---
name: dotfiles-manage
description: This skill should be used when the user asks to "manage dotfiles", "track config files", "add a file to dotfiles", "commit dotfiles", "set up dotfiles on a new machine", "bootstrap a new machine", or mentions dotfiles or stow. Provides guidance for day-to-day dotfiles management and new machine setup.
---

# Dotfiles Management

Dotfiles are tracked via a normal git repo at `~/Progetti/dotfiles`, managed with **GNU Stow**.

## Repo

| Property | Value |
|---|---|
| Local path | `~/Progetti/dotfiles` |
| Remote | `https://github.com/luca-trifilio/dotfiles.git` |
| Branch | `main` |

## How stow works

`.stowrc` sets `--target=~/.config`. Running `stow .` from inside the repo treats the **entire repo as a single package** — stow maps each top-level app directory into `~/.config/` as a directory symlink (tree folding).

```
dotfiles/nvim/    → ~/.config/nvim    (symlink)
dotfiles/ghostty/ → ~/.config/ghostty (symlink)
dotfiles/tmux/    → ~/.config/tmux    (symlink)
```

## zshrc exception

`zshrc/` targets `~/` not `~/.config/`. Two things handle this:
1. `.stowrc` has `--ignore=^zshrc$` — `stow .` skips it
2. `setup.sh` runs `stow --target="$HOME" zshrc` separately

## tmux plugins

TPM and plugins live at `~/.tmux/plugins/` — **outside** the stow-managed `~/.config/tmux/`. `tmux.conf` explicitly sets:

```
set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins/"
```

This prevents TPM from leaking plugins into `~/.config/tmux/plugins/` (which would land inside the repo via the stow symlink). `tmux/plugins/` is also gitignored as a safety net.

**Pitfall**: if plugins appear in `~/Progetti/dotfiles/tmux/plugins/`, do NOT delete that dir — it breaks Dracula's script paths. Instead, just ensure `TMUX_PLUGIN_MANAGER_PATH` is set and gitignore `tmux/plugins/`.

On a fresh machine: clone TPM manually (`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`), then run `prefix + I` inside tmux.

## tmux + Ghostty auto-start

Ghostty is configured to auto-start tmux via:
```
command = /bin/zsh -c 'tmux new-session -A -s main'
```

## Current packages

| Package | Target | Notes |
|---|---|---|
| `nvim` | `~/.config/nvim/` | LazyVim |
| `ghostty` | `~/.config/ghostty/` | auto-starts tmux on open |
| `tmux` | `~/.config/tmux/` | plugins at `~/.tmux/plugins/` |
| `zshrc` | `~/` | exception: separate stow call |
| `opencode` | `~/.config/opencode/` | config: `opencode.json`; plugin dir: `opencode/opencode/` |

## Day-to-Day Operations

```zsh
cd ~/Progetti/dotfiles
git add <file>
git commit -m "message"
git push
```

## Adding a new XDG package (→ ~/.config/)

```zsh
mkdir ~/Progetti/dotfiles/<app>
mv ~/.config/<app> ~/Progetti/dotfiles/<app>
cd ~/Progetti/dotfiles && stow .
git add <app> && git commit -m "add <app>"
```

No changes to `.stowrc` or `setup.sh` needed.

## Adding a home-target package (→ ~/)

```zsh
mkdir ~/Progetti/dotfiles/<app>
mv ~/.<file> ~/Progetti/dotfiles/<app>/
# Add to .stowrc:  --ignore=^<app>$
# Add to setup.sh: stow --target="$HOME" <app>
cd ~/Progetti/dotfiles && stow --target="$HOME" <app>
git add <app> .stowrc setup.sh && git commit -m "add <app>"
```

## Other stow commands

```zsh
stow -nv .   # dry-run
stow -D .    # remove XDG symlinks
stow -R .    # restow
```

## Files Safe to Add

| File | Package | Type |
|---|---|---|
| `~/.gitconfig` | `git` | home-target |
| `~/.config/gh/config.yml` | `gh` | XDG |
| `~/.config/opencode/opencode.json` | `opencode` | XDG |

## Files to NEVER Track

| File | Reason |
|---|---|
| `~/.ssh/` | Private keys |
| `~/.config/gh/hosts.yml` | OAuth tokens |
| `~/.gnupg/` | Private keys |
| Any `.env` file | May contain secrets |

Always scan before adding:
```zsh
grep -iE '(token|password|secret|api[_-]?key|credential)' <file>
```

## Additional Resources

- **`references/new-machine-setup.md`** — Bootstrap guide for a fresh machine
