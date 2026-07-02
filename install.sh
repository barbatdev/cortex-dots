#!/bin/bash
# install.sh — Instalador de dotfiles
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DRY_RUN=false
CHECK_MODE=false
INSTALL_MODE="copy"
CORTEX_CONFIG_HOME="${CORTEX_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/cortex-dots}"
PENDING_GHOSTTY_DIR="$CORTEX_CONFIG_HOME/pending/ghostty"

case "$(uname -s)" in
    Darwin)
        PLATFORM="macOS"
        PNPM_CONFIG_TARGET="$HOME/Library/Preferences/pnpm/rc"
        FONT_GLOB="$HOME/Library/Fonts/FiraCodeNerdFont*"
        CUSTOM_FONT="$HOME/Library/Fonts/FiraCodeNerdFontMonoBeard-Reg.ttf"
        ;;
    Linux)
        PLATFORM="Linux"
        PNPM_CONFIG_TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/pnpm/rc"
        FONT_GLOB="$HOME/.local/share/fonts/FiraCodeNerdFont*"
        CUSTOM_FONT="$HOME/.local/share/fonts/FiraCodeNerdFontMonoBeard-Reg.ttf"
        ;;
    *)
        PLATFORM="$(uname -s)"
        PNPM_CONFIG_TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/pnpm/rc"
        FONT_GLOB="$HOME/.local/share/fonts/FiraCodeNerdFont*"
        CUSTOM_FONT="$HOME/.local/share/fonts/FiraCodeNerdFontMonoBeard-Reg.ttf"
        ;;
esac

for arg in "$@"; do
    case "$arg" in
        --check)
            CHECK_MODE=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --symlink)
            INSTALL_MODE="symlink"
            ;;
        *)
            echo "Usage: $0 [--check] [--dry-run] [--symlink]"
            exit 1
            ;;
    esac
done

INSTALL_LOG="$CORTEX_CONFIG_HOME/install.log"
GHOSTTY_APPLY_LOG="$CORTEX_CONFIG_HOME/ghostty-apply.log"

if [[ "$CHECK_MODE" != true && "$DRY_RUN" != true ]]; then
    mkdir -p "$CORTEX_CONFIG_HOME"
    touch "$INSTALL_LOG"
    exec > >(tee -a "$INSTALL_LOG") 2>&1

    echo ""
    echo "===== cortex-dots install $(date -Is) ====="
    echo "log: $INSTALL_LOG"
    echo "repo: $DOTFILES"
    echo "platform: $PLATFORM"
    echo "mode: $INSTALL_MODE"
    echo "pid: $$"

    trap 'code=$?; echo "ERROR install failed at line $LINENO with exit $code"; echo "log: $INSTALL_LOG"; exit $code' ERR
fi

