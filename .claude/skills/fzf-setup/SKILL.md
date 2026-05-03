---
name: fzf-setup
description: Use when configuring fzf in dotfiles — setting up fd integration, bat/eza previews, fzf-git, Catppuccin Macchiato theme, and fixing vi mode keybinding conflicts.
---

# fzf Setup in Dotfiles

## File structure

- `zsh/fzf.zsh` — all fzf config, sourced last in `.zshrc`
- `bootstrap.sh` — clone fzf-git.sh to `~/fzf-git.sh/`

## fzf.zsh structure

1. `eval "$(fzf --zsh)"` — init
2. `[ -f "$HOME/fzf-git.sh/fzf-git.sh" ] && source ...` — fzf-git
3. Catppuccin Macchiato color vars → `FZF_DEFAULT_OPTS`
4. fd-based commands (`FZF_DEFAULT_COMMAND`, `FZF_CTRL_T_COMMAND`, `FZF_ALT_C_COMMAND`)
5. `_fzf_compgen_path` / `_fzf_compgen_dir` using fd
6. Preview var with `bat` (files) + `eza --tree` (dirs)
7. `_fzf_comprun` for context-aware previews (cd, export, ssh)

## Critical gotchas

### vi mode conflict
`^G list-expand` in `viins` blocks fzf-git chords (`Ctrl+G`+`f`, etc.).
Fix in `vimode.zsh` after `zle -N` calls:
```zsh
bindkey -M viins -r '^G'
bindkey -M emacs -r '^G'
```

### fzf-git bootstrap
Add to `bootstrap.sh` (same pattern as OMZ plugins):
```bash
status "fzf-git"
if [ -d "$HOME/fzf-git.sh" ]; then
  echo "  already installed"
else
  run git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/fzf-git.sh"
fi
```

Source in `fzf.zsh` with guard:
```zsh
[ -f "$HOME/fzf-git.sh/fzf-git.sh" ] && source "$HOME/fzf-git.sh/fzf-git.sh"
```

### Kitty Option key
Use `macos_option_as_alt left` (not `yes`) — left Option sends Alt for fzf bindings, right Option preserves macOS accents (ç, è, etc.).

### KEYTIMEOUT
`KEYTIMEOUT=1` (10ms) works fine once `^G list-expand` is unbound — the chord conflict was the real issue, not the timeout.

## bat config
`dotfiles/bat/config` (XDG, stowed to `~/.config/bat/config`):
```
--theme="Catppuccin Macchiato"
```
Prefer config file over `BAT_THEME` env var — cleaner and consistent with XDG approach.

## fzf-git keybindings
- `Ctrl+G` then `f` — files
- `Ctrl+G` then `b` — branches
- `Ctrl+G` then `h` — commit hashes
- `Ctrl+G` then `s` — stashes
- `Ctrl+G` then `?` — show all bindings

Must be inside a git repo for bindings to show results.
