#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
FAKE_GHOSTTY_PID=""
INSTALL_MODE="copy"
SEED_STALE_OPPOSITE=false

for arg in "$@"; do
    case "$arg" in
        --symlink)
            INSTALL_MODE="symlink"
            ;;
        --seed-stale-opposite)
            SEED_STALE_OPPOSITE=true
            ;;
        *)
            printf 'Usage: %s [--symlink] [--seed-stale-opposite]\n' "$0" >&2
            exit 1
            ;;
    esac
done

cleanup() {
    if [[ -n "$FAKE_GHOSTTY_PID" ]] && kill -0 "$FAKE_GHOSTTY_PID" 2>/dev/null; then
        kill "$FAKE_GHOSTTY_PID" 2>/dev/null || true
        wait "$FAKE_GHOSTTY_PID" 2>/dev/null || true
    fi
    rm -rf "$TMP_HOME"
}
trap cleanup EXIT

fail() {
    printf 'FAIL %s\n' "$*" >&2
    exit 1
}

assert_file() {
    [[ -f "$1" ]] || fail "expected file: $1"
}

assert_dir() {
    [[ -d "$1" ]] || fail "expected directory: $1"
}

assert_missing() {
    [[ ! -e "$1" ]] || fail "expected missing path: $1"
}

poll_for() {
    local path="$1"
    local attempts=30
    local i

    for ((i = 0; i < attempts; i++)); do
        if compgen -G "$path" >/dev/null; then
            return 0
        fi
        sleep 0.2
    done

    fail "timed out waiting for: $path"
}

export HOME="$TMP_HOME/home"
export XDG_CONFIG_HOME="$TMP_HOME/config"
export CORTEX_CONFIG_HOME="$XDG_CONFIG_HOME/cortex-dots"
mkdir -p "$HOME" "$XDG_CONFIG_HOME"
PENDING_DIR="$CORTEX_CONFIG_HOME/pending/ghostty"
GHOSTTY_DIR="$HOME/.config/ghostty"
FONT_TARGET="$HOME/.local/share/fonts/FiraCodeNerdFontMonoBeard-Reg.ttf"

install_args=()
if [[ "$INSTALL_MODE" == "symlink" ]]; then
    install_args+=(--symlink)
fi

if [[ "$SEED_STALE_OPPOSITE" == true ]]; then
    mkdir -p "$PENDING_DIR"
    if [[ "$INSTALL_MODE" == "symlink" ]]; then
        printf '%s\n' 'stale copy config' > "$PENDING_DIR/config"
        mkdir -p "$PENDING_DIR/shaders"
    else
        printf '%s\n' 'symlink' > "$PENDING_DIR/config.mode"
        printf '%s\n' '/tmp/stale-config' > "$PENDING_DIR/config.source"
        printf '%s\n' 'symlink' > "$PENDING_DIR/shaders.mode"
        printf '%s\n' '/tmp/stale-shaders' > "$PENDING_DIR/shaders.source"
    fi
fi

(exec -a ghostty sleep 60) &
FAKE_GHOSTTY_PID="$!"

bash "$ROOT_DIR/install.sh" "${install_args[@]}"

assert_file "$PENDING_DIR/FiraCodeNerdFontMonoBeard-Reg.ttf"
if [[ "$INSTALL_MODE" == "symlink" ]]; then
    assert_file "$PENDING_DIR/config.mode"
    assert_file "$PENDING_DIR/config.source"
    assert_file "$PENDING_DIR/shaders.mode"
    assert_file "$PENDING_DIR/shaders.source"
else
    assert_file "$PENDING_DIR/config"
    assert_dir "$PENDING_DIR/shaders"
fi
assert_missing "$FONT_TARGET"
assert_missing "$GHOSTTY_DIR/config"
assert_missing "$GHOSTTY_DIR/shaders"

kill "$FAKE_GHOSTTY_PID"
wait "$FAKE_GHOSTTY_PID" 2>/dev/null || true
FAKE_GHOSTTY_PID=""

poll_for "$PENDING_DIR/FiraCodeNerdFontMonoBeard-Reg.ttf.applied_*"
if [[ "$INSTALL_MODE" == "symlink" ]]; then
    poll_for "$PENDING_DIR/config.mode.applied_*"
    poll_for "$PENDING_DIR/shaders.mode.applied_*"
else
    poll_for "$PENDING_DIR/config.applied_*"
    poll_for "$PENDING_DIR/shaders.applied_*"
fi

assert_file "$FONT_TARGET"
assert_file "$GHOSTTY_DIR/config"
assert_dir "$GHOSTTY_DIR/shaders"

if [[ "$INSTALL_MODE" == "symlink" ]]; then
    [[ -L "$GHOSTTY_DIR/config" ]] || fail "expected symlink: $GHOSTTY_DIR/config"
    [[ -L "$GHOSTTY_DIR/shaders" ]] || fail "expected symlink: $GHOSTTY_DIR/shaders"
    assert_missing "$PENDING_DIR/config"
    assert_missing "$PENDING_DIR/shaders"
else
    [[ ! -L "$GHOSTTY_DIR/config" ]] || fail "expected copied file, got symlink: $GHOSTTY_DIR/config"
    [[ ! -L "$GHOSTTY_DIR/shaders" ]] || fail "expected copied directory, got symlink: $GHOSTTY_DIR/shaders"
    assert_missing "$PENDING_DIR/config.mode"
    assert_missing "$PENDING_DIR/shaders.mode"
fi

printf 'PASS install deferred Ghostty/font flow (%s)\n' "$INSTALL_MODE"
