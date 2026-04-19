# CLAUDE.md

Personal dotfiles at `~/Progetti/dotfiles`, managed with **GNU Stow**.

## How stow works here

`.stowrc` sets `--target=~/.config`. Running `stow .` from inside the repo treats the repo as a single package: stow maps each top-level directory into `~/.config/` via directory symlinks (tree folding).

```
dotfiles/nvim/    → ~/.config/nvim    (symlink)
dotfiles/ghostty/ → ~/.config/ghostty (symlink)
dotfiles/tmux/    → ~/.config/tmux    (symlink)
```

## Home-target packages

Some packages target `~/` instead of `~/.config/`. They are excluded from `stow .` via `.stowrc` and handled separately in `setup.sh`.

| Package | Target | How |
|---|---|---|
| `zshrc` | `~/` | `stow --target="$HOME" zshrc` |
| `claude` | `~/.claude/` | `stow --target="$HOME" claude` |

## Current packages

| Package | Target | Notes |
|---|---|---|
| `nvim` | `~/.config/nvim/` | LazyVim |
| `ghostty` | `~/.config/ghostty/` | auto-starts tmux on open |
| `tmux` | `~/.config/tmux/` | plugins at `~/.tmux/plugins/` |
| `zsh` | `~/.config/zsh/` | aliases, exports, tmux fn, zoxide |
| `opencode` | `~/.config/opencode/` | |
| `starship` | `~/.config/starship/` | `STARSHIP_CONFIG` set in `.zshrc` |
| `zshrc` | `~/` | `.zshrc`, `.p10k.zsh` |
| `claude` | `~/.claude/` | `statusline.sh` |

## zsh config structure

`.zshrc` sources modular files from `~/.config/zsh/` (→ `dotfiles/zsh/`):

- `exports.zsh` — PATH, EDITOR, BUN, LM Studio
- `aliases.zsh` — shell aliases
- `tmux.zsh` — tmux wrapper function
- `zoxide.zsh` — zoxide config + lazy init

## nvim structure

Plugin files use semantic grouping (not one file per plugin):
- `lua/plugins/ui.lua` — colorscheme, lualine, tmux-navigator
- `lua/plugins/coding.lua` — gitsigns, language plugins
- `lua/plugins/notes.lua` — markdown, obsidian, blink.cmp overrides
- `lua/plugins/snacks.lua` — dashboard, picker, explorer

Assets (logo, etc.) live in `lua/assets/` and are `require()`d in plugin configs.

## tmux plugins

TPM and all plugins live at `~/.tmux/plugins/` — **outside** the stow-managed `~/.config/tmux/`. `tmux.conf` explicitly sets:

```
set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins/"
```

This prevents TPM from installing into `~/.config/tmux/plugins/` (which would leak into the repo via the stow symlink). `tmux/plugins/` is also gitignored as a safety net.

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
# place files inside, mirroring the target structure
# Add to .stowrc:  --ignore=^<app>$
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

## Gotchas

- Nerd Font glyphs corrupt when copy-pasted through terminal — use `gh api ... --jq '.content' | base64 -d > file` to preserve bytes
- `printf "%.2f"` uses locale decimal separator — use `LC_ALL=C awk '{printf "%.2f", $1}'` for locale-safe float formatting in shell scripts

## Fresh machine bootstrap

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
cd ~/Progetti/dotfiles
./bootstrap.sh   # install prerequisites
./setup.sh       # stow symlinks
# Then install TPM for tmux:
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Inside tmux: prefix + I to install plugins
```