if [[ "$CHECK_MODE" == true ]]; then
    WARNINGS=0
    CRITICAL_FAILURES=0

    pass() {
        printf 'PASS %s\n' "$1"
    }

    warn() {
        printf 'WARN %s\n' "$1"
        WARNINGS=$((WARNINGS + 1))
    }

    fail() {
        printf 'FAIL %s\n' "$1"
        CRITICAL_FAILURES=$((CRITICAL_FAILURES + 1))
    }

    rel_path() {
        local path="$1"
        printf '%s\n' "${path#"$DOTFILES"/}"
    }

    check_command() {
        local command_name="$1"
        local severity="${2:-warn}"

        if command -v "$command_name" &>/dev/null; then
            pass "tool available: $command_name"
        elif [[ "$severity" == "fail" ]]; then
            fail "missing required tool: $command_name"
        else
            warn "missing optional tool: $command_name"
        fi
    }

    check_file() {
        local path="$1"
        if [[ -e "$path" ]]; then
            pass "repo file exists: $(rel_path "$path")"
        else
            fail "missing repo file: $(rel_path "$path")"
        fi
    }

    check_install_target() {
        local src="$1"
        local dst="$2"

        check_file "$src"

        if [[ -L "$dst" ]]; then
            local current
            current="$(readlink "$dst")"
            if [[ "$current" == "$src" ]]; then
                pass "target ok (symlink): $dst -> $src"
            else
                warn "symlink points elsewhere: $dst -> $current (expected $src)"
            fi
        elif [[ -e "$dst" ]]; then
            pass "target exists (copy install): $dst"
        else
            warn "dotfile target not installed yet: $dst"
        fi
    }

    check_json() {
        local path="$1"
        [[ -f "$path" ]] || return 0

        if command -v python3 &>/dev/null; then
            if python3 -m json.tool "$path" >/dev/null; then
                pass "JSON syntax ok: $(rel_path "$path")"
            else
                fail "JSON syntax invalid: $(rel_path "$path")"
            fi
        else
            warn "python3 unavailable; skipped JSON syntax: $(rel_path "$path")"
        fi
    }

    check_toml() {
        local path="$1"
        [[ -f "$path" ]] || return 0

        if command -v python3 &>/dev/null; then
            if python3 - "$path" <<'PY'
import sys
try:
    import tomllib
except ModuleNotFoundError:
    sys.exit(2)
with open(sys.argv[1], 'rb') as fh:
    tomllib.load(fh)
PY
            then
                pass "TOML syntax ok: $(rel_path "$path")"
            else
                local status=$?
                if [[ "$status" -eq 2 ]]; then
                    warn "python3 tomllib unavailable; skipped TOML syntax: $(rel_path "$path")"
                else
                    fail "TOML syntax invalid: $(rel_path "$path")"
                fi
            fi
        else
            warn "python3 unavailable; skipped TOML syntax: $(rel_path "$path")"
        fi
    }

    check_shell() {
        local path="$1"
        local shell_name="$2"
        [[ -f "$path" ]] || return 0

        if command -v "$shell_name" &>/dev/null; then
            if "$shell_name" -n "$path"; then
                pass "$shell_name syntax ok: $(rel_path "$path")"
            else
                fail "$shell_name syntax invalid: $(rel_path "$path")"
            fi
        else
            warn "$shell_name unavailable; skipped shell syntax: $(rel_path "$path")"
        fi
    }

    echo "dotfiles install check"
    echo "repo: $DOTFILES"
    echo ""

    case "$(uname -s)" in
        Darwin)
            pass "platform supported: macOS"
            check_command brew fail
            check_command zsh fail
            check_command bash fail
            check_command starship warn
            check_command eza warn
            check_command herdr warn
            check_command mosh warn
            check_command herdr warn
            check_command lazygit warn
            ;;
        Linux)
            pass "platform supported: Linux"
            check_command bash fail
            check_command zsh warn
            check_command python3 warn
            check_command curl warn
            check_command starship warn
            check_command herdr warn
            check_command mosh warn
            ;;
        *)
            warn "unsupported platform: $(uname -s)"
            check_command bash fail
            check_command zsh warn
            check_command python3 warn
            ;;
    esac

    echo ""
    echo "checking fonts"
    if [[ -f "$CUSTOM_FONT" ]]; then
        pass "optional custom font installed"
    elif compgen -G "$FONT_GLOB" >/dev/null; then
        pass "FiraCode Nerd Font Beard present"
    else
        warn "FiraCode Nerd Font Beard not found for $PLATFORM"
    fi

    echo ""
    echo "checking installed targets"
    check_install_target "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
    check_install_target "$DOTFILES/zsh/scripts" "$CORTEX_CONFIG_HOME/zsh/scripts"
    check_install_target "$DOTFILES/npm/npmrc" "$HOME/.npmrc"
    check_install_target "$DOTFILES/pnpm/rc" "$PNPM_CONFIG_TARGET"
    check_install_target "$DOTFILES/bun/bunfig.toml" "$HOME/.bunfig.toml"
    check_install_target "$DOTFILES/uv/uv.toml" "$HOME/.config/uv/uv.toml"
    check_install_target "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
    check_install_target "$DOTFILES/herdr/config.toml" "$HOME/.config/herdr/config.toml"
    check_install_target "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
    check_install_target "$DOTFILES/ghostty/shaders" "$HOME/.config/ghostty/shaders"
    check_install_target "$DOTFILES/opencode/tui.json" "$HOME/.config/opencode/tui.json"
    check_install_target "$DOTFILES/opencode/themes" "$HOME/.config/opencode/themes"
    check_install_target "$DOTFILES/claude/statusline.sh" "$HOME/.claude/statusline.sh"
    check_install_target "$DOTFILES/claude/themes" "$HOME/.claude/themes"
    check_install_target "$DOTFILES/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"

    echo ""
    echo "checking syntax"
    check_shell "$DOTFILES/install.sh" bash
    check_shell "$DOTFILES/claude/statusline.sh" bash
    check_shell "$DOTFILES/zsh/zshrc" zsh
    for path in "$DOTFILES"/zsh/scripts/*.zsh; do
        check_shell "$path" zsh
    done
    for path in "$DOTFILES"/opencode/*.json "$DOTFILES"/opencode/**/*.json "$DOTFILES"/claude/themes/*.json; do
        check_json "$path"
    done
    check_toml "$DOTFILES/starship/starship.toml"
    check_toml "$DOTFILES/bun/bunfig.toml"
    check_toml "$DOTFILES/uv/uv.toml"
    for path in "$DOTFILES"/herdr/*.toml "$DOTFILES"/herdr/**/*.toml; do
        check_toml "$path"
    done

    echo ""
    if [[ "$CRITICAL_FAILURES" -gt 0 ]]; then
        echo "FAIL check completed with $CRITICAL_FAILURES critical failure(s) and $WARNINGS warning(s)"
        exit 1
    fi

    echo "PASS check completed with $WARNINGS warning(s)"
    exit 0
