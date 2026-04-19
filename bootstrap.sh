#!/usr/bin/env bash
# bootstrap.sh — install prerequisites before running setup.sh
# Usage: ./bootstrap.sh [--dry-run]
set -e

DRY=false
[[ "${1:-}" == "--dry-run" ]] && DRY=true

run() {
  if $DRY; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

status() { echo ""; echo "── $1"; }

# ── Homebrew ──────────────────────────────────────────────────────────────────
status "Homebrew"
if command -v brew &>/dev/null; then
  echo "  already installed"
else
  $DRY && echo "  [dry-run] install Homebrew via curl" || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ── CLI tools ─────────────────────────────────────────────────────────────────
status "CLI tools (brew)"
for pkg in git stow neovim tmux starship zoxide; do
  if brew list "$pkg" &>/dev/null; then
    echo "  $pkg — already installed"
  else
    echo "  $pkg — will install"
    run brew install "$pkg"
  fi
done

# ── Apps (cask) ───────────────────────────────────────────────────────────────
status "Apps (brew cask)"
for cask in ghostty karabiner-elements; do
  if brew list --cask "$cask" &>/dev/null; then
    echo "  $cask — already installed"
  else
    echo "  $cask — will install"
    run brew install --cask "$cask"
  fi
done

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
status "Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "  already installed"
else
  echo "  will install via curl"
  run sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── OMZ plugins ───────────────────────────────────────────────────────────────
status "OMZ plugins"
OMZ_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
for plugin_repo in \
  "zsh-users/zsh-syntax-highlighting" \
  "zsh-users/zsh-autosuggestions"; do
  plugin="${plugin_repo##*/}"
  if [ -d "$OMZ_PLUGINS/$plugin" ]; then
    echo "  $plugin — already installed"
  else
    echo "  $plugin — will clone"
    run git clone "https://github.com/$plugin_repo" "$OMZ_PLUGINS/$plugin"
  fi
done

# ── Bun ───────────────────────────────────────────────────────────────────────
status "Bun"
if command -v bun &>/dev/null; then
  echo "  already installed"
else
  echo "  will install via curl"
  run curl -fsSL https://bun.sh/install | bash
fi

# ── TPM ───────────────────────────────────────────────────────────────────────
status "TPM (tmux plugin manager)"
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "  already installed"
else
  echo "  will clone tmux-plugins/tpm"
  run git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ── Manual steps ──────────────────────────────────────────────────────────────
echo ""
echo "── Manual steps (can't automate)"
echo "  1. Nerd Font — https://www.nerdfonts.com (set in Ghostty config)"
echo "  2. Java JDK (optional, nvim-jdtls) — brew install temurin"
echo "  3. Inside tmux after setup.sh: prefix + I to install plugins"
echo ""
$DRY && echo "Dry run complete — nothing was installed." || echo "Done. Now run: ./setup.sh"
