# New Machine Setup — Dotfiles Bootstrap

## Pre-requisites

```zsh
xcode-select --install
brew install stow
```

## Steps

### 1. Clone the repo

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
```

### 2. Run setup

```zsh
cd ~/Progetti/dotfiles && ./setup.sh
```

This runs:
- `stow .` → symlinks `nvim/`, `ghostty/`, `tmux/` into `~/.config/`
- `stow --target="$HOME" zshrc` → symlinks `.zshrc`, `.p10k.zsh` into `~/`

If stow fails due to existing files, back them up first:
```zsh
mv ~/.config/nvim ~/.config/nvim.bak   # example
cd ~/Progetti/dotfiles && ./setup.sh
```

### 3. Bootstrap tmux plugins

TPM lives outside the dotfiles repo at `~/.tmux/plugins/tpm`:

```zsh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then open tmux and press `prefix + I` to install all plugins listed in `tmux.conf`.

### 4. Done

```zsh
source ~/.zshrc
```

---

## Bootstrap One-Liner

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles && \
cd ~/Progetti/dotfiles && ./setup.sh && \
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
source ~/.zshrc
```

Then open tmux → `prefix + I`.
