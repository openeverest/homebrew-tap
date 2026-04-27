#!/usr/bin/env bash
#
# Update the Homebrew formula for everestctl to a new release version.
#
# Usage:   ./scripts/update-formula.sh <version>
# Example: ./scripts/update-formula.sh 1.14.0
#
# Behaviour:
#   * Refuses to run for non-GA versions (e.g. 1.14.0-rc1) — the tap only
#     ships GA builds.
#   * Verifies that the upstream GitHub release exists and is *published*
#     (not draft, not prerelease) before downloading any assets. This prevents
#     the class of bug where the formula is updated against assets that get
#     re-uploaded after the draft is published.
#   * Uses `curl -fsSL` so any HTTP error (404, 5xx) hard-fails the script
#     instead of silently producing a SHA of an HTML error page.
#   * Sanity-checks each downloaded asset (non-empty, not HTML) before hashing.
#   * Updates Formula/everestctl.rb in-place.
#   * Creates or updates Formula/everestctl@X.Y.rb (versioned, keg_only) so
#     users can pin to a specific minor.

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <version>" >&2
    echo "Example: $0 1.14.0" >&2
    exit 64
fi

VERSION="$1"
FORMULA_FILE="Formula/everestctl.rb"
MAJOR_MINOR="${VERSION%.*}"                       # 1.14.3 -> 1.14
VERSIONED_FILE="Formula/everestctl@${MAJOR_MINOR}.rb"
CLASS_SUFFIX="${MAJOR_MINOR//./}"                 # 1.14 -> 114
VERSIONED_CLASS="EverestctlAT${CLASS_SUFFIX}"
REPO="openeverest/openeverest"
BASE_URL="https://github.com/${REPO}/releases/download/v${VERSION}"
ASSETS=(darwin-amd64 darwin-arm64 linux-amd64 linux-arm64)

# --- Validation ---------------------------------------------------------------

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: version '$VERSION' is not a GA semver (X.Y.Z)." >&2
    echo "       The tap only ships GA releases; pre-releases are skipped." >&2
    exit 1
fi

if [[ ! -f "$FORMULA_FILE" ]]; then
    echo "ERROR: $FORMULA_FILE not found. Run from the repo root." >&2
    exit 1
fi

# --- Verify the upstream release is published ---------------------------------

echo "==> Checking upstream release v${VERSION} is published..."
RELEASE_JSON=$(curl -fsSL \
    -H "Accept: application/vnd.github+json" \
    ${GITHUB_TOKEN:+-H "Authorization: Bearer ${GITHUB_TOKEN}"} \
    "https://api.github.com/repos/${REPO}/releases/tags/v${VERSION}") \
    || { echo "ERROR: release v${VERSION} not found on GitHub." >&2; exit 1; }

extract_bool() {
    # crude JSON field extraction without jq dependency
    echo "$RELEASE_JSON" | grep -E "\"$1\":" | head -n1 | sed -E 's/.*: *(true|false).*/\1/'
}

DRAFT=$(extract_bool draft)
PRERELEASE=$(extract_bool prerelease)

if [[ "$DRAFT" == "true" ]]; then
    echo "ERROR: release v${VERSION} is still a draft. Publish it first." >&2
    exit 1
fi
if [[ "$PRERELEASE" == "true" ]]; then
    echo "ERROR: release v${VERSION} is marked as a pre-release. Skipping." >&2
    exit 1
fi

# --- Download and hash assets -------------------------------------------------

TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

declare -A SHAS

