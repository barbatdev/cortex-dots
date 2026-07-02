# Release Checklist

Use this checklist before publishing a snapshot or tagging a release.

1. Start from tracked files on `main` only.
2. Verify `local/env.zsh`, ignored files, and `.git` history are not included in exported artifacts.
3. Run `scripts/oss-audit.sh`.
4. Run shell syntax checks for `install.sh`, `zsh/zshrc`, `zsh/scripts/*.zsh`, and `scripts/*.sh`.
5. Validate JSON with `jq`.
6. Validate TOML with Python `tomllib`.
7. Run `bash install.sh --check`.
8. Review `README.md`, `SECURITY.md`, `THIRD_PARTY.md`, and `CHANGELOG.md` for release accuracy.
9. Create the release archive from tracked files only.
