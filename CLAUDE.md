# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repositorio

Dotfiles para terminal: configuración de Ghostty + Zsh + Starship. El instalador crea symlinks desde el directorio del repo hacia las ubicaciones estándar del sistema.

## Instalación y testing

```bash
# Instalar dotfiles (crea symlinks + instala dependencias)
./install.sh

# Medir load time del profile zsh
time zsh -i -c exit

# Verificar que los symlinks están correctos
ls -la ~/.zshrc ~/.config/starship.toml ~/.config/ghostty/config

# Validar sintaxis sin instalar
bash install.sh --check
```

No hay tests automatizados. La validación es manual: recargar la shell con `source ~/.zshrc` o `reload` y verificar que los comandos funcionen.

## Estructura y arquitectura

```
dotfiles/
├── zsh/
│   ├── zshrc                 # Profile principal → symlink a ~/.zshrc
│   └── scripts/              # Scripts sourced desde zshrc
│       ├── agent-state.sh         # Local CLI para cortex.agent_state.v1
│       ├── claude-helpers.zsh     # cc, ccb, ccx, ccd, ccclip
│       ├── git-helpers.zsh        # git-workdev, git-personaldev, git-whoami, clone-*
│       ├── herdr-helpers.zsh      # hhere, hfocus, hside, hscratch, hremote, hname, whereami
│       ├── pc-helpers.zsh         # is-pc-forbidden, is-pc-editable
│       ├── screenshots.zsh        # ss, last, ssd, imgclip
│       ├── ssh-helpers.zsh        # sshx, moshx helpers
│       ├── worktree-helpers.zsh   # wtadd, wtlist, wtremove
│       ├── memsave-nudge.sh       # Hook UserPromptSubmit para recordar mem_save
│       └── postcompact-hook.sh    # Hook PostCompact con orden explícito
├── starship/starship.toml    # Prompt → ~/.config/starship.toml
├── ghostty/
│   ├── config                # Terminal → ~/.config/ghostty/config
│   ├── muxy.conf             # Muxy integration config
│   └── shaders/              # 4 cursor shaders (glsl)
├── herdr/config.toml         # Multiplexor → ~/.config/herdr/config.toml
├── lazygit/config.yml        # LazyGit → ~/.config/lazygit/config.yml
├── local/
│   └── env.zsh.example       # Template para ~/.config/cortex-dots/local/env.zsh
├── fonts/
│   └── FiraCodeNerdFontMonoBeard-Reg.ttf  # Terminal font
├── scripts/
│   ├── oss-audit.sh          # OSS safety audit
│   ├── test-install.sh       # Installation tests
│   └── check-agent-state.sh  # Agent state validator
├── bun/bunfig.toml           # Bun defaults
├── npm/npmrc                 # NPM defaults
├── pnpm/rc                   # PNPM defaults
├── uv/uv.toml                # UV defaults
└── install.sh                # Instalador
```

**Flujo de carga del zshrc:** Las secciones están separadas por `#region`/`#endregion`. El orden importa: Brew → PATH → Zsh options → Editor → Env vars → Aliases → Source scripts → Local overrides → Starship → Welcome. Scripts en `zsh/scripts/` que son hooks de Claude Code (memsave-nudge.sh, postcompact-hook.sh) no se sourced desde zshrc, se usan directamente como hooks en la config de Claude Code.

**`~/.config/cortex-dots/local/env.zsh`** contiene paths personales, tokens y overrides de variables de entorno (`SCREENSHOTS_DIR`, `WORKSPACE_DIR`, `WORK_PROJECTS_DIR`, `CORTEX_HOME`, `CORTEX_ROOT`, `CORTEX_CONFIG_HOME`, `CORTEX_MULTIPLEXER`). Se genera desde `env.zsh.example` en la primera instalación.

## Múltiples identidades GitHub

El repositorio maneja dos cuentas de GitHub con SSH host aliases:
- `github-workdev` → cuenta de trabajo/empresa (configurar con tu email de empresa)
- `github-personaldev` → cuenta personal (configurar con tu email personal)

Los helpers en `git-helpers.zsh` configuran la identidad local del repo Y actualizan el remote URL para usar el alias SSH correcto. Cuando se agregan nuevas funciones relacionadas con identidades, seguir el mismo patrón.

## Convenciones al editar

- Los scripts `.zsh` usan `#region`/`#endregion` para agrupar secciones lógicas.
- Cada función pública en los scripts debe tener un comentario explicando su uso.
- Variables de entorno con defaults se definen como `${VAR:-default}` para permitir override desde `~/.config/cortex-dots/local/env.zsh`.
- `install.sh` usa `set -e` y hace backup de configs existentes antes de copiar o linkear configs — mantener este comportamiento al agregar nuevas configs.

## Agregar una nueva configuración

1. Crear el archivo de config en su directorio (`nombre-herramienta/config`)
2. Agregar backup + symlink en `install.sh` siguiendo el patrón existente
3. Actualizar el README.md con la nueva entrada en la tabla de estructura
