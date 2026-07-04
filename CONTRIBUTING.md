# Contributing

Thanks for helping improve `cortex-dots`. This repository is public, but changes are intentionally gated because these dotfiles affect local shells, developer tooling, and package-manager defaults.

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
- GitHub Actions and repository governance files.
- Any file that could expose private paths, hostnames, emails, tokens, or machine-specific data.

## Public Safety Rules

- Do not commit secrets, tokens, private keys, real emails, private hostnames, private IPs, customer names, or machine-specific paths.
- Put local/private values in `~/.config/cortex-dots/local/env.zsh`.
- Keep examples generic and placeholder-based.
- Run the validation commands listed in `README.md` when touching scripts or config formats.

## Pull Request Expectations

Every PR should include:

- A linked issue, using `Fixes #123`, `Closes #123`, or `Refs #123`.
- A short summary of the change.
- Validation performed.
- Any security or public-exposure considerations.

## Maintainer Merge Policy

Only maintainers merge to `main`. PRs should be merged only after the repository owner has reviewed and approved the change.
