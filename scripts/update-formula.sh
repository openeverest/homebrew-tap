#!/usr/bin/env bash

# Script to manually update the Homebrew formula for a new everestctl release
# Usage: ./scripts/update-formula.sh <version>
# Example: ./scripts/update-formula.sh 1.14.0

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.14.0"
    exit 1
fi

VERSION=$1
BASE_URL="https://github.com/openeverest/openeverest/releases/download/v${VERSION}"
FORMULA_FILE="Formula/everestctl.rb"

echo "Updating everestctl formula to version ${VERSION}..."

# Create temporary directory
TMP_DIR=$(mktemp -d)
trap "rm -rf ${TMP_DIR}" EXIT

# Download all binaries and calculate SHA256
declare -A SHAS

for os_arch in darwin-amd64 darwin-arm64 linux-amd64 linux-arm64; do
    echo "Downloading and calculating SHA256 for everestctl-${os_arch}..."
    curl -sL "${BASE_URL}/everestctl-${os_arch}" -o "${TMP_DIR}/everestctl-${os_arch}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sha=$(shasum -a 256 "${TMP_DIR}/everestctl-${os_arch}" | awk '{print $1}')
    else
        sha=$(sha256sum "${TMP_DIR}/everestctl-${os_arch}" | awk '{print $1}')
    fi
    
    SHAS[$os_arch]=$sha
    echo "  SHA256: ${sha}"
done

echo ""
echo "Updating ${FORMULA_FILE}..."

# Update version
sed -i.bak "s/version \".*\"/version \"${VERSION}\"/" "${FORMULA_FILE}"

# Update URLs and SHA256s for each platform
sed -i.bak "/everestctl-darwin-amd64/s|download/v[0-9.]*/|download/v${VERSION}/|" "${FORMULA_FILE}"
sed -i.bak "/darwin-amd64\"/,/sha256/s/sha256 \".*\"/sha256 \"${SHAS[darwin-amd64]}\"/" "${FORMULA_FILE}"

sed -i.bak "/everestctl-darwin-arm64/s|download/v[0-9.]*/|download/v${VERSION}/|" "${FORMULA_FILE}"
sed -i.bak "/darwin-arm64\"/,/sha256/s/sha256 \".*\"/sha256 \"${SHAS[darwin-arm64]}\"/" "${FORMULA_FILE}"

sed -i.bak "/everestctl-linux-amd64/s|download/v[0-9.]*/|download/v${VERSION}/|" "${FORMULA_FILE}"
sed -i.bak "/linux-amd64\"/,/sha256/s/sha256 \".*\"/sha256 \"${SHAS[linux-amd64]}\"/" "${FORMULA_FILE}"

sed -i.bak "/everestctl-linux-arm64/s|download/v[0-9.]*/|download/v${VERSION}/|" "${FORMULA_FILE}"
sed -i.bak "/linux-arm64\"/,/sha256/s/sha256 \".*\"/sha256 \"${SHAS[linux-arm64]}\"/" "${FORMULA_FILE}"

# Remove backup file
rm -f "${FORMULA_FILE}.bak"

echo ""
echo "✅ Formula updated successfully!"
echo ""
echo "Please review the changes with:"
echo "  git diff ${FORMULA_FILE}"
echo ""
echo "If everything looks good, commit and push:"
echo "  git add ${FORMULA_FILE}"
echo "  git commit -m \"Update everestctl to v${VERSION}\""
echo "  git push"
