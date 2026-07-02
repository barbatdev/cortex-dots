# cortex-dots

Open-source dotfiles for a terminal workflow centered on Ghostty, Zsh, Starship, Herdr, Claude Code, and OpenCode.

The repo is intentionally generic. Private paths, tokens, emails, hostnames, project aliases, and machine-specific overrides belong in `local/env.zsh`, which is gitignored and generated from `local/env.zsh.example`.

## Install

```bash
git clone <repo-url> ~/.cortex/cortex-dots
cd ~/.cortex/cortex-dots
bash install.sh
```

Preview without changing files:

```bash
bash install.sh --dry-run
```

Audit the local environment without installing packages or creating symlinks:

```bash
bash install.sh --check
```

## What It Includes

| Area | Files |
| --- | --- |
| Shell | `zsh/zshrc`, `zsh/scripts/` |
| Terminal | `ghostty/config`, `ghostty/shaders/` |
| Prompt | `starship/starship.toml` using the generic `cortex_warm_slate` palette |
| Multiplexer | `herdr/config.toml` plus session helpers |
| AI CLI UX | `claude/`, `opencode/`, Herdr helpers, agent-state docs |
| Package guardrails | global defaults for `npm`, `pnpm`, `bun`, and `uv` |

## Navigation Defaults

The shell profile uses safe, env-driven defaults:

| Command | Default target |
| --- | --- |
| `dev` | `$WORKSPACE_DIR` (`~/dev`) |
| `work` | `$WORK_PROJECTS_DIR` (`~/dev/work`) |
| `personal` | `$PERSONAL_PROJECTS_DIR` (`~/dev/personal`) |
| `tools` | `$TOOLS_DIR` (`~/dev/tools`) |
| `worktrees` | `$WORKTREES_DIR` (`~/dev/worktrees`) |
| `cortex` | `$CORTEX_ROOT` (`~/.cortex/cortex`) |
| `dotfiles` | `$CORTEX_DOTFILES_DIR` (`~/.cortex/cortex-dots`) |

Override any of these in `local/env.zsh`.

## Private Config

Copy or edit the generated local file:

```bash
cp local/env.zsh.example local/env.zsh
```

Typical private values:

| Variable | Purpose |
| --- | --- |
| `WORKSPACE_DIR` | root directory for local projects |
| `WORK_PROJECTS_DIR` | work project directory |
| `PERSONAL_PROJECTS_DIR` | personal project directory |
| `TOOLS_DIR` | local tools directory |
| `WORKTREES_DIR` | git worktrees directory |
| `CORTEX_HOME` | Cortex state/root directory |
| `CORTEX_ROOT` | Cortex product repo path |
| `CORTEX_DOTFILES_DIR` | this dotfiles repo path |
| `SCREENSHOTS_DIR` | screenshots directory |
| `GIT_WORK_NAME`, `GIT_WORK_EMAIL` | work git identity |
| `GIT_PERSONAL_NAME`, `GIT_PERSONAL_EMAIL` | personal git identity |
| `OPENCODE_DEFAULT_FLAGS` | default flags for `oc` |

Never commit `local/env.zsh`.

## Fonts

The OSS snapshot uses the official `FiraCode Nerd Font` installed by Homebrew when available. A previously bundled custom font binary is intentionally not included because downstream users should verify font licensing and branding assets themselves.

If you want a custom font, install it manually and update `ghostty/config` and `starship/starship.toml` locally.

## OSS Audit

Run before publishing or packaging:

```bash
scripts/oss-audit.sh
```

The audit scans tracked files only and fails on known private identifiers, private paths, and email-shaped strings.

## Validation

```bash
scripts/oss-audit.sh
bash -n install.sh
zsh -n zsh/zshrc
python3 - <<'PY'
import pathlib, tomllib
for path in pathlib.Path('.').rglob('*.toml'):
    with path.open('rb') as handle:
        tomllib.load(handle)
PY
bash install.sh --check
```

## Docs

- [Agent State v1](docs/agent-state-v1.md)
- [Herdr workflow](docs/herdr-workflow.md)
- [Keymaps](docs/keymaps.md)
- [Release checklist](docs/release-checklist.md)

## License

MIT. See [LICENSE](LICENSE).
