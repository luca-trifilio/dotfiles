#!/usr/bin/env bash
# Global PostToolUse hook (registered in ~/.claude/settings.json, fires for
# every session/project on this machine): after Claude Code writes/edits a
# markdown file inside the Obsidian vault specifically, run it through
# Prettier so blank-line/heading formatting matches what Neovim's
# conform.nvim + prettier already enforce on save. Scoped to the vault path
# so this never touches markdown in other projects/repos.
#
# Prefers a PATH-installed prettier; falls back to the Mason-managed binary
# from the Neovim setup (present on both personal and work Macs).
set -uo pipefail

VAULT_DIR="$HOME/Documents/Taccuino Cerusico"
MASON_PRETTIER="$HOME/.local/share/nvim/mason/bin/prettier"

command -v jq >/dev/null 2>&1 || exit 0

file_path=$(jq -r '.tool_input.file_path // empty')
[ -n "$file_path" ] || exit 0
[[ "$file_path" == "$VAULT_DIR"/* ]] || exit 0
[[ "$file_path" == *.md ]] || exit 0
[ -f "$file_path" ] || exit 0

if command -v prettier >/dev/null 2>&1; then
  PRETTIER="prettier"
elif [ -x "$MASON_PRETTIER" ]; then
  PRETTIER="$MASON_PRETTIER"
else
  exit 0
fi

"$PRETTIER" --write "$file_path" >/dev/null 2>&1 || true
