#!/usr/bin/env bash
# Auto-install gta-samp-lua skill for all supported agents.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/keyreylaa/gta-samp-lua/main/install.sh | bash
#   curl ... | bash -s -- --global
#   curl ... | bash -s -- --dir /path/to/project
set -euo pipefail

REPO="keyreylaa/gta-samp-lua"
BRANCH="main"
SKILL_NAME="gta-samp-lua"

GLOBAL=0
TARGET_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --global) GLOBAL=1; shift ;;
        --dir) TARGET_DIR="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

if [[ -z "$TARGET_DIR" ]]; then
    if [[ $GLOBAL -eq 1 ]]; then
        TARGET_DIR="$HOME"
    else
        TARGET_DIR="$(pwd)"
    fi
fi

# Fetch source into temp (git preferred, tarball fallback).
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
SRC="$TMP/$SKILL_NAME"
if command -v git >/dev/null 2>&1 && git clone --depth 1 -b "$BRANCH" "https://github.com/$REPO.git" "$SRC" >/dev/null 2>&1; then
    rm -rf "$SRC/.git"
else
    curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$TMP"
    mv "$TMP/$SKILL_NAME-$BRANCH" "$SRC"
fi

install_to() {
    local dest="$1"
    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    cp -r "$SRC" "$dest"
    echo "  -> $dest"
}

echo "Installing $SKILL_NAME ..."

if [[ $GLOBAL -eq 1 ]]; then
    # OpenCode primary global paths (these are what OpenCode v2 actually scans).
    install_to "$HOME/.config/opencode/skills/$SKILL_NAME"
    install_to "$HOME/.opencode/skills/$SKILL_NAME"
    # Cross-agent compatibility paths.
    install_to "$HOME/.agents/skills/$SKILL_NAME"
    install_to "$HOME/.claude/skills/$SKILL_NAME"
else
    # OpenCode primary project paths.
    install_to "$TARGET_DIR/.opencode/skills/$SKILL_NAME"
    # Cross-agent compatibility paths.
    install_to "$TARGET_DIR/.agents/skills/$SKILL_NAME"
    install_to "$TARGET_DIR/.claude/skills/$SKILL_NAME"
    # Cursor convenience.
    AGENTS="$TARGET_DIR/AGENTS.md"
    if [[ ! -f "$AGENTS" ]] || ! grep -q "gta-samp-lua" "$AGENTS" 2>/dev/null; then
        printf '\n## GTA SA-MP Lua\nFor GTA SA-MP Lua work, read `%s/SKILL.md` and its `references/`.\n' ".opencode/skills/$SKILL_NAME" >> "$AGENTS"
        echo "  -> appended pointer to $AGENTS (for Cursor)"
    fi
fi

echo "Done."
echo "OpenCode: use /skills or @gta-samp-lua to load it."
