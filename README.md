# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Each app is a package directory. `stow .` symlinks all XDG packages into `~/.config/` at once.

```
dotfiles/
  nvim/        → ~/.config/nvim/     (LazyVim)
    lua/plugins/ui.lua       colorscheme, lualine, tmux-navigator
    lua/plugins/coding.lua   gitsigns, language plugins
    lua/plugins/notes.lua    markdown, obsidian, blink.cmp
    lua/plugins/snacks.lua   dashboard, picker, explorer
    lua/assets/              static assets (logo, etc.)
  ghostty/     → ~/.config/ghostty/  (auto-starts tmux)
  tmux/        → ~/.config/tmux/     (plugins at ~/.tmux/plugins/, gitignored)
  zsh/         → ~/.config/zsh/      (aliases, exports, tmux fn, zoxide)
  opencode/    → ~/.config/opencode/
  starship/    → ~/.config/starship/ (STARSHIP_CONFIG set in .zshrc)
  zshrc/       → ~/                  (.zshrc, .p10k.zsh)
  claude/      → ~/.claude/          (statusline.sh)
```

## Prerequisites

| Tool | Install |
|---|---|
| Homebrew | [brew.sh](https://brew.sh) |
| git, stow, neovim, tmux | `brew install` |
| starship, zoxide | `brew install` |
| zsh-syntax-highlighting, zsh-autosuggestions | git clone in `~/.oh-my-zsh/custom/plugins/` |
| Oh My Zsh | curl installer |
| Bun | curl installer |
| Ghostty | `brew install --cask ghostty` |
| Karabiner-Elements | `brew install --cask karabiner-elements` |
| Nerd Font | [nerdfonts.com](https://www.nerdfonts.com) — manual, set in Ghostty config |
| Java JDK *(optional, nvim-jdtls)* | `brew install temurin` |

Run `bootstrap.sh` to install everything automatable:

```zsh
./bootstrap.sh
```

## Install

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
cd ~/Progetti/dotfiles
./bootstrap.sh   # install prerequisites
./setup.sh       # stow symlinks
```

## zshrc exception

`zshrc/` targets `~` instead of `~/.config/` because `.zshrc` lives at `~`. `setup.sh` handles this with a separate stow call. Same pattern for `claude/`.

## Add a new package

**XDG package** (goes to `~/.config/`):
```zsh
mkdir ~/Progetti/dotfiles/<app>
mv ~/.config/<app> ~/Progetti/dotfiles/<app>
cd ~/Progetti/dotfiles && stow .
```

**Home package** (goes to `~/`):
```zsh
mkdir ~/Progetti/dotfiles/<app>
mv ~/.<file> ~/Progetti/dotfiles/<app>/
# add --ignore=^<app>$ to .stowrc
# add stow --target="$HOME" <app> to setup.sh
cd ~/Progetti/dotfiles && stow --target="$HOME" <app>
```
