# Automation Scripts

## update-formula.sh

Script to update the Homebrew formula when a new everestctl release is published.

### Manual Usage

```bash
./scripts/update-formula.sh <version>
```

Example:
```bash
./scripts/update-formula.sh 1.14.0
```

This will:
1. Download all platform binaries (darwin-amd64, darwin-arm64, linux-amd64, linux-arm64)
2. Calculate SHA256 hashes for each
3. Update the formula with new version and hashes
4. Show you a summary of changes to review

### Automated Usage

The GitHub Actions workflow can be triggered in two ways:

#### 1. Manual Trigger (workflow_dispatch)
Go to Actions → Update Formula → Run workflow and enter the version number.

#### 2. Repository Dispatch (from openeverest/openeverest)
When a new release is created in the main repository, trigger this workflow with:

```bash
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <TOKEN>" \
  https://api.github.com/repos/openeverest/homebrew-tap/dispatches \
  -d '{"event_type":"new-release","client_payload":{"version":"1.14.0"}}'
```

Or add this to your openeverest/openeverest release workflow:
```yaml
- name: Update Homebrew tap
  run: |
    curl -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${{ secrets.TAP_REPO_TOKEN }}" \
      https://api.github.com/repos/openeverest/homebrew-tap/dispatches \
      -d "{\"event_type\":\"new-release\",\"client_payload\":{\"version\":\"${VERSION}\"}}"
```
