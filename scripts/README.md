# Automation scripts

## `update-formula.sh`

Updates `Formula/everestctl.rb` to a new GA version.

```bash
./scripts/update-formula.sh <version>   # e.g. 1.14.0
```

Behaviour:

- Refuses non-GA versions (e.g. `1.14.0-rc1`) — the tap only ships GA builds.
- Verifies the upstream GitHub release exists and is **published** (not draft, not prerelease) before downloading any assets, via the GitHub Releases API.
- Uses `curl -fsSL` so a 404 / 5xx hard-fails the script rather than silently producing a SHA of an HTML error page.
- Sanity-checks each downloaded asset (non-empty, not HTML) before hashing.
- Idempotent — re-running for the same version produces no diff.
