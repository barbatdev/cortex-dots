# Changelog

## 0.1.0 - 2026-07-01

- Initial OSS-safe `cortex-dots` snapshot.
- Generalized private paths and navigation defaults.
- Removed custom font binary and private brand assets.
- Added MIT license, security policy, third-party notices, and automated installer tests.

## 0.1.1 - 2026-07-04

- Renamed `pcsoft-helpers.zsh` → `pc-helpers.zsh`.
- Added `scripts/test-install.sh` — automated installer tests.
- CI — added installer integration tests step.

## 0.2.0 - 2026-07-04

> Breaking: this release removes all code and documentation that belongs to the cortex product. This repo is now exclusively dotfiles — configuration files, installer, and shell aliases.

### Breaking

- Removed `docs/` — agent-state spec, workflow docs, keymaps, release checklist (belong to cortex product).
- Removed `ghostty/muxy.conf` — external integration config.
- Removed `nvim/README.md` — nvim config documentation (config not versioned here).
- Removed `scripts/check-agent-state.sh` — product validator.
- Removed `zsh/scripts/agent-state.sh` — product API component (300 lines).
- Removed `zsh/scripts/claude-helpers.zsh` — Claude Code launchers (`cc`, `ccb`, `ccx`, `ccd`, `ccclip`).
- Removed `zsh/scripts/git-helpers.zsh` — git identity/workflow tools.
- Removed `zsh/scripts/herdr-helpers.zsh` — session helpers (`hhere`, `hfocus`, `hside`, `hscratch`, `hremote`, `hname`, `whereami`).
- Removed `zsh/scripts/memsave-nudge.sh` — Claude Code hook for personal memory.
- Removed `zsh/scripts/postcompact-hook.sh` — Claude Code hook for post-compaction.
- Removed `zsh/scripts/worktree-helpers.zsh` — worktree management tools.
- Removed `claude/themes/` — Claude Code themes (cortex.json, cortex-green.json).
- Removed `opencode/themes/` — OpenCode themes (cortex.json, cortex-green.json).
- Removed `claude/statusline.sh` — Claude Code status line script.
- Removed `opencode/tui.json` — OpenCode TUI configuration.
- Removed `scripts/oss-audit.sh` and `.oss-audit-denylist.local` — OSS safety tool (private denylist, only owner used it).

### Docs

- Cleaned CLAUDE.md — removed all product references, simplified to dotfiles structure.
- Cleaned CONTRIBUTING.md — removed supply chain security section.
- Cleaned CHANGELOG.md — removed references to deleted files.
- Cleaned README.md — removed docs section and product references.
- Cleaned zsh/zshrc — removed sourcing of deleted scripts.
