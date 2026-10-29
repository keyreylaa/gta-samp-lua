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

# Universal location supported by OpenCode, Claude Code, Codex, Pi, Gemini CLI.
DEST="$TARGET_DIR/.agents/skills/$SKILL_NAME"

echo "Installing $SKILL_NAME to $DEST ..."
rm -rf "$DEST"
mkdir -p "$(dirname "$DEST")"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if command -v git >/dev/null 2>&1 && git clone --depth 1 -b "$BRANCH" "https://github.com/$REPO.git" "$TMP/$SKILL_NAME" >/dev/null 2>&1; then
    rm -rf "$TMP/$SKILL_NAME/.git"
else
    curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$TMP"
    mv "$TMP/$SKILL_NAME-$BRANCH" "$TMP/$SKILL_NAME"
fi

cp -r "$TMP/$SKILL_NAME" "$DEST"
# Remove git metadata if present
rm -rf "$DEST/.git"

# Cursor convenience: append a pointer to AGENTS.md at project root if not present.
if [[ $GLOBAL -eq 0 ]]; then
    AGENTS="$TARGET_DIR/AGENTS.md"
    if [[ ! -f "$AGENTS" ]] || ! grep -q "gta-samp-lua" "$AGENTS" 2>/dev/null; then
        printf '\n## GTA SA-MP Lua\nFor GTA SA-MP Lua work, read `%s/SKILL.md` and its `references/`.\n' ".agents/skills/$SKILL_NAME" >> "$AGENTS"
        echo "Appended pointer to $AGENTS (for Cursor)."
    fi
fi

echo "Done. Skill installed at: $DEST"
echo "Claude Code also reads .claude/skills; symlink if needed:"
echo "  ln -sfn .agents/skills/$SKILL_NAME .claude/skills/$SKILL_NAME"