fi

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║      dotfiles — Instalador           ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "DRY RUN: no files, packages, services, install targets, chmods, or local config will be changed."
    echo ""
fi

echo "Install mode: $INSTALL_MODE"

GHOSTTY_LIVE_WARNING_SHOWN=false
GHOSTTY_DEFER_WORKER_STARTED=false

ghostty_is_running() {
    ps -eo comm=,args= | awk '$1 == "ghostty" || $2 == "ghostty" || $2 ~ /\/ghostty$/ { found = 1 } END { exit found ? 0 : 1 }'
}

write_ghostty_apply_worker() {
    local worker="$CORTEX_CONFIG_HOME/apply-pending-ghostty.sh"
    if [[ "$DRY_RUN" == true ]]; then
        echo "  → Would create deferred Ghostty applier: $worker"
        return
    fi

    mkdir -p "$CORTEX_CONFIG_HOME"
    cat > "$worker" <<EOF
#!/bin/sh
set -eu

CONFIG_HOME="$CORTEX_CONFIG_HOME"
PENDING_DIR="$PENDING_GHOSTTY_DIR"
TARGET_DIR="$HOME/.config/ghostty"
LOG_FILE="$GHOSTTY_APPLY_LOG"
STAMP="\$(date +%Y%m%d_%H%M%S).\$\$"

mkdir -p "\$(dirname "\$LOG_FILE")"
echo "===== ghostty deferred apply \$(date -Is) =====" >> "\$LOG_FILE"
echo "pending: \$PENDING_DIR" >> "\$LOG_FILE"
echo "target: \$TARGET_DIR" >> "\$LOG_FILE"

ghostty_running() {
    ps -eo comm=,args= | awk '\$1 == "ghostty" || \$2 == "ghostty" || \$2 ~ /\\/ghostty\$/ { found = 1 } END { exit found ? 0 : 1 }'
}

wait_seconds=0
echo "waiting for Ghostty to exit..." >> "\$LOG_FILE"
while ghostty_running; do
    sleep 1
    wait_seconds=\$((wait_seconds + 1))
    if [ \$((wait_seconds % 30)) -eq 0 ]; then
        echo "still waiting for Ghostty to exit (\${wait_seconds}s)..." >> "\$LOG_FILE"
    fi
done

echo "Ghostty exited after \${wait_seconds}s; applying pending config" >> "\$LOG_FILE"

mkdir -p "\$TARGET_DIR"

if [ -f "\$PENDING_DIR/config" ]; then
    tmp="\$TARGET_DIR/.tmp.config.\$STAMP"
    cp "\$PENDING_DIR/config" "\$tmp"
    mv -f "\$tmp" "\$TARGET_DIR/config"
    mv "\$PENDING_DIR/config" "\$PENDING_DIR/config.applied_\$STAMP"
    echo "applied config" >> "\$LOG_FILE"
fi

if [ -d "\$PENDING_DIR/shaders" ]; then
    tmp="\$TARGET_DIR/shaders.tmp.\$STAMP"
    previous="\$TARGET_DIR/shaders.previous_\$STAMP"
    cp -R "\$PENDING_DIR/shaders" "\$tmp"
    if [ -e "\$TARGET_DIR/shaders" ] || [ -L "\$TARGET_DIR/shaders" ]; then
        mv "\$TARGET_DIR/shaders" "\$previous"
    fi
    mv "\$tmp" "\$TARGET_DIR/shaders"
    mv "\$PENDING_DIR/shaders" "\$PENDING_DIR/shaders.applied_\$STAMP"
    echo "applied shaders" >> "\$LOG_FILE"
fi

echo "done" >> "\$LOG_FILE"
EOF
    chmod +x "$worker"
}

