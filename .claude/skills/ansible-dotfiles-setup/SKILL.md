---
name: ansible-dotfiles-setup
description: This skill should be used when the user asks to run, update, or troubleshoot the Ansible dotfiles playbook, add packages/casks, configure work vs personal profiles, manage SOPS secrets, or bootstrap a new Mac.
---

# Ansible Dotfiles Setup

## Structure

```
ansible/
  ansible.cfg              # inventory, roles_path, vars_plugins_enabled
  inventory.yml            # work-mac + personal-mac (both ansible_connection: local)
  requirements.yml         # community.general >= 9.0.0, community.sops >= 1.6.0
  .sops.yaml               # age recipient for vault encryption
  playbooks/mac.yml        # single playbook, --limit selects profile
  group_vars/
    all/main.yml           # common packages, feature toggles, brew lists
    all/vault.sops.yaml    # SOPS-encrypted, BOTH profiles: ssh_homelab_hosts
    work/main.yml          # machine_profile, expected_hostname, brew_packages_extra
    work/vault.sops.yaml   # SOPS-encrypted, work only: work_git_email, cf_access_client_id/secret
    personal/main.yml      # machine_profile, expected_hostname, enable_docs
  roles/
    homebrew/              # taps → trust → formulae → casks
    shell/                 # OMZ, plugins, Bun, TPM, fzf-git
    stow/                  # XDG + home-target stow, gitconfig-local template
    macos/                 # karabiner, colima, kanata, yazi, docs, ssh homelab block
```

## Run commands

```bash
# From ansible/ directory

# Install + stow only (no sudo required)
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  ansible-playbook playbooks/mac.yml --limit work-mac --tags install,stow

# Full run (requires sudo for kanata LaunchDaemon)
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  ansible-playbook playbooks/mac.yml --limit work-mac --ask-become-pass

# Dry-run (check mode)
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  ansible-playbook playbooks/mac.yml --limit work-mac --check --diff

# Or via setup.sh wrapper (prompts for profile)
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt ./setup.sh
```

## Tags

| Tag | What it runs |
|-----|-------------|
| `install` | homebrew role (taps, packages, casks) |
| `shell` | shell role (OMZ, plugins, Bun, TPM) |
| `stow` | stow role (symlinks, gitconfig-local) |
| `macos` | macos role (karabiner, colima, kanata, yazi, docs) |
| `become` | tasks requiring sudo (kanata, KE agents) |

## Adding packages

- Common formulae: `group_vars/all/main.yml` → `brew_packages`
- Common casks: `group_vars/all/main.yml` → `brew_casks`
- Work-only formulae: `group_vars/work/main.yml` → `brew_packages_extra`
- Work-only casks: `group_vars/work/main.yml` → `brew_casks_extra`

## Known gotchas

**Homebrew 4.x tap trust**
Third-party taps (FelixKratz, nikitabobko, etc.) require explicit trust before their formulae/casks install. The `homebrew` role runs `brew trust <taps>` after `homebrew_tap`. If a new tap is added to `brew_taps`, trust is applied automatically on next run.

**Casks that install to /Applications/ require sudo**
`community.general.homebrew_cask` does not support `become`. Casks like `notion-calendar` that copy `.app` to `/Applications/` need `--ask-become-pass` at the playbook level. Run the full playbook with `--ask-become-pass` rather than `--tags install` alone.

**karabiner symlink must use `ln -sfn`**
`ansible.builtin.file: state=link, force=true` refuses to replace a non-empty directory. Use `ansible.builtin.command: ln -sfn <src> <dest>` — this replaces the directory entry without touching contents, matching the original `setup.sh` behavior.

**colima homebrew_services: use `state=present` not `state=started`**
`state=started` is not a valid value for `community.general.homebrew_services`. Use `state=present` to register the service for autostart.

**SOPS vault in --check mode**
Add `ignore_errors: "{{ ansible_check_mode }}"` to the `community.sops.load_vars` task. Without it, `--check` fails if the vault references variables that haven't been loaded.

**stow simulate+apply pattern**
Two-task pattern for `--check` compatibility:
1. Simulate: `stow --simulate`, `check_mode: false`, `changed_when: "'LINK:' in result.stderr"`
2. Apply: `stow` (no simulate), `when: not ansible_check_mode`

**ansible/ must be ignored in .stowrc**
Add `--ignore=^ansible$` to `.stowrc` to prevent stow from symlinking `ansible/` into `~/.config/`.

## Bootstrapping a new Mac

1. `git clone git@github.com:luca-trifilio/dotfiles.git ~/Progetti/dotfiles`
2. Copy age key: `cp /path/to/keys.txt ~/.config/sops/age/keys.txt`
3. Update `expected_hostname` in `group_vars/{work,personal}/main.yml` if needed (`hostname` to check)
4. Install ansible collections: `cd ansible && ansible-galaxy collection install -r requirements.yml`
5. Run: `SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt ansible-playbook playbooks/mac.yml --limit work-mac --ask-become-pass`
6. Manual steps (cannot be automated): Input Monitoring + Accessibility permissions for Karabiner, Driver Extension approval, `prefix + I` in tmux for TPM plugins

## SOPS vault

Encrypted with age. Key at `~/.config/sops/age/keys.txt`. Two vaults:

- `group_vars/all/vault.sops.yaml` — **both profiles**. Loaded unconditionally in `mac.yml` pre_tasks (gated only on sops being present). Contains `ssh_homelab_hosts` (homelab SSH host data: internal IPs, Tailscale addresses, usernames).
- `group_vars/work/vault.sops.yaml` — **work only** (`when: 'work' in group_names`). Contains `work_git_email`, `cf_access_client_id`, `cf_access_client_secret`.

```bash
# Edit a vault (sops opens decrypted in $EDITOR, re-encrypts on save)
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops ansible/group_vars/all/vault.sops.yaml

# Verify decryption
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops --decrypt ansible/group_vars/all/vault.sops.yaml
```

**Creation-rule gotcha**: `.sops.yaml` matches on `path_regex: \.sops\.yaml$` against the *input* filename. To `sops --encrypt` a new file from scratch, name it `*.sops.yaml` and use `--in-place` (or `--config ansible/.sops.yaml`). Encrypting a `/tmp/foo.yaml` fails with "no matching creation rules" and a `>` redirect will clobber the destination with empty output. Prefer `sops <file>` (edit-in-place) for existing vaults.

## SSH homelab block (~/.ssh/config)

The `macos` role manages a `blockinfile`-marked region in `~/.ssh/config` (marker `# {mark} ANSIBLE MANAGED BLOCK — homelab`), rendered from `ssh_homelab_hosts` (in the shared vault) via `roles/macos/templates/ssh_homelab.j2`. Toggle: `enable_ssh_homelab` in `group_vars/all/main.yml` (default true).

- Only the marked region is managed — colima `Include` lines and the `github.com`/`github-personal` identity blocks are untouched. Host patterns are disjoint, so the block can sit anywhere in the file without shadowing.
- The task tightens perms to `0600` and is gated on `ssh_homelab_hosts is defined` (skipped with a reminder if the vault wasn't loaded, e.g. before sops is installed).
- `proxy_command` is stored as a **literal absolute path** (`/opt/homebrew/bin/cloudflared`) — `blockinfile`'s `block:` lookup does NOT recursively re-template var values, so `{{ homebrew_prefix }}` inside a vault string would leak verbatim into the file.
- Verify the effective result with `ssh -G macserver` / `ssh -G vps-homelab` (resolves config without connecting).
