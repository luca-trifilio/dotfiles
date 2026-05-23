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
run apt-get install -y zsh stow git curl fzf fd-find bat neovim unzip

# fd and bat ship with different binary names on Ubuntu
mkdir -p "$HOME/.local/bin"
[ -f /usr/bin/fdfind ] && [ ! -e "$HOME/.local/bin/fd" ]  && run ln -s /usr/bin/fdfind "$HOME/.local/bin/fd"
[ -f /usr/bin/batcat ] && [ ! -e "$HOME/.local/bin/bat" ] && run ln -s /usr/bin/batcat "$HOME/.local/bin/bat"

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

# ── Eza ───────────────────────────────────────────────────────────────────────
status "Eza"
if command -v eza &>/dev/null; then
  echo "  already installed"
else
  run apt-get install -y eza
fi

# ── Delta ─────────────────────────────────────────────────────────────────────
status "Delta"
if command -v delta &>/dev/null; then
  echo "  already installed"
else
  DELTA_URL=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest \
    | grep "browser_download_url.*x86_64-unknown-linux-musl.tar.gz" | cut -d'"' -f4)
  run curl -sL "$DELTA_URL" | tar xz -C /tmp
  run mv /tmp/delta-*/delta /usr/local/bin/delta
fi

# ── Yazi ──────────────────────────────────────────────────────────────────────
status "Yazi"
if command -v yazi &>/dev/null; then
  echo "  already installed"
else
  YAZI_URL=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest \
    | grep "browser_download_url.*yazi-x86_64-unknown-linux-musl.zip" | cut -d'"' -f4)
  run curl -sL "$YAZI_URL" -o /tmp/yazi.zip
  run unzip -q /tmp/yazi.zip -d /tmp/yazi
  run mv /tmp/yazi/yazi-*/yazi /usr/local/bin/yazi
  rm -rf /tmp/yazi /tmp/yazi.zip
fi

# ── kubectx / kubens ──────────────────────────────────────────────────────────
status "kubectx / kubens"
for tool in kubectx kubens; do
  if command -v "$tool" &>/dev/null; then
    echo "  $tool — already installed"
  else
    URL=$(curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest \
      | grep "browser_download_url.*/${tool}_v.*_linux_x86_64.tar.gz" | cut -d'"' -f4)
    run curl -sL "$URL" | tar xz -C /usr/local/bin "$tool"
  fi
done

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