start_ghostty_apply_worker() {
    if [[ "$GHOSTTY_DEFER_WORKER_STARTED" == true ]]; then
        return
    fi

    write_ghostty_apply_worker
    if [[ "$DRY_RUN" == true ]]; then
        echo "  → Would launch deferred Ghostty applier after Ghostty exits"
    else
        nohup "$CORTEX_CONFIG_HOME/apply-pending-ghostty.sh" >>"$GHOSTTY_APPLY_LOG" 2>&1 &
        echo "  → Ghostty config pendiente: se aplicará automáticamente cuando Ghostty se cierre"
        echo "  → Log deferred Ghostty: $GHOSTTY_APPLY_LOG"
    fi
    GHOSTTY_DEFER_WORKER_STARTED=true
}

defer_ghostty_target() {
    local src="$1"
    local dst="$2"
    local pending_name
    pending_name="$(basename "$dst")"

    if [[ "$DRY_RUN" == true ]]; then
        echo "  → Would stage pending Ghostty $pending_name from $src"
        start_ghostty_apply_worker
        return
    fi

    mkdir -p "$PENDING_GHOSTTY_DIR"
    if [[ -d "$src" ]]; then
        local tmp="$PENDING_GHOSTTY_DIR/${pending_name}.tmp.$$"
        if [[ -e "$tmp" || -L "$tmp" ]]; then
            mv "$tmp" "${tmp}.stale_${TIMESTAMP}.$$"
        fi
        cp -R "$src" "$tmp"
        if [[ -e "$PENDING_GHOSTTY_DIR/$pending_name" || -L "$PENDING_GHOSTTY_DIR/$pending_name" ]]; then
            mv "$PENDING_GHOSTTY_DIR/$pending_name" "$PENDING_GHOSTTY_DIR/${pending_name}.previous_${TIMESTAMP}.$$"
        fi
        mv "$tmp" "$PENDING_GHOSTTY_DIR/$pending_name"
    else
        local tmp="$PENDING_GHOSTTY_DIR/.tmp.${pending_name}.$$"
        cp "$src" "$tmp"
        mv -f "$tmp" "$PENDING_GHOSTTY_DIR/$pending_name"
    fi

    start_ghostty_apply_worker
}

run_or_plan() {
    local message="$1"
    shift

    if [[ "$DRY_RUN" == true ]]; then
        echo "  → Would $message"
    else
        "$@"
    fi
}

