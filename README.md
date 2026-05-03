# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## How it works

`.stowrc` sets `--target=~/.config`. Running `stow .` symlinks every top-level directory into `~/.config/` automatically — no manual updates needed when adding or removing packages.

Three packages target `~/` or `~/.claude/` instead and are handled separately in `setup.sh`:

| Package | Target |
|---|---|
| `zshrc` | `~/` |
| `gitconfig` | `~/` |
| `claude` | `~/.claude/` |

## Fresh machine setup

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
cd ~/Progetti/dotfiles
./bootstrap.sh   # Homebrew, CLI tools, Oh My Zsh, OMZ plugins, fzf-git, Bun, TPM
./setup.sh       # brew bundle, stow all symlinks, yazi flavors
```

**Manual steps** (can't be automated):

1. **Nerd Font** — install from [nerdfonts.com](https://www.nerdfonts.com) and set in Ghostty config
2. **Karabiner-Elements** — grant Input Monitoring + Accessibility in System Settings → Privacy & Security; enable driver in System Settings → General → Login Items & Extensions → Driver Extensions
3. **tmux plugins** — inside tmux: `prefix + I` to install via TPM
4. **Atuin sync** — `atuin login -u <user> -p <pass> -s https://atuin-homelab.lucatrifilio.it` then `atuin sync`
5. **Java JDK** (optional, for nvim-jdtls) — `brew install temurin`

## Adding a package

**XDG** (→ `~/.config/`): create the directory and run `stow .` — nothing else needed.

**Home-target** (→ `~/`): add `--ignore=^<pkg>$` to `.stowrc` and `stow --target="$HOME" <pkg>` to `setup.sh`.
