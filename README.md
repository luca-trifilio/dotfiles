# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## How it works

`.stowrc` sets `--target=~/.config`. Running `stow .` symlinks every top-level directory into `~/.config/` automatically — no manual updates needed when adding or removing packages.

Two packages target `~/` instead and are handled separately in `setup.sh`:

| Package | Target |
|---|---|
| `zshrc` | `~/` |
| `claude` | `~/.claude/` |

## Fresh machine setup

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
cd ~/Progetti/dotfiles
./bootstrap.sh   # install Homebrew, CLI tools, Oh My Zsh, Bun, TPM
./setup.sh       # stow all symlinks
```

After `setup.sh`, inside tmux run `prefix + I` to install plugins via TPM.

## Adding a package

**XDG** (→ `~/.config/`): just create the directory and run `stow .` — nothing else needed.

**Home-target** (→ `~/`): add `--ignore=^<pkg>$` to `.stowrc` and `stow --target="$HOME" <pkg>` to `setup.sh`.
