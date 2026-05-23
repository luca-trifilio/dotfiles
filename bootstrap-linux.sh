#!/usr/bin/env bash
# bootstrap-linux.sh — install prerequisites on Ubuntu/Debian, then run setup-linux.sh
set -e

DRY=false
[[ "${1:-}" == "--dry-run" ]] && DRY=true

run() { $DRY && echo "  [dry-run] $*" || "$@"; }
status() { echo ""; echo "── $1"; }

# ── Base packages ─────────────────────────────────────────────────────────────
status "apt packages"
run apt-get update -qq
run apt-get install -y zsh stow git curl

# ── Starship ──────────────────────────────────────────────────────────────────
status "Starship"
if command -v starship &>/dev/null; then
  echo "  already installed"
else
  run curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# ── Zoxide ────────────────────────────────────────────────────────────────────
status "Zoxide"
if command -v zoxide &>/dev/null; then
  echo "  already installed"
else
  run curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# ── Atuin ─────────────────────────────────────────────────────────────────────
status "Atuin"
if command -v atuin &>/dev/null; then
  echo "  already installed"
else
  run curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
status "Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "  already installed"
else
  run sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── OMZ plugins ───────────────────────────────────────────────────────────────
status "OMZ plugins"
OMZ_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
for plugin_repo in \
  "zsh-users/zsh-syntax-highlighting" \
  "zsh-users/zsh-autosuggestions" \
  "zsh-users/zsh-completions" \
  "Aloxaf/fzf-tab"; do
  plugin="${plugin_repo##*/}"
  if [ -d "$OMZ_PLUGINS/$plugin" ]; then
    echo "  $plugin — already installed"
  else
    echo "  $plugin — will clone"
    run git clone "https://github.com/$plugin_repo" "$OMZ_PLUGINS/$plugin"
  fi
done

# ── TPM ───────────────────────────────────────────────────────────────────────
status "TPM (tmux plugin manager)"
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "  already installed"
else
  run git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ── Default shell ─────────────────────────────────────────────────────────────
status "Default shell → zsh"
ZSH_BIN=$(which zsh)
if [ "$SHELL" = "$ZSH_BIN" ]; then
  echo "  already zsh"
else
  run chsh -s "$ZSH_BIN"
fi

echo ""
$DRY && echo "Dry run complete — nothing was installed." || echo "Done. Now run: ./setup-linux.sh"
