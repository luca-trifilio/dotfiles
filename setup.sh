#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
brew bundle install --file="$(pwd)/brew/Brewfile"
stow .                        # nvim, ghostty, tmux → ~/.config/
stow --target="$HOME" zshrc                  # .zshrc → ~/
stow --target="$HOME" gitconfig              # .gitconfig → ~/
stow --target="$HOME" claude                 # .claude/ → ~/.claude/
ya pkg install                               # yazi flavors (catppuccin-macchiato)
