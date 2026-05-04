---
name: delta-catppuccin-setup
description: Use when configuring delta with Catppuccin Macchiato theme in dotfiles, or when adding/updating the catppuccin.gitconfig include.
---

# Delta Catppuccin Setup

## File structure

- `git/catppuccin.gitconfig` — stowato in `~/.config/git/catppuccin.gitconfig` via `stow .`
- `gitconfig/.gitconfig` — contiene `[include]` e `[delta] features`

## Installazione

1. Scaricare il file ufficiale catppuccin/delta:
```bash
gh api repos/catppuccin/delta/contents/catppuccin.gitconfig --jq '.content' | base64 -d > dotfiles/git/catppuccin.gitconfig
```

2. Stowarlo tramite package XDG (`stow .` copre già la dir `git/`):
```bash
stow .
# → ~/.config/git/catppuccin.gitconfig
```

3. Nel `gitconfig/.gitconfig`:
```gitconfig
[include]
    path = ~/.config/git/catppuccin.gitconfig

[delta]
    features = catppuccin-macchiato
```

## Prerequisiti

- `git-delta` e `bat` nel `Brewfile` (già presenti)
- Tema bat "Catppuccin Macchiato" in `bat/config` (prerequisito ufficiale catppuccin/delta)

## Flag delta da ricordare

- **Non esiste `--no-side-by-side`** — il side-by-side si disabilita non passando `-s`/`--side-by-side`
- **Non esiste `--side-by-side=false`** — sintassi non supportata
- `--no-gitconfig` — azzera tutto il gitconfig (utile per override in contesti specifici)
- `--syntax-theme` non serve se si usa il metodo `features` (è già incluso nel feature block)

## FZF_GIT_PAGER

Per le preview di fzf-git (pannello troppo stretto per side-by-side), in `zsh/fzf.zsh`:
```zsh
export FZF_GIT_PAGER="delta --no-gitconfig --line-numbers --dark --syntax-theme 'Catppuccin Macchiato'"
```

Perché `--no-gitconfig`: azzera side-by-side che altrimenti verrebbe letto dal gitconfig.
Perché `--syntax-theme` esplicito: con `--no-gitconfig` il feature block non viene caricato.
