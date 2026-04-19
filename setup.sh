#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
stow .                        # nvim, ghostty, tmux → ~/.config/
stow --target="$HOME" zshrc                  # .zshrc, .p10k.zsh → ~/
stow --target="$HOME" claude                 # .claude/ → ~/.claude/
