# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed with **GNU Stow**. Each app has a package directory whose contents are symlinked into `~` via `stow <package>`.

## Stow Mechanics

`.stowrc` sets `--target=~`. Files inside a package must mirror the path relative to `~`:

- `zshrc/.zshrc` → `~/.zshrc`
- `nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`

## Repo Location

`~/Progetti/dotfiles`

## Adding a New Package

```zsh
mkdir -p <package>/<path-relative-to-home>/
mv ~/<path> <package>/<path-relative-to-home>/
stow <package>
git add <package> && git commit -m "add <package>"
```

## Other Stow Commands

```zsh
stow -D <package>    # remove symlinks (unstow)
stow -R <package>    # restow (remove + re-apply)
stow -nv <package>   # dry-run, shows what would happen
```

## Applying Changes on a New Machine

```zsh
./setup.sh   # runs: stow nvim ghostty zshrc tmux
```

## Current Packages

| Package | Target path |
|---|---|
| `zshrc` | `~/.zshrc`, `~/.p10k.zsh` |
| `nvim` | `~/.config/nvim/` (LazyVim) |
| `ghostty` | `~/.config/ghostty/` |
| `tmux` | `~/.config/tmux/tmux.conf` |
