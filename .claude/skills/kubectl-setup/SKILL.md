---
name: kubectl-setup
description: Use when the user asks to "install kubectl", "set up kubens", "configure kubernetes CLI tools", or needs to make kubectl/kubens/kubectx replicable via dotfiles Ansible package list.
---

# kubectl + kubens/kubectx Setup

## State (as of 2026-08)

- `kubectl` 1.36.1 — installed via `brew install kubectl`
- `kubectx` / `kubens` 0.11.0 — installed, managed via Ansible
- `k9s` — installed, managed via Ansible

## Package list (ansible/group_vars/all/main.yml)

All three tools are in `brew_packages` (see ADR-0002 — `brew/Brewfile` was removed,
`group_vars` is the source of truth):

```yaml
brew_packages:
  - k9s
  - kubectl
  - kubectx
```

## Aliases

`k` alias comes from the OMZ `kubectl` plugin (already in `.zshrc` plugins list).
Do NOT duplicate it in `aliases.zsh` — it's already provided by OMZ.

In `zsh/aliases.zsh`:
```bash
alias kns='kubens'
alias kx='kubectx'
```

## Replicating on a new machine

Handled by the `install` tag in the Ansible playbook (see `ansible/README.md`):

```bash
ansible-playbook playbooks/site.yml --limit <profile>-mac --tags install
```

Aliases come automatically from stow + OMZ `kubectl` plugin.

## Notes

- `colima start --kubernetes` creates a separate local cluster context navigable with `kx`
- `kubectx` uses `~/.kube/config` — contexts are added by cloud CLIs (e.g. `aws eks update-kubeconfig`)
- zsh completions installed automatically by Homebrew to `/opt/homebrew/share/zsh/site-functions`
