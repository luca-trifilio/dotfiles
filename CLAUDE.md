# CLAUDE.md

Personal dotfiles at `~/Progetti/dotfiles`, managed with **GNU Stow**.

## Documentation

Per-tool docs with current config state, paths, and gotchas: `docs/index.md`.

`docs/<tool>.md` are file symlinks into the Obsidian vault, created by the Ansible `macos` role (`Symlink docs from Obsidian vault`, only when `enable_docs`, i.e. personal). Only `docs/adr/` is versioned (see `.gitignore`).

## How stow works here

`.stowrc` sets `--target=~/.config`. Running `stow .` symlinks every top-level directory into `~/.config/` automatically. No changes to `.stowrc` needed when adding XDG packages.

Some packages are excluded from `stow .` and handled by Ansible (`stow` role for home-target, `macos` role for karabiner/colima):

| Package | Target | Command |
|---|---|---|
| `zshrc` | `~/` | `stow --target="$HOME" zshrc` |
| `gitconfig` | `~/` | `stow --target="$HOME" gitconfig` |
| `claude` | `~/.claude/` | `stow --target="$HOME" claude` |
| `karabiner` | `~/.config/karabiner/` | `ln -sfn` directory symlink (`macos` role; see gotcha below) |
| `colima` | ignored in `.stowrc` | `macos` role: file symlink `colima.yaml` + `~/.colima → ~/.config/colima`; la dir è gestita da Colima a runtime (contiene socket) |

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
- **kanata / Karabiner-Elements** — binario kanata (path Cellar) in Input Monitoring + Accessibility; Driver Extension KE in Generale → Elementi di Login ed Estensioni (vedi skill `kanata-macos-setup`)
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
# Add <app> to the home-target loop in ansible/roles/stow/tasks/main.yml
cd ~/Progetti/dotfiles && stow --target="$HOME" <app>
git add <app> .stowrc ansible/roles/stow/tasks/main.yml && git commit -m "add <app>"
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
- `aws.zsh` — AWS helpers (e1s wrapper)
- `kube.zsh` — Kubernetes helpers
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
- `lua/plugins/editing.lua` — editing helpers (rip-substitute, text-case)
- `lua/plugins/atlas.lua`, `hardtime.lua` — single-plugin specs
- `lua/plugins/bruno.lua` — `.bru` filetype + local tree-sitter parser (`~/Progetti/tree-sitter-bru`)
- `lua/plugins/disabled.lua` — LazyVim defaults turned off

## Useful stow commands

```zsh
stow -nv .   # dry-run
stow -D .    # remove all XDG symlinks
stow -R .    # restow (remove + re-apply)
```
