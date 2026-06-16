# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) as symlink engine, orchestrated by **Ansible**.

## How it works

Stow symlinks config directories into `~/.config/` (via `.stowrc`). Ansible handles package installation, shell setup, and system configuration — idempotently, for two profiles: `personal` and `work`.

| Profile | Machine |
|---|---|
| `personal` | MacBook Pro M4 Max |
| `work` | company Mac |

## Fresh machine setup

```zsh
git clone https://github.com/luca-trifilio/dotfiles.git ~/Progetti/dotfiles
cd ~/Progetti/dotfiles

# 1. Homebrew + Ansible prereqs
./bootstrap.sh

# 2. SOPS age key (copy from existing machine via scp / AirDrop)
mkdir -p ~/.config/sops/age
# → place keys.txt at ~/.config/sops/age/keys.txt

# 3. Ansible collections
cd ansible && ansible-galaxy collection install -r requirements.yml

# 4. Run (prompts for profile: personal/work)
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  ansible-playbook playbooks/new-mac.yml --ask-become-pass
```

**Manual steps** (cannot be automated):

1. **Nerd Font** — install from [nerdfonts.com](https://www.nerdfonts.com)
2. **Karabiner-Elements** — grant Input Monitoring + Accessibility (System Settings → Privacy & Security); enable Driver Extension (System Settings → General → Login Items & Extensions)
3. **tmux plugins** — inside tmux: `prefix + I`
4. **Java JDK** (optional, nvim-jdtls) — `brew install temurin`

## Partial runs

```zsh
cd ansible

# Dry run
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  ansible-playbook playbooks/mac.yml --limit personal-mac --check --diff

# Single role
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  ansible-playbook playbooks/mac.yml --limit personal-mac --tags stow
```

| Tag | Role |
|---|---|
| `install` | Homebrew packages + casks |
| `shell` | Oh My Zsh, plugins, Bun, TPM |
| `stow` | Symlinks via Stow |
| `macos` | karabiner, colima, kanata, yazi, docs |

## Adding a package

**Common (both machines)** — add to `ansible/group_vars/all/main.yml`:
- formulae → `brew_packages`
- casks → `brew_casks`

**Profile-only** — add to `ansible/group_vars/{personal,work}/main.yml`:
- formulae/casks → `brew_packages_extra` / `brew_casks_extra`
