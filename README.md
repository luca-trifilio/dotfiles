# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Each app is a package directory. `stow .` symlinks all XDG packages into `~/.config/` at once — each package dir becomes `~/.config/<package>/`.

```
dotfiles/
  nvim/        → ~/.config/nvim/     (LazyVim)
  ghostty/     → ~/.config/ghostty/  (auto-starts tmux)
  tmux/        → ~/.config/tmux/     (plugins at ~/.tmux/plugins/, gitignored here)
  opencode/    → ~/.config/opencode/
  starship/    → ~/.config/starship/ (STARSHIP_CONFIG set in .zshrc)
  zshrc/       → ~/                  (exception, see below)
```

## Install

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
cd ~/Progetti/dotfiles && ./setup.sh
```

## zshrc exception

`zshrc/` targets `~` instead of `~/.config/` because `.zshrc` lives at `~`. `setup.sh` handles this with a separate stow call.

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
cd ~/Progetti/dotfiles && stow --target="$HOME" <app>
# add --ignore=^<app>$ to .stowrc so stow . skips it
```
