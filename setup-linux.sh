#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

stow tmux starship zsh
stow --target="$HOME" zshrc
stow --target="$HOME" gitconfig

echo ""
echo "Done. Manual steps:"
echo "  1. Re-open shell (or: exec zsh)"
echo "  2. Inside tmux: prefix + I to install plugins"
