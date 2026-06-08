---
name: kubectl-setup
description: Use when the user asks to "install kubectl", "set up kubens", "configure kubernetes CLI tools", or needs to make kubectl/kubens/kubectx replicable via dotfiles Brewfile.
---

# kubectl + kubens/kubectx Setup

## State (as of 2026-06)

- `kubectl` 1.36.1 — installed via `brew install kubectl`
- `kubectx` / `kubens` 0.11.0 — installed, managed via Brewfile
- `k9s` — installed, managed via Brewfile

## Brewfile (brew/Brewfile)

All three tools are in `brew/Brewfile` under the CLI tools section:

```
brew "k9s"
brew "kubectl"
brew "kubectx"
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

```bash
brew bundle --file=brew/Brewfile
```

Aliases come automatically from stow + OMZ `kubectl` plugin.

## Notes

- `colima start --kubernetes` creates a separate local cluster context navigable with `kx`
- `kubectx` uses `~/.kube/config` — contexts are added by cloud CLIs (e.g. `aws eks update-kubeconfig`)
- zsh completions installed automatically by Homebrew to `/opt/homebrew/share/zsh/site-functions`
