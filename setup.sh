#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
brew bundle install --file="$(pwd)/brew/Brewfile"
stow .                        # nvim, ghostty, tmux → ~/.config/
stow --target="$HOME" zshrc                  # .zshrc → ~/
stow --target="$HOME" gitconfig              # .gitconfig → ~/
stow --target="$HOME" claude                 # .claude/ → ~/.claude/
ya pkg install                               # yazi flavors (catppuccin-macchiato)

# docs/ symlinks → Obsidian vault (vault must be present)
VAULT="$HOME/Documents/Taccuino Cerusico/60 - Progetti/dotfiles"
DOCS="$(pwd)/docs"
mkdir -p "$DOCS"
if [ -d "$VAULT" ]; then
  ln -sf "$VAULT/dotfiles doc.md"           "$DOCS/index.md"
  ln -sf "$VAULT/dotfiles - aerospace.md"   "$DOCS/aerospace.md"
  ln -sf "$VAULT/dotfiles - atuin.md"       "$DOCS/atuin.md"
  ln -sf "$VAULT/dotfiles - brew.md"        "$DOCS/brew.md"
  ln -sf "$VAULT/dotfiles - fzf.md"         "$DOCS/fzf.md"
  ln -sf "$VAULT/dotfiles - git.md"         "$DOCS/git.md"
  ln -sf "$VAULT/dotfiles - nvim.md"        "$DOCS/nvim.md"
  ln -sf "$VAULT/dotfiles - tmux.md"        "$DOCS/tmux.md"
  ln -sf "$VAULT/dotfiles - yazi.md"        "$DOCS/yazi.md"
  ln -sf "$VAULT/dotfiles - zsh.md"         "$DOCS/zsh.md"
  echo "docs/ symlinks created"
else
  echo "⚠ Obsidian vault not found at $VAULT — skipping docs/ symlinks"
fi
