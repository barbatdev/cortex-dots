# Contributing

Thanks for helping improve `cortex-dots`. This repository is public, but changes are intentionally gated because these dotfiles affect local shells, developer tooling, package-manager defaults, and AI CLI behavior.

## Contribution Flow

1. Open an issue before starting work.
2. Wait for maintainer agreement on the scope.
3. Open a pull request linked to the issue.
4. Keep the PR focused on one change.
5. Wait for maintainer review before merge.

Maintainers may close PRs that do not have a linked issue or that expand beyond the agreed scope.

## What Needs Review

All changes to `main` require maintainer review. This is especially important for:

- Shell startup files and helper scripts.
- Installer behavior.
- Package-manager configuration.
- AI CLI configuration or permission flags.
- GitHub Actions and repository governance files.
- Any file that could expose private paths, hostnames, emails, tokens, or machine-specific data.

## Public Safety Rules

- Do not commit secrets, tokens, private keys, real emails, private hostnames, private IPs, customer names, or machine-specific paths.
- Put local/private values in `~/.config/cortex-dots/local/env.zsh`.
- Keep examples generic and placeholder-based.
- Run the validation commands listed in `README.md` when touching scripts or config formats.

## Supply Chain Security

Any external tool, CLI, or dependency installed by `install.sh` or referenced in scripts must be pinned to a specific version. Do not use `latest`, `^ SemVer` ranges, or unpinned references in installation commands. Versions must be at least 15 days old before adoption — supply chain attacks typically target newly published releases.

```bash
# Good — pinned version, 15+ days old
curl -fsSL https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin" -y --commit abc123

# Good — pinned package manager version
npm install -g some-cli@2.4.1

# Bad — no version pinning
curl -fsSL https://example.com/install | bash

# Bad — latest tag
npm install -g some-cli@latest
```

For GitHub Actions in workflows, always use explicit commit SHAs (`@commit-sha`) or pinned minor versions (`@v4`). Avoid `${{ github.sha }}` or floating tags in production workflows.

## Pull Request Expectations

Every PR should include:

- A linked issue, using `Fixes #123`, `Closes #123`, or `Refs #123`.
- A short summary of the change.
- Validation performed.
- Any security or public-exposure considerations.

## Maintainer Merge Policy

Only maintainers merge to `main`. PRs should be merged only after the repository owner has reviewed and approved the change.
