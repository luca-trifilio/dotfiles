# CLAUDE.md

Personal dotfiles at `~/Progetti/dotfiles`, managed with **GNU Stow**.

## Documentation

Per-tool docs with current config state, paths, and gotchas: `docs/index.md`.

`docs/` is **not versioned** — it's a symlink to an Obsidian vault folder managed externally. Create it manually on a new machine:

```zsh
ln -s /path/to/obsidian/vault/dotfiles ~/Progetti/dotfiles/docs
```

## How stow works here

`.stowrc` sets `--target=~/.config`. Running `stow .` symlinks every top-level directory into `~/.config/` automatically. No changes to `.stowrc` or `setup.sh` needed when adding XDG packages.

Some packages are excluded from `stow .` and handled separately in `setup.sh`:

| Package | Target | Command |
|---|---|---|
| `zshrc` | `~/` | `stow --target="$HOME" zshrc` |
| `gitconfig` | `~/` | `stow --target="$HOME" gitconfig` |
| `claude` | `~/.claude/` | `stow --target="$HOME" claude` |
| `karabiner` | `~/.config/karabiner/` | `ln -sf` (file symlink, not stow) |
| `colima` | ignored in `.stowrc` | `colima.yaml` già linkato manualmente; la dir è gestita da Colima a runtime (contiene socket) |

## Fresh machine bootstrap

Ansible è il metodo principale. `bootstrap.sh` è il solo prereq (installa Homebrew e Ansible).

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
cd ~/Progetti/dotfiles

# 1. Prereq (Homebrew + Ansible)
./bootstrap.sh

# 2. Copia la SOPS age key da un'altra macchina
mkdir -p ~/.config/sops/age
# scp / AirDrop → ~/.config/sops/age/keys.txt

# 3. Installa le collections
cd ansible && ansible-galaxy collection install -r requirements.yml

# 4. Esegui il playbook (chiede profilo interattivamente: personal/work)
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  ansible-playbook playbooks/bootstrap.yml --ask-become-pass
```

Manual steps non automatizzabili:
- **Nerd Font** — installa da [nerdfonts.com](https://www.nerdfonts.com)
- **Karabiner-Elements** — Input Monitoring + Accessibility in Impostazioni di Sistema → Privacy e Sicurezza; Driver Extension in Generale → Elementi di Login ed Estensioni
- **tmux plugins** — dentro tmux: `prefix + I`

## Adding a new XDG package

```zsh
mkdir ~/Progetti/dotfiles/<app>
mv ~/.config/<app> ~/Progetti/dotfiles/<app>
cd ~/Progetti/dotfiles && stow .
git add <app> && git commit -m "add <app>"
```

## Adding a home-target package

```zsh
mkdir ~/Progetti/dotfiles/<app>
# Add to .stowrc:  --ignore=^<app>$
# Add to setup.sh: stow --target="$HOME" <app>
cd ~/Progetti/dotfiles && stow --target="$HOME" <app>
git add <app> .stowrc setup.sh && git commit -m "add <app>"
```

## Key gotchas

- **tmux plugins** live at `~/.tmux/plugins/` (outside stow). `tmux.conf` sets `TMUX_PLUGIN_MANAGER_PATH` explicitly to prevent TPM from writing into the stow-managed `~/.config/tmux/`.
- **Catppuccin tmux**: if the theme isn't applied, check that `~/.tmux/plugins/tmux/` is the catppuccin repo (not Dracula or another leftover). Remove and reinstall with `prefix + I`.
- **Nerd Font glyphs** corrupt when copy-pasted through terminal — use `gh api ... --jq '.content' | base64 -d > file` to preserve bytes.
- **Float formatting** in shell: `printf "%.2f"` uses locale decimal separator — use `LC_ALL=C awk '{printf "%.2f", $1}'` instead.
- **delta Catppuccin theme**: lives in `git/catppuccin.gitconfig` (XDG, stowed to `~/.config/git/`), included via `[include] path = ~/.config/git/catppuccin.gitconfig` in `.gitconfig`. Do not move it to the `gitconfig/` package.
- **stow --adopt**: sovrascrive i file nel repo con quelli esistenti sulla macchina — usare solo per adottare file già presenti in `~/` o `~/.config/`, non per routine restow.
- **Karabiner-Elements**: sovrascrive i symlink ai file prima di scrivere (bug noto, non fixato upstream). Usare `ln -sfn "$(pwd)/karabiner" "$HOME/.config/karabiner"` — symlink alla **directory**, non al file. `.gitignore` in `karabiner/` traccia solo `karabiner.json`.

## zsh config structure

`.zshrc` sources modular files from `~/.config/zsh/` (`dotfiles/zsh/`):

- `exports.zsh` — PATH, EDITOR, env vars
- `history.zsh` — HISTFILE, HISTSIZE, SAVEHIST, setopts
- `completions.zsh` — zstyle, fzf-tab config
- `aliases.zsh` — shell aliases
- `tmux.zsh` — tmux wrapper function
- `zoxide.zsh` — zoxide init (`--cmd cd` replaces `cd`)
- `fzf.zsh` — fzf init, fd integration, bat/eza previews, fzf-git, Catppuccin theme
- `vimode.zsh` — vi keybindings + cursor shape; unbinds `^G` for fzf-git chords

OMZ plugins: `git kubectl aws fzf-tab zsh-syntax-highlighting zsh-autosuggestions`

Custom plugins (cloned in `~/.oh-my-zsh/custom/plugins/`): `zsh-completions`, `fzf-tab`

**compinit**: handled by OMZ via `ZSH_DISABLE_COMPFIX=true` — do not call manually.

## Atuin

Local shell history, no sync server. Config at `dotfiles/atuin/config.toml` (stowed via directory symlink: `~/.config/atuin → dotfiles/atuin`). Replaces `Ctrl+R`. Catppuccin Macchiato theme in `dotfiles/atuin/themes/`.

## nvim structure

Plugin files use semantic grouping:
- `lua/plugins/ui.lua` — colorscheme, lualine, tmux-navigator
- `lua/plugins/coding.lua` — gitsigns, language plugins
- `lua/plugins/notes.lua` — markdown, obsidian, blink.cmp overrides
- `lua/plugins/snacks.lua` — dashboard, picker, explorer

## Useful stow commands

```zsh
stow -nv .   # dry-run
stow -D .    # remove all XDG symlinks
stow -R .    # restow (remove + re-apply)
```
