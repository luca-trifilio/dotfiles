# New Machine Setup — Dotfiles Bootstrap

## Pre-requisites

Install git and stow. On macOS:

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

This runs `stow nvim ghostty zshrc tmux` with `--target=~`.

If stow fails due to existing files, back them up first:

```zsh
mkdir -p ~/.config-backup
# move conflicting files to backup, then re-run ./setup.sh
```

### 3. Done

Source the shell config or open a new terminal:

```zsh
source ~/.zshrc
```

---

## Bootstrap One-Liner

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles && \
cd ~/Progetti/dotfiles && ./setup.sh && source ~/.zshrc
```
