# CLAUDE.md

Personal dotfiles at `~/Progetti/dotfiles`, managed with **GNU Stow**.

## How stow works here

`.stowrc` sets `--target=~/.config`. Running `stow .` symlinks every top-level directory into `~/.config/` automatically. No changes to `.stowrc` or `setup.sh` needed when adding XDG packages.

Two packages are excluded from `stow .` and handled separately in `setup.sh`:

| Package | Target | Command |
|---|---|---|
| `zshrc` | `~/` | `stow --target="$HOME" zshrc` |
| `gitconfig` | `~/` | `stow --target="$HOME" gitconfig` |
| `claude` | `~/.claude/` | `stow --target="$HOME" claude` |

## Fresh machine bootstrap

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
cd ~/Progetti/dotfiles
./bootstrap.sh   # Homebrew, CLI tools, Oh My Zsh, OMZ plugins, fzf-git, Bun, TPM
./setup.sh       # stow all symlinks
# Inside tmux: prefix + I to install plugins via TPM
```

Manual steps bootstrap.sh can't automate:
- Nerd Font — install from [nerdfonts.com](https://www.nerdfonts.com)
- Karabiner-Elements — grant Input Monitoring + Accessibility permissions, enable keyboard in Devices tab

## Adding a new XDG package

```zsh
mkdir ~/Progetti/dotfiles/<app>
mv ~/.config/<app> ~/Progetti/dotfiles/<app>
cd ~/Progetti/dotfiles && stow .
git add <app> && git commit -m "add <app>"
```

## Adding a home-target package

```zsh
mkdir ~/Progetti/dotfiles/<app>
# Add to .stowrc:  --ignore=^<app>$
# Add to setup.sh: stow --target="$HOME" <app>
cd ~/Progetti/dotfiles && stow --target="$HOME" <app>
git add <app> .stowrc setup.sh && git commit -m "add <app>"
```

## Key gotchas

- **tmux plugins** live at `~/.tmux/plugins/` (outside stow). `tmux.conf` sets `TMUX_PLUGIN_MANAGER_PATH` explicitly to prevent TPM from writing into the stow-managed `~/.config/tmux/`.
- **Catppuccin tmux**: if the theme isn't applied, check that `~/.tmux/plugins/tmux/` is the catppuccin repo (not Dracula or another leftover). Remove and reinstall with `prefix + I`.
- **Nerd Font glyphs** corrupt when copy-pasted through terminal — use `gh api ... --jq '.content' | base64 -d > file` to preserve bytes.
- **Float formatting** in shell: `printf "%.2f"` uses locale decimal separator — use `LC_ALL=C awk '{printf "%.2f", $1}'` instead.

## zsh config structure

`.zshrc` sources modular files from `~/.config/zsh/` (`dotfiles/zsh/`):

- `exports.zsh` — PATH, EDITOR, env vars
- `history.zsh` — HISTFILE, HISTSIZE, SAVEHIST, setopts
- `completions.zsh` — zstyle, fzf-tab config
- `aliases.zsh` — shell aliases
- `tmux.zsh` — tmux wrapper function
- `zoxide.zsh` — zoxide init (`--cmd cd` replaces `cd`)
- `fzf.zsh` — fzf init, fd integration, bat/eza previews, fzf-git, Catppuccin theme
- `vimode.zsh` — vi keybindings + cursor shape; unbinds `^G` for fzf-git chords

OMZ plugins: `git kubectl aws fzf-tab zsh-syntax-highlighting zsh-autosuggestions`

Custom plugins (cloned in `~/.oh-my-zsh/custom/plugins/`): `zsh-completions`, `fzf-tab`

**compinit**: handled by OMZ via `ZSH_DISABLE_COMPFIX=true` — do not call manually.

## Atuin

Shell history sync, self-hosted at `atuin-homelab.lucatrifilio.it`. Config at `dotfiles/atuin/config.toml` (XDG, stowed). Replaces `Ctrl+R`. Syncs every 10min triggered by any command.

## nvim structure

Plugin files use semantic grouping:
- `lua/plugins/ui.lua` — colorscheme, lualine, tmux-navigator
- `lua/plugins/coding.lua` — gitsigns, language plugins
- `lua/plugins/notes.lua` — markdown, obsidian, blink.cmp overrides
- `lua/plugins/snacks.lua` — dashboard, picker, explorer

## Useful stow commands

```zsh
stow -nv .   # dry-run
stow -D .    # remove all XDG symlinks
stow -R .    # restow (remove + re-apply)
```
