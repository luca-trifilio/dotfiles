#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

# --- Homebrew packages ---
brew bundle install --file="$(pwd)/brew/Brewfile"

# --- Symlinks ---
stow .                                       # nvim, ghostty, tmux, … → ~/.config/
stow --target="$HOME" zshrc                  # .zshrc → ~/
stow --target="$HOME" gitconfig              # .gitconfig → ~/
stow --target="$HOME" claude                 # .claude/ → ~/.claude/
ln -sfn "$(pwd)/karabiner" "$HOME/.config/karabiner"  # dir symlink (KE overwrites file symlinks)

# --- kanata LaunchDaemon (runs as root, needs Karabiner VirtualHID driver) ---
sed "s|__HOME__|$HOME|g" "$(pwd)/kanata-daemon/com.lucatrifilio.kanata.plist" \
  | sudo tee /Library/LaunchDaemons/com.lucatrifilio.kanata.plist > /dev/null
sudo launchctl bootout system/com.lucatrifilio.kanata 2>/dev/null || true
sudo launchctl bootstrap system /Library/LaunchDaemons/com.lucatrifilio.kanata.plist

# --- Disable KE daemons/agents (keep only VirtualHID driver for kanata) ---
for agent in \
  org.pqrs.service.agent.Karabiner-Core-Service \
  org.pqrs.service.agent.Karabiner-Core-Service-rev2 \
  org.pqrs.service.agent.karabiner_console_user_server \
  org.pqrs.service.agent.karabiner_session_monitor \
  org.pqrs.service.agent.Karabiner-NotificationWindow; do
  launchctl disable gui/$(id -u)/$agent 2>/dev/null || true
  launchctl bootout gui/$(id -u)/$agent 2>/dev/null || true
done
sudo launchctl disable system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true
sudo launchctl bootout system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true

# --- Yazi ---
ya pkg install                               # yazi flavors (catppuccin-macchiato)

# --- docs/ symlinks → Obsidian vault (vault must be present) ---
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