for asset in "${ASSETS[@]}"; do
    file="everestctl-${asset}"
    out="${TMP_DIR}/${file}"
    echo "==> Downloading ${file}..."
    curl -fsSL "${BASE_URL}/${file}" -o "${out}"

    if [[ ! -s "${out}" ]]; then
        echo "ERROR: ${file} downloaded but is empty." >&2
        exit 1
    fi
    # Reject HTML/text in case GitHub served an error page despite a 200.
    if head -c 16 "${out}" | grep -qiE '<!doctype|<html'; then
        echo "ERROR: ${file} appears to be HTML, not a binary." >&2
        exit 1
    fi

    if [[ "${OSTYPE:-}" == darwin* ]]; then
        sha=$(shasum -a 256 "${out}" | awk '{print $1}')
    else
        sha=$(sha256sum "${out}" | awk '{print $1}')
    fi
    SHAS[$asset]=$sha
    echo "    sha256: ${sha}"
done

# --- Patch the formula --------------------------------------------------------

echo "==> Updating ${FORMULA_FILE}..."

SED_INPLACE=(-i)
if [[ "${OSTYPE:-}" == darwin* ]]; then
    SED_INPLACE=(-i '')
fi

# Update the top-level `version` line.
sed "${SED_INPLACE[@]}" -E \
    "s|^(  version )\".*\"|\1\"${VERSION}\"|" \
    "${FORMULA_FILE}"

for asset in "${ASSETS[@]}"; do
    file="everestctl-${asset}"
    sha="${SHAS[$asset]}"

    # Update the URL line for this asset to point at the new version.
    sed "${SED_INPLACE[@]}" -E \
        "s|(/releases/download/)v[0-9]+\.[0-9]+\.[0-9]+(/${file})|\1v${VERSION}\2|" \
        "${FORMULA_FILE}"

    # Update the sha256 immediately following that asset's url line.
    # Use awk for context-aware replacement (sed range matching is fragile).
    awk -v file="${file}" -v sha="${sha}" '
        /url ".*\/'"$file"'"/ { print; getline; sub(/sha256 ".*"/, "sha256 \"" sha "\""); print; next }
        { print }
    ' "${FORMULA_FILE}" > "${FORMULA_FILE}.tmp"
    mv "${FORMULA_FILE}.tmp" "${FORMULA_FILE}"
done

# --- Generate the versioned formula ------------------------------------------
#
# Always (re)written from scratch from a template so a 1.14.3 release
# overwrites a previous 1.14.0 @1.14 formula with the latest patch SHAs,
# while older minors (e.g. @1.13) are left untouched.

echo "==> Writing ${VERSIONED_FILE}..."

cat > "${VERSIONED_FILE}" <<EOF
class ${VERSIONED_CLASS} < Formula
  desc "CLI tool for provisioning and managing OpenEverest on Kubernetes"
  homepage "https://github.com/${REPO}"
  version "${VERSION}"
  license "Apache-2.0"

  keg_only :versioned_formula

  on_macos do
    on_intel do
      url "${BASE_URL}/everestctl-darwin-amd64"
      sha256 "${SHAS[darwin-amd64]}"
    end
    on_arm do
      url "${BASE_URL}/everestctl-darwin-arm64"
      sha256 "${SHAS[darwin-arm64]}"
    end
  end

  on_linux do
    on_intel do
      url "${BASE_URL}/everestctl-linux-amd64"
      sha256 "${SHAS[linux-amd64]}"
    end
    on_arm do
      url "${BASE_URL}/everestctl-linux-arm64"
      sha256 "${SHAS[linux-arm64]}"
    end
  end

  def install
    os = OS.mac? ? "darwin" : "linux"
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    bin.install "everestctl-#{os}-#{arch}" => "everestctl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/everestctl version 2>&1")
  end
end
EOF

echo ""
echo "✅ Updated ${FORMULA_FILE} and ${VERSIONED_FILE} to v${VERSION}."
echo ""
echo "Next steps:"
echo "  git diff Formula/"
echo "  brew style openeverest/tap/everestctl openeverest/tap/everestctl@${MAJOR_MINOR}"
echo "  brew audit --strict --online openeverest/tap/everestctl openeverest/tap/everestctl@${MAJOR_MINOR}"
echo "  git add Formula/"
echo "  git commit -m \"everestctl ${VERSION}\""
