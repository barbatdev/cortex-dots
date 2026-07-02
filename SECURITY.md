# Security Policy

## Reporting

Please report security issues privately to the repository maintainers through the hosting platform's private vulnerability reporting feature when available.

Do not open public issues for secrets, credential exposure, or command-injection findings until a maintainer has reviewed the report.

## Scope

This repository contains dotfiles and installer scripts. Security-sensitive areas include shell startup files, package-manager defaults, symlink creation, macOS service startup, and AI CLI helper scripts.

## Local Secrets

Do not commit secrets or machine-specific values. Use `local/env.zsh`, which is intentionally gitignored.
