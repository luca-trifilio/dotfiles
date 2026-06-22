#!/usr/bin/env bash
# Stop hook: warns when the last commit changed dotfiles configs whose matching
# Obsidian-vault doc likely needs updating. Emits a systemMessage suggesting
# /dotfiles-docs-update. Never blocks — informational only.
#
# The vault docs are gitignored (live in Obsidian), so the signal is purely
# "the last commit touched config X" — there is no doc change to diff against.
# Mapping mirrors .claude/skills/dotfiles-docs-update/SKILL.md.
set -euo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

# Files changed in the last commit, excluding docs/ itself.
changed="$(git show --name-only --pretty=format: HEAD 2>/dev/null | grep -v '^docs/' | grep -v '^$' || true)"
[ -z "$changed" ] && exit 0

# Space-delimited dedup set of docs to update (no associative arrays — macOS
# ships bash 3.2, where `declare -A` + empty-expansion under `set -u` breaks).
hits=" "
add() { case "$hits" in *" $1 "*) ;; *) hits="$hits$1 " ;; esac; }

while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    aerospace/*)                    add aerospace ;;
    ansible/*)                      add ansible ;;
    atuin/*)                        add atuin ;;
    brew/Brewfile)                  add brew ;;
    zsh/fzf.zsh|bat/*|fzf-git.sh/*) add fzf ;;
    gitconfig/*|git/*)              add git ;;
    nvim/*)                         add nvim ;;
    tmux/*)                         add tmux ;;
    yazi/*)                         add yazi ;;
    setup.sh|.stowrc|CLAUDE.md)     add index ;;
    zsh/*)                          add zsh ;;   # after fzf.zsh so it doesn't shadow
  esac
done <<< "$changed"

docs="$(echo "$hits" | xargs)"   # trim
[ -z "$docs" ] && exit 0

printf '{"systemMessage": "📝 Config modificati senza aggiornare la doc: %s. Lancia /dotfiles-docs-update per riallineare il vault Obsidian."}\n' "$docs"
