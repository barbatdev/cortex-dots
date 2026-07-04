# cortex-dots

Open-source dotfiles for a terminal workflow centered on Ghostty, Zsh, Starship, Herdr, Claude Code, and OpenCode.

The repo is intentionally generic. Private paths, tokens, emails, hostnames, project aliases, and machine-specific overrides belong in `~/.config/cortex-dots/local/env.zsh`, which is generated from `local/env.zsh.example`.

## Install

```bash
git clone <repo-url> ~/.cortex/cortex-dots
cd ~/.cortex/cortex-dots
bash install.sh
```

The default install copies files into your home/config directories. The cloned
repo is not required at runtime after installation.

For dotfiles development, keep live links back to the checkout:

```bash
bash install.sh --symlink
```

Preview without changing files:

```bash
bash install.sh --dry-run
bash install.sh --dry-run --symlink
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
| `dotfiles` | `$CORTEX_DOTFILES_DIR` (`~/.config/cortex-dots`) |

Override any of these in `~/.config/cortex-dots/local/env.zsh`.

## Private Config

Edit the generated local file:

```bash
${EDITOR:-vi} ~/.config/cortex-dots/local/env.zsh
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

Never commit private env files or machine-specific overrides.

## Fonts

The Ghostty config expects `FiraCode Nerd Font Mono Beard`. The installer bundles and installs `fonts/FiraCodeNerdFontMonoBeard-Reg.ttf` so Linux and macOS users get the same font name.

If you want a different font, install it manually and update `ghostty/config` and `starship/starship.toml` locally.

## Ghostty On Linux

The default Ghostty config launches `zsh` so Starship can initialize from
`~/.zshrc`. If the prompt does not appear, check:

```bash
command -v ghostty
command -v zsh
command -v starship
zsh -i -c 'command -v starship && echo starship-ok'
```

Font names vary by distro/package. Verify the installed name before changing
`ghostty/config`:

```bash
fc-match "FiraCode Nerd Font Mono Beard"
fc-list | grep -i "FiraCode"
```

Transparency depends on your Linux compositor/window manager. Shaders are
opt-in in `ghostty/config`; uncomment one `custom-shader` line only after
confirming your GPU/driver handles it well.

## OSS Audit

Run before publishing or packaging:

```bash
scripts/oss-audit.sh
```

The audit scans tracked files only and fails on configured private identifiers, private paths, and email-shaped strings.
Set `OSS_AUDIT_FORBIDDEN_REGEX` or create an untracked `.oss-audit-denylist.local` file with one regex per line to add private denylist terms locally.
For CI, configure the repository variable `OSS_AUDIT_FORBIDDEN_REGEX` with private denylist terms instead of committing them.

## Validation

```bash
scripts/oss-audit.sh
scripts/test-install.sh
scripts/test-install.sh --symlink
scripts/test-install.sh --seed-stale-opposite
scripts/test-install.sh --symlink --seed-stale-opposite
bash -n install.sh
zsh -n zsh/zshrc
for path in opencode/*.json opencode/**/*.json claude/themes/*.json; do jq . "$path" >/dev/null 2>&1 || echo "invalid: $path"; done
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
