# Changelog

## 0.1.0 - 2026-07-01

- Initial OSS-safe `cortex-dots` snapshot.
- Generalized private paths and navigation defaults.
- Removed custom font binary and private brand assets.
- Added MIT license, security policy, third-party notices, release checklist, and automated installer tests.

## 0.1.1 - 2026-07-04

### Breaking

- Renamed `pcsoft-helpers.zsh` → `pc-helpers.zsh` (generic name for broader reuse).

### Added

- `scripts/test-install.sh` — automated installer tests (copy, symlink, stale-opposite scenarios).
- `scripts/check-agent-state.sh` — agent-state validator for release checklist.
- Supply chain security rules — external tools must be pinned to specific versions, 15+ days old.

### Changed

- CI — added installer integration tests step.
