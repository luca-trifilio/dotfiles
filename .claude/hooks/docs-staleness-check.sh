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

declare -A hits   # doc -> 1

while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    aerospace/*)                    hits[aerospace]=1 ;;
    atuin/*)                        hits[atuin]=1 ;;
    brew/Brewfile)                  hits[brew]=1 ;;
    zsh/fzf.zsh|bat/*|fzf-git.sh/*) hits[fzf]=1 ;;
    gitconfig/*|git/*)              hits[git]=1 ;;
    nvim/*)                         hits[nvim]=1 ;;
    tmux/*)                         hits[tmux]=1 ;;
    yazi/*)                         hits[yazi]=1 ;;
    setup.sh|.stowrc|CLAUDE.md)     hits[index]=1 ;;
    zsh/*)                          hits[zsh]=1 ;;   # after fzf.zsh so it doesn't shadow
  esac
done <<< "$changed"

[ ${#hits[@]} -eq 0 ] && exit 0

docs="$(printf '%s ' "${!hits[@]}")"
printf '{"systemMessage": "📝 Config modificati senza aggiornare la doc: %s. Lancia /dotfiles-docs-update per riallineare il vault Obsidian."}\n' "${docs% }"
