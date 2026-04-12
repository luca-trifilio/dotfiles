# CLAUDE.md

Personal dotfiles at `~/Progetti/dotfiles`, managed with **GNU Stow**.

## How stow works here

`.stowrc` sets `--target=~/.config`. Running `stow .` from inside the repo treats the repo as a single package: stow maps each top-level directory into `~/.config/` via directory symlinks (tree folding).

```
dotfiles/nvim/    → ~/.config/nvim    (symlink)
dotfiles/ghostty/ → ~/.config/ghostty (symlink)
dotfiles/tmux/    → ~/.config/tmux    (symlink)
```

## zshrc exception

`zshrc/` contains `~`-relative files (`.zshrc`, `.p10k.zsh`) — they must go to `~/`, not `~/.config/`. Two things handle this:

1. `.stowrc` has `--ignore=^zshrc$` so `stow .` skips it
2. `setup.sh` runs a separate `stow --target="$HOME" zshrc`

When adding other home-target packages, follow the same pattern.

## tmux plugins

TPM and all plugins live at `~/.tmux/plugins/` — **outside** the stow-managed `~/.config/tmux/`. `tmux.conf` explicitly sets:

```
set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins/"
```

This prevents TPM from installing into `~/.config/tmux/plugins/` (which would leak into the repo via the stow symlink). `tmux/plugins/` is also gitignored as a safety net.

On a fresh machine, bootstrap TPM manually (see below).

## tmux alias

`.zshrc` has `alias t='tmux new-session -A -s main'` — attaches to the `main` session or creates it. Ghostty also auto-starts tmux via `command = /bin/zsh -c 'tmux new-session -A -s main'` in its config.

## Current packages

| Package | Target | Notes |
|---|---|---|
| `nvim` | `~/.config/nvim/` | LazyVim |
| `ghostty` | `~/.config/ghostty/` | auto-starts tmux on open |
| `tmux` | `~/.config/tmux/` | plugins at `~/.tmux/plugins/` |
| `zshrc` | `~/` | exception: separate stow call |
| `opencode` | `~/.config/opencode/` | |

## Adding a new XDG package

```zsh
mkdir ~/Progetti/dotfiles/<app>
mv ~/.config/<app> ~/Progetti/dotfiles/<app>   # or copy files manually
cd ~/Progetti/dotfiles && stow .
git add <app> && git commit -m "add <app>"
```

No changes to `.stowrc` or `setup.sh` needed — `stow .` picks it up automatically.

## Adding a home-target package

```zsh
mkdir ~/Progetti/dotfiles/<app>
mv ~/.<file> ~/Progetti/dotfiles/<app>/
# Add to .stowrc: --ignore=^<app>$
# Add to setup.sh: stow --target="$HOME" <app>
cd ~/Progetti/dotfiles && stow --target="$HOME" <app>
git add <app> .stowrc setup.sh && git commit -m "add <app>"
```

## Other stow commands

```zsh
stow -nv .           # dry-run, preview what would be linked
stow -D .            # remove all XDG symlinks
stow -R .            # restow (remove + re-apply)
```

## Fresh machine bootstrap

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
cd ~/Progetti/dotfiles && ./setup.sh
# Then install TPM for tmux:
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Inside tmux: prefix + I to install plugins
```
