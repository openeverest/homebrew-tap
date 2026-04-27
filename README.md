# OpenEverest Homebrew Tap

Homebrew tap for [`everestctl`](https://github.com/openeverest/openeverest) — the OpenEverest CLI for managing OpenEverest on Kubernetes.

Supports macOS (Intel and Apple Silicon) and Linux (x86_64 and arm64).

## Install

```bash
brew tap openeverest/tap
brew install everestctl
```

The unversioned `everestctl` formula always tracks the latest GA release of OpenEverest.

## Install a specific version

If your OpenEverest server requires a particular `everestctl` minor version, install a versioned formula:

```bash
brew install everestctl@X.Y   # e.g. everestctl@1.14
```

Versioned formulae are `keg_only`, so they don't shadow the main `everestctl` binary on `PATH`. To use one, either symlink it explicitly or invoke it by full path:

```bash
brew link --force everestctl@X.Y
# or
"$(brew --prefix everestctl@X.Y)/bin/everestctl" version
```

## Usage

Interactive install:

```bash
everestctl install
```

Headless install:

```bash
everestctl install \
  --namespaces <namespace> \
  --operator.mongodb=true \
  --operator.postgresql=true \
  --operator.mysql=true \
  --skip-wizard
```

Common commands:

```bash
everestctl namespaces add <namespace>
everestctl install --skip-db-namespace
everestctl accounts set-password --username admin
```

Full documentation: <https://openeverest.io/documentation/current>

## Maintainer notes

### Releasing a new version

Publishing a non-prerelease GitHub release in `openeverest/openeverest` automatically dispatches the [Update Formula](.github/workflows/update-formula.yml) workflow in this repo, which:

1. Verifies the upstream GitHub release is published and not a prerelease.
2. Downloads each platform binary and computes SHA-256 with `curl -fsSL` (fail-fast).
3. Patches `Formula/everestctl.rb`.
4. Creates or updates `Formula/everestctl@X.Y.rb` for the released minor.
5. Runs `brew style` and `brew audit --strict --online` against both formulae.
6. Commits and pushes directly to `main`.

### Adding a versioned formula

`update-formula.sh` automatically creates or updates `Formula/everestctl@X.Y.rb` on every release, so no manual steps are needed. When the next minor ships, the script creates a new versioned formula and the previous minor's formula remains as the pinned older minor.

### Deprecating an old version

When a minor exits support, mark its formula deprecated rather than deleting it immediately:

```ruby
deprecate! date: "2026-12-01", because: :unmaintained
```

After two releases, delete the formula file.

### Manual formula bump

```bash
./scripts/update-formula.sh <version>
brew style openeverest/tap/everestctl
brew audit --strict --online openeverest/tap/everestctl
```
