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

## Structure

Each app has its own package directory. Files are laid out relative to `~` (stow target).

```
dotfiles/
  zshrc/
    .zshrc
    .p10k.zsh
  nvim/
    .config/nvim/   ← LazyVim config
  ghostty/
    .config/ghostty/
      config
  tmux/
    .config/tmux/
      tmux.conf
  .stowrc           # --target=~
  setup.sh          # stow nvim ghostty zshrc tmux
```

## Day-to-Day Operations

```zsh
cd ~/Progetti/dotfiles
git add zshrc/.zshrc
git commit -m "message"
git push
```

## Adding a New App

1. Create `<package>/<path-relative-to-home>/` inside the repo
2. Move the real file into it
3. Run `stow <package>` to create the symlink
4. Commit

Example — adding `.gitconfig`:
```zsh
mkdir -p ~/Progetti/dotfiles/git
mv ~/.gitconfig ~/Progetti/dotfiles/git/
cd ~/Progetti/dotfiles && stow git
git add git && git commit -m "add gitconfig"
```

## Currently Tracked Packages

| Package | Symlinks to |
|---|---|
| `zshrc` | `~/.zshrc`, `~/.p10k.zsh` |
| `nvim` | `~/.config/nvim` |
| `ghostty` | `~/.config/ghostty` |
| `tmux` | `~/.config/tmux/tmux.conf` |

## Files Safe to Add

| File | Package name |
|---|---|
| `~/.gitconfig` | `git` |
| `~/.config/gh/config.yml` | `gh` |
| `~/.config/opencode/opencode.json` | `opencode` |

## Files to NEVER Track

| File | Reason |
|---|---|
| `~/.ssh/` | Private keys |
| `~/.config/gh/hosts.yml` | OAuth tokens |
| `~/.gnupg/` | Private keys |
| `~/.config/opencode/node_modules/` | Generated artifacts |
| Any `.env` file | May contain secrets |

Always scan before adding:
```zsh
grep -iE '(token|password|secret|api[_-]?key|credential)' <file>
```

## Additional Resources

- **`references/new-machine-setup.md`** — Bootstrap guide for a fresh machine