install_formula_if_missing() {
    local command_name="$1"
    local formula="$2"
    local description="$3"
    local tap="${4:-}"

    if ! command -v "$command_name" &>/dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            if command -v brew &>/dev/null; then
                echo "  → Would install $formula ($description) via Homebrew"
            else
                echo "  → Would skip automatic install for $formula ($description); install with your $PLATFORM package manager"
            fi
        elif command -v brew &>/dev/null; then
            echo "  → Instalando $formula ($description)..."
            [[ -z "$tap" ]] || brew tap "$tap"
            brew install "$formula"
        else
            echo "  ⚠️  $command_name no está instalado; instalalo con el package manager de $PLATFORM"
        fi
    else
        echo "  ✓ $command_name ya instalado"
    fi
}

install_starship_if_missing() {
    if command -v starship &>/dev/null; then
        echo "  ✓ starship ya instalado"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "  → Would ask to install starship to $HOME/.local/bin via official installer"
        return
    fi

    if ! command -v curl &>/dev/null; then
        echo "  ⚠️  starship no está instalado y curl no está disponible; instalá curl y re-ejecutá install.sh"
        return
    fi

    if [[ ! -t 0 ]]; then
        echo "  ⚠️  starship no está instalado; se omite prompt porque stdin no es interactivo"
        return
    fi

    echo ""
    read -p "  ¿Instalar Starship en $HOME/.local/bin? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "  - Starship no instalado; el prompt usará zsh default"
        return
    fi

    echo "  → Instalando starship en $HOME/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin" -y
}

# --- Verificar dependencias base ---
if [[ "$PLATFORM" == "macOS" ]] && ! command -v brew &>/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "  → Would require Homebrew before installing packages on macOS"
    else
        echo "❌ Homebrew no está instalado. Instalá desde https://brew.sh"
        exit 1
    fi
fi

install_starship_if_missing

# --- Instalar herramientas opcionales ---
echo "📦 Verificando herramientas..."

install_formula_if_missing eza eza "ls mejorado"
install_formula_if_missing herdr herdr "multiplexor remoto persistente"
install_formula_if_missing mosh mosh "SSH resiliente para workstations remotas"
install_formula_if_missing lazygit lazygit "git TUI"

# --- Fuentes ---
echo ""
echo "📦 Verificando fuentes..."

