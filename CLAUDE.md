# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository

Terminal dotfiles: configuration for Ghostty + Zsh + Starship. The installer creates symlinks from the repo directory to standard system locations.

## Installation and testing

```bash
# Install dotfiles (creates symlinks + installs local dependencies)
./install.sh

# Measure zsh profile load time
time zsh -i -c exit

# Verify symlinks are correct
ls -la ~/.zshrc ~/.config/starship.toml ~/.config/ghostty/config

# Validate syntax without installing
bash install.sh --check
```

Manually validate by reloading the shell with `source ~/.zshrc` or `reload` and checking that commands work.

## Directory structure

```
dotfiles/
├── zsh/
│   ├── zshrc                 # Main profile → symlinked to ~/.zshrc
│   └── scripts/              # Scripts sourced from zshrc
│       ├── pc-helpers.zsh        # is-pc-forbidden, is-pc-editable (PC file detection)
│       ├── screenshots.zsh       # ss, last, ssd, imgclip (screenshot helpers)
│       └── ssh-helpers.zsh       # sshx, moshx helpers (SSH/remote shortcuts)
├── starship/starship.toml    # Prompt → ~/.config/starship.toml
├── ghostty/
│   ├── config                # Terminal config → ~/.config/ghostty/config
│   └── shaders/              # Cursor shaders (4 glsl files)
├── herdr/config.toml         # Multiplexer → ~/.config/herdr/config.toml
├── lazygit/config.yml        # LazyGit → ~/.config/lazygit/config.yml
├── fonts/
│   └── FiraCodeNerdFontMonoBeard-Reg.ttf  # Terminal font
├── local/
│   └── env.zsh.example       # Template for ~/.config/cortex-dots/local/env.zsh
├── bun/bunfig.toml           # Bun defaults
├── npm/npmrc                 # NPM defaults
├── pnpm/rc                   # PNPM defaults
├── uv/uv.toml                # UV defaults
├── scripts/
│   ├── test-install.sh       # Installation tests
│   └── oss-audit.sh          # OSS safety audit
└── install.sh                # Installer
```

**zshrc loading order:** Sections are split by `#region`/`#endregion`. The order matters: Setup → PATH → zsh options → Editor → Env vars → Aliases → Source scripts → Local overrides → Starship → Welcome.

**`~/.config/cortex-dots/local/env.zsh`** contains personal paths, tokens and environment variable overrides (`SCREENSHOTS_DIR`, `WORKSPACE_DIR`, `WORK_PROJECTS_DIR`, `CORTEX_HOME`, `CORTEX_ROOT`, `CORTEX_CONFIG_HOME`, `CORTEX_MULTIPLEXER`). Generated from `env.zsh.example` on first install.

## Editing conventions

- `.zsh` scripts use `#region`/`#endregion` for logical groups.
- Each public function should have a comment explaining its use.
- Environment variables with defaults use `${VAR:-default}` for overrides from `~/.config/cortex-dots/local/env.zsh`.
- `install.sh` uses `set -e` and backs up existing configs before copying or symlinking — maintain this pattern when adding new configs.

## Adding a new config

1. Create the config file in its directory (`name/config`)
2. Add backup + symlink in `install.sh` following the existing pattern
3. Update the README.md with the new entry in the structure table
