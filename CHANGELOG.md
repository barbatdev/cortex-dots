# Changelog

## 0.1.0 - 2026-07-01

- Initial OSS-safe `cortex-dots` snapshot.
- Generalized private paths and navigation defaults.
- Removed custom font binary and private brand assets.
- Added MIT license, security policy, third-party notices, release checklist, and OSS audit script.

## 0.1.1 - 2026-07-04

### Breaking

- Renamed `pcsoft-helpers.zsh` → `pc-helpers.zsh` (generic name for broader reuse).

### Added

- `scripts/test-install.sh` — automated installer tests (copy, symlink, stale-opposite scenarios).
- `scripts/check-agent-state.sh` — agent-state validator for release checklist.
- `.oss-audit-denylist.local` — untracked personal denylist for OSS audit (one regex per line).
- `OSS_AUDIT_FORBIDDEN_REGEX` CI variable support — configure repo-level denylist without committing.

### Changed

- OSS audit script — externalized forbidden identifiers to env var + local denylist; no longer hardcodes private terms.
- CI — added installer integration tests step; passes `OSS_AUDIT_FORBIDDEN_REGEX` from repo vars.
- `.gitignore` — added `.oss-audit-denylist.local`.