if [[ -f "$DOTFILES/fonts/FiraCodeNerdFontMonoBeard-Reg.ttf" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "  → Would create $(dirname "$CUSTOM_FONT")"
        echo "  → Would install bundled FiraCode Nerd Font Mono Beard to $CUSTOM_FONT"
    else
        mkdir -p "$(dirname "$CUSTOM_FONT")"
        cp "$DOTFILES/fonts/FiraCodeNerdFontMonoBeard-Reg.ttf" "$CUSTOM_FONT"
        if [[ "$PLATFORM" == "Linux" ]] && command -v fc-cache &>/dev/null; then
            fc-cache -f "$(dirname "$CUSTOM_FONT")" >/dev/null 2>&1 || true
        fi
        echo "  ✓ FiraCode Nerd Font Mono Beard instalada"
    fi
elif ! compgen -G "$FONT_GLOB" >/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "  → Would install FiraCode Nerd Font Beard for $PLATFORM when package manager is available"
    elif [[ "$PLATFORM" == "macOS" ]] && command -v brew &>/dev/null; then
        echo "  → Instalando FiraCode Nerd Font..."
        brew install --cask font-fira-code-nerd-font
        echo "  ✓ FiraCode Nerd Font instalada"
    else
        echo "  ⚠️  FiraCode Nerd Font Beard no encontrada; instalala manualmente en $CUSTOM_FONT"
    fi
else
    echo "  ✓ FiraCode Nerd Font Beard ya instalada"
fi

# --- Backup de configs existentes ---
echo ""
echo "💾 Haciendo backup de configs existentes..."

backup_if_exists() {
    local src="$1"
    if [[ -e "$src" && ! -L "$src" ]]; then
        local backup="${src}.bak_${TIMESTAMP}.$$"
        if [[ "$DRY_RUN" == true ]]; then
            echo "  → Would backup $src to $backup"
        elif [[ -d "$src" ]]; then
            cp -R "$src" "$backup"
            echo "  → Backup: $backup"
        else
            cp "$src" "$backup"
            echo "  → Backup: $backup"
        fi
    fi
}

backup_if_exists "$HOME/.zshrc"
backup_if_exists "$CORTEX_CONFIG_HOME/zsh/scripts"
backup_if_exists "$HOME/.npmrc"
backup_if_exists "$PNPM_CONFIG_TARGET"
backup_if_exists "$HOME/.bunfig.toml"
backup_if_exists "$HOME/.config/uv/uv.toml"
backup_if_exists "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.config/herdr/config.toml"
backup_if_exists "$HOME/.config/ghostty/config"
backup_if_exists "$HOME/.config/herdr/config.toml"
backup_if_exists "$HOME/.config/opencode/tui.json"
backup_if_exists "$HOME/.config/opencode/themes"
backup_if_exists "$HOME/.claude/statusline.sh"
backup_if_exists "$HOME/.claude/themes"
backup_if_exists "$HOME/.config/lazygit/config.yml"

# --- Instalar configs ---
echo ""
echo "🔗 Instalando configs ($INSTALL_MODE)..."

install_target() {
    local src="$1"
    local dst="$2"
    local tmp="${dst}.tmp.$$"
    local replaced="${dst}.previous_${TIMESTAMP}.$$"

    if [[ "$DRY_RUN" == true ]]; then
        if [[ "$INSTALL_MODE" == "symlink" ]]; then
            echo "  → Would symlink $dst → $src"
        else
            echo "  → Would atomically copy $src → $dst"
        fi
        if [[ "$dst" == "$HOME/.config/ghostty/"* ]] && ghostty_is_running; then
            echo "  ⚠️  Ghostty está corriendo; se dejaría $dst pendiente y se aplicaría automáticamente al cerrar Ghostty"
            defer_ghostty_target "$src" "$dst"
        fi
    elif [[ "$INSTALL_MODE" == "symlink" ]]; then
        if [[ "$dst" == "$HOME/.config/ghostty/"* ]] && ghostty_is_running; then
            echo "  ⚠️  Ghostty está corriendo; dejando $dst pendiente para evitar reload/crash"
            defer_ghostty_target "$src" "$dst"
            return
        fi
        mkdir -p "$(dirname "$dst")"
        # -n evita que ln dereferencie un symlink-a-directorio existente y cree
        # un link adentro (caso ghostty/shaders → loop shaders/shaders)
        ln -sfn "$src" "$dst"
        echo "  ✓ $dst → $src"
    else
        mkdir -p "$(dirname "$dst")"

        if [[ "$dst" == "$HOME/.config/ghostty/"* ]] && ghostty_is_running; then
            if [[ "$GHOSTTY_LIVE_WARNING_SHOWN" == false ]]; then
                echo "  ⚠️  Ghostty está corriendo; dejando configs pendientes para evitar reload/crash"
                GHOSTTY_LIVE_WARNING_SHOWN=true
            fi
            defer_ghostty_target "$src" "$dst"
            return
        fi

        if [[ "$dst" == "$HOME/.config/ghostty/"* ]] && [[ "$GHOSTTY_LIVE_WARNING_SHOWN" == false ]]; then
            echo "  → Ghostty no está corriendo; instalando config con reemplazo atómico"
            GHOSTTY_LIVE_WARNING_SHOWN=true
        fi

        if [[ -e "$tmp" || -L "$tmp" ]]; then
            mv "$tmp" "${tmp}.stale_${TIMESTAMP}"
        fi
        if [[ -d "$src" ]]; then
            cp -R "$src" "$tmp"
            if [[ -e "$dst" || -L "$dst" ]]; then
                mv "$dst" "$replaced"
            fi
            mv "$tmp" "$dst"
        else
            cp "$src" "$tmp"
            mv -f "$tmp" "$dst"
        fi
        echo "  ✓ $dst ← $src"
    fi
}

install_target "$DOTFILES/zsh/zshrc"              "$HOME/.zshrc"
install_target "$DOTFILES/zsh/scripts"            "$CORTEX_CONFIG_HOME/zsh/scripts"
install_target "$DOTFILES/npm/npmrc"              "$HOME/.npmrc"
install_target "$DOTFILES/pnpm/rc"                "$PNPM_CONFIG_TARGET"
install_target "$DOTFILES/bun/bunfig.toml"        "$HOME/.bunfig.toml"
install_target "$DOTFILES/uv/uv.toml"             "$HOME/.config/uv/uv.toml"
install_target "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
install_target "$DOTFILES/herdr/config.toml"      "$HOME/.config/herdr/config.toml"
install_target "$DOTFILES/ghostty/config"         "$HOME/.config/ghostty/config"
install_target "$DOTFILES/ghostty/shaders"        "$HOME/.config/ghostty/shaders"
install_target "$DOTFILES/opencode/tui.json"      "$HOME/.config/opencode/tui.json"
install_target "$DOTFILES/opencode/themes"        "$HOME/.config/opencode/themes"
install_target "$DOTFILES/claude/statusline.sh"   "$HOME/.claude/statusline.sh"
run_or_plan "chmod +x $HOME/.claude/statusline.sh" chmod +x "$HOME/.claude/statusline.sh"
install_target "$DOTFILES/claude/themes"          "$HOME/.claude/themes"
install_target "$DOTFILES/lazygit/config.yml"     "$HOME/.config/lazygit/config.yml"

# --- AI CLI installation (optional) ---

install_ai_cli_if_requested() {
    local command_name="$1"
    local display_name="$2"
    local install_url="$3"

    if command -v "$command_name" &>/dev/null; then
        echo "  ✓ $display_name ya instalado"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "  → Would ask to install $display_name from $install_url"
        return
    fi

    if [[ ! -t 0 ]]; then
        echo "  ⚠️  $display_name no está instalado; se omite prompt porque stdin no es interactivo"
        return
    fi

    echo ""
    read -p "  ¿Instalar $display_name? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "  → Instalando $display_name..."
        curl -fsSL "$install_url" | bash
    fi
}

install_ai_cli_if_requested claude "Claude Code" "https://claude.ai/install.sh"
install_ai_cli_if_requested opencode "OpenCode" "https://opencode.ai/install"

# --- Configuración local ---
echo ""
if [[ ! -f "$CORTEX_CONFIG_HOME/local/env.zsh" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "📝 Would create $CORTEX_CONFIG_HOME/local"
        echo "📝 Would create $CORTEX_CONFIG_HOME/local/env.zsh from local/env.zsh.example"
    else
        mkdir -p "$CORTEX_CONFIG_HOME/local"
        cp "$DOTFILES/local/env.zsh.example" "$CORTEX_CONFIG_HOME/local/env.zsh"
        echo "📝 Creado $CORTEX_CONFIG_HOME/local/env.zsh desde el ejemplo — editalo con tus paths"
    fi
else
    echo "✓ $CORTEX_CONFIG_HOME/local/env.zsh ya existe"
fi

# --- Verificación final ---
echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo "✅ Dry run completado; no se aplicaron cambios."
else
    echo "✅ Instalación completada!"
    echo "   Log: $INSTALL_LOG"
fi
echo ""
echo "  Próximos pasos:"
echo "  1. Abrí una nueva tab en Ghostty para cargar el nuevo profile"
echo "  2. Editá $CORTEX_CONFIG_HOME/local/env.zsh con tus paths personales"
echo "  3. Ghostty usa FiraCode Nerd Font Mono Beard; instalá esa fuente si Ghostty no la detecta"
echo ""
echo "  Para medir el load time:"
echo "  \$ time zsh -i -c exit"
echo ""
