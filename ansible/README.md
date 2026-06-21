# Dotfiles — Ansible

Idempotent setup for the dotfiles, replacing the imperative `setup.sh` + Stow workflow.
Stow stays the symlink engine; the Brewfile package set is migrated into `group_vars`.

Two profiles, selected with `--limit`:

| Profile | Host | Hostname |
|---|---|---|
| work | `work-mac` | `0876-Pro-14` |
| personal | `personal-mac` | _set on first run (see below)_ |

Both hosts use `ansible_connection: local` — Ansible runs against the machine it's on.

## Prerequisites

1. **Homebrew + base prereqs** — run `./bootstrap.sh` from the repo root first
   (Ansible cannot install itself or Homebrew).
2. **Ansible** — installed by `setup.sh` via `pip3 install --user ansible` if missing.
3. **Collections** — `ansible-galaxy collection install -r requirements.yml`.
4. **SOPS age key** — `~/.config/sops/age/keys.txt` must exist for the **work** profile
   (used to decrypt `group_vars/work/vault.sops.yaml`). Without it, the work run fails early.

## Run order

The easy path is the repo-root wrapper:

```zsh
./bootstrap.sh          # Homebrew + Ansible prereqs
DOTFILES_PROFILE=work ./setup.sh    # or personal; prompts if unset
```

Or invoke Ansible directly from this directory:

```zsh
cd ansible
ansible-galaxy collection install -r requirements.yml

# Work Mac
ansible-playbook playbooks/site.yml --limit work-mac

# Personal Mac
ansible-playbook playbooks/site.yml --limit personal-mac
```

## Selecting a profile (`--limit`)

`--limit work-mac` / `--limit personal-mac` picks which host (and thus which `group_vars`)
to apply. Never run without `--limit` — that would target both hosts.

## Partial runs (`--tags`)

Each role is tagged so it can run in isolation:

| Tag | Role |
|---|---|
| `install` | homebrew (taps, formulae, casks) |
| `shell` | Oh My Zsh, plugins, Bun, TPM, fzf-git |
| `stow` | Stow symlinks + `~/.gitconfig-local` |
| `macos` | karabiner, colima, kanata, yazi, docs |
| `become` | privileged kanata LaunchDaemon / KE units |

```zsh
ansible-playbook playbooks/site.yml --limit work-mac --tags install
ansible-playbook playbooks/site.yml --limit personal-mac --tags stow,shell
```

## Dry run (`--check`)

```zsh
ansible-playbook playbooks/site.yml --limit personal-mac --check --diff
```

`--check` reports per-package Homebrew status natively and uses `stow --simulate` for the
stow role, so it never mutates the live `~/.config` symlinks. Privileged kanata tasks are
guarded with `when: not ansible_check_mode` so check mode stays read-only.

## Secrets (SOPS)

`group_vars/work/vault.sops.yaml` holds work-only secrets:
`work_git_email`, `cf_access_client_id`, `cf_access_client_secret`.

Encrypt / edit with:

```zsh
sops group_vars/work/vault.sops.yaml
```

The age recipient is in `.sops.yaml`. The vault is decrypted in the playbook `pre_tasks`
only for the work group (`no_log: true`).

`~/.gitconfig-local` is **generated** from these vault values by the stow role and is always
overwritten — do not edit it by hand, edit the vault instead.

## Rollback to Stow-only

The Ansible layer is additive: the underlying engine is still Stow + Brewfile, so reverting
is just running the legacy commands manually.

```zsh
cd ~/Progetti/dotfiles

# Packages
brew bundle install --file=brew/Brewfile

# XDG symlinks
stow .

# Home-target symlinks
stow --target="$HOME" zshrc
stow --target="$HOME" gitconfig
stow --target="$HOME" claude

# Special-case symlinks
ln -sfn "$(pwd)/karabiner" "$HOME/.config/karabiner"
mkdir -p "$HOME/.config/colima/default"
ln -sf "$(pwd)/colima/default/colima.yaml" "$HOME/.config/colima/default/colima.yaml"

# kanata daemon
sed "s|__HOME__|$HOME|g" kanata-daemon/com.lucatrifilio.kanata.plist \
  | sudo tee /Library/LaunchDaemons/com.lucatrifilio.kanata.plist > /dev/null
sudo launchctl bootout system/com.lucatrifilio.kanata 2>/dev/null || true
sudo launchctl bootstrap system /Library/LaunchDaemons/com.lucatrifilio.kanata.plist
```

To remove all Stow symlinks: `stow -D .` (XDG) and `stow -D --target="$HOME" zshrc gitconfig claude`.

The git history of the pre-Ansible `setup.sh` is the canonical reference for the full manual flow.

## Manual steps (not automatable)

- Nerd Font — install from <https://www.nerdfonts.com>
- Java JDK (optional, nvim-jdtls) — `brew install temurin`
- Karabiner-Elements — grant Input Monitoring + Accessibility + Driver Extension in
  System Settings > Privacy & Security
- tmux plugins — inside tmux: `prefix + I`
- Personal Mac: fill `expected_hostname` in `group_vars/personal/main.yml`
  (run `hostname` / `scutil --get LocalHostName`)
