---
name: dotfiles-docs-update
description: Use when the user asks to "update docs", "sync docs", "aggiorna la doc", or after making changes to dotfiles configs. Updates the Obsidian vault docs in ~/Documents/Taccuino Cerusico/60 - Progetti/dotfiles/ to reflect the current state of the repo.
---

## Purpose

Keep `docs/` in sync with the actual dotfiles state. Docs live in the Obsidian vault; `dotfiles/docs/` contains symlinks to them. Edit the vault files directly.

## File mapping

| Changed path | Doc to update |
|---|---|
| `aerospace/` | `docs/aerospace.md` |
| `atuin/` | `docs/atuin.md` |
| `brew/Brewfile` | `docs/brew.md` |
| `zsh/fzf.zsh`, `bat/`, `fzf-git.sh/` | `docs/fzf.md` |
| `gitconfig/`, `git/` | `docs/git.md` |
| `nvim/` | `docs/nvim.md` |
| `tmux/` | `docs/tmux.md` |
| `yazi/` | `docs/yazi.md` |
| `zsh/` (excluding fzf.zsh) | `docs/zsh.md` |
| `setup.sh`, `.stowrc`, `CLAUDE.md` | `docs/index.md` |

## Workflow

1. Run `git diff HEAD~1 --name-only` (or `git diff --name-only` for uncommitted) to identify changed files
2. Map changed paths to the relevant docs using the table above
3. For each doc to update, resolve the real path: `readlink dotfiles/docs/<tool>.md`
4. Read the current config files for each affected tool
5. Read and edit the **resolved vault path** — never edit through the `docs/` symlink directly (the Edit tool refuses symlinks)
6. Update only the sections that changed — preserve wikilinks, add new ones where relevant
7. Never remove wikilinks unless the referenced tool was actually removed

## Doc file paths

`dotfiles/docs/<tool>.md` are symlinks into the Obsidian vault. Always resolve with `readlink` before editing.

## Style rules

- No frontmatter tags
- Wikilinks: use `[[dotfiles - tool|label]]` for cross-references between dotfiles docs
- Wikilinks: use `[[Tool]]` for external tools (Obsidian, Catppuccin, Neovim, etc.)
- Config blocks: show actual current values, not placeholders
- Keep it agent-readable: paths, gotchas, current state — not generic docs

## Adding a new tool

1. Create `~/Documents/Taccuino Cerusico/60 - Progetti/dotfiles/dotfiles - <tool>.md`
2. Add symlink: `ln -sf "$VAULT/dotfiles - <tool>.md" dotfiles/docs/<tool>.md`
3. Add entry to `docs/index.md` wikilink list
4. Add row to the mapping table in this skill
5. Add mapping to `setup.sh` docs section
