---
name: fzf-setup
description: This skill should be used when the user asks to "configure fzf", "set up fzf-git", "fix fzf keybindings", "add fzf previews", or needs to set up fd integration, bat/eza previews, fzf-git submodule, Catppuccin theme, or fix vi mode chord conflicts.
---

# fzf Setup in Dotfiles

## File structure

- `zsh/fzf.zsh` — all fzf config, sourced last in `.zshrc`
- `fzf-git.sh/` — git submodule (junegunn/fzf-git.sh), stowed to `~/.config/fzf-git.sh/`
- `bootstrap.sh` — initializes submodule if not already checked out

## fzf.zsh structure

1. `eval "$(fzf --zsh)"` — init
2. `[ -f "$HOME/.config/fzf-git.sh/fzf-git.sh" ] && source ...` — fzf-git
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
fzf-git is a **git submodule** at `dotfiles/fzf-git.sh/`, stowed via `stow .` to `~/.config/fzf-git.sh/`.

`bootstrap.sh` initializes the submodule if empty:
```bash
status "fzf-git"
if [ -f "$DOTFILES_DIR/fzf-git.sh/fzf-git.sh" ]; then
  echo "  already installed"
else
  run git -C "$DOTFILES_DIR" submodule update --init fzf-git.sh
fi
```

Source in `fzf.zsh` with guard:
```zsh
[ -f "$HOME/.config/fzf-git.sh/fzf-git.sh" ] && source "$HOME/.config/fzf-git.sh/fzf-git.sh"
```

On a fresh machine: `git clone --recurse-submodules` populates the submodule; `stow .` creates the symlink.

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

## FZF_GIT_PAGER (delta preview)

fzf-git uses `FZF_GIT_PAGER` for diff previews. Without an override, delta inherits `side-by-side = true` from gitconfig — too wide for the preview panel.

In `zsh/fzf.zsh`:
```zsh
export FZF_GIT_PAGER="delta --no-gitconfig --line-numbers --dark --syntax-theme 'Catppuccin Macchiato'"
```

- `--no-gitconfig` disables side-by-side and all gitconfig options
- `--syntax-theme` must be re-passed explicitly because `--no-gitconfig` bypasses the feature block
- There is no `--no-side-by-side` or `--side-by-side=false` flag
