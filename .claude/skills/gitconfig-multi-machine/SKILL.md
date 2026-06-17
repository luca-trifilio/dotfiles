---
name: gitconfig-multi-machine
description: This skill should be used when the user asks to "set up work email in git", "different git email per machine", "gitconfig work vs personal", "local git override", or needs to manage machine-specific git identity without polluting shared dotfiles.
---

## Strategy: base personal config in repo + machine-local override

`gitconfig/.gitconfig` (stowed to `~/.gitconfig`) holds personal defaults.
`~/.gitconfig-local` (never committed, never stowed) holds machine-specific overrides.

Git processes includes in order and applies **last-value-wins** for every key — so anything in `~/.gitconfig-local` silently overrides the base. The base file ends with:

```ini
[include]
    path = ~/.gitconfig-local
```

Git silently ignores a missing include path — safe on machines without the override file.

---

## What goes where

**In repo** (`gitconfig/.gitconfig`, stowed to `~/`):
- Personal name + email as defaults
- SSH commit signing
- Shared tooling: delta pager, credential helpers, fetch.prune, init.defaultBranch
- `[include]` for `~/.config/git/catppuccin.gitconfig` (delta themes, stowed via `git/` XDG package)
- `[include]` for `~/.gitconfig-local` at the very end

**NOT in repo** — `~/.gitconfig-local` only:
- Work email (on work machine)
- `[includeIf]` for work-only project dirs
- Any credential helper specific to corporate SSO/proxies

---

## How overrides work

### Simple keys — last-value-wins

```ini
# ~/.gitconfig-local
[user]
    email = luca@company.com     # overrides personal email ✓

[delta]
    side-by-side = false         # overrides base delta config ✓

[core]
    pager = less                 # overrides delta pager ✓
```

### Credential helpers — they accumulate, not override

Credential helpers are an exception: Git collects ALL helper entries across all included files. To replace them, use the empty-string reset pattern:

```ini
# ~/.gitconfig-local
[credential "https://github.com"]
    helper =                     # clears all previously loaded helpers for this host
    helper = /path/to/corp-helper
```

---

## Stow setup

`gitconfig/` is a home-target package — excluded from `stow .` and handled separately:

`.stowrc` must have:
```
--ignore=^gitconfig$
```

`setup.sh` must have:
```bash
stow --target="$HOME" gitconfig
```

On a new machine, after `./setup.sh`, `~/.gitconfig` is a symlink to `dotfiles/gitconfig/.gitconfig`.

---

## Work machine bootstrap

After cloning dotfiles and running `setup.sh`, create `~/.gitconfig-local`:

```ini
[user]
    email = luca@company.com

# Optional: per-project email override
[includeIf "gitdir:~/Progetti/work-project/"]
    path = ~/.gitconfig-work-project
```

Where `~/.gitconfig-work-project` (also never committed) can hold further per-repo overrides if needed.

---

## Verification

```bash
# Check effective identity
git config user.name
git config user.email

# Check which file a value comes from
git config --show-origin user.email

# Test SSH signing (requires ssh-agent with key loaded)
git commit --allow-empty -m "test signing" && git reset HEAD~

# See full resolved config
git config --list --show-origin
```

---

## Common mistakes

**Do NOT put work email or work-only `[includeIf]` in the shared base config.**
If it accidentally gets committed, it affects all machines pulling the dotfiles. Revert and push immediately.

**Do NOT remove the `[include] path = ~/.gitconfig-local` line from the base config.**
Without it, overrides on work machine have no effect.

**Do NOT stow `~/.gitconfig-local`.**
It must remain a plain file on each machine, never tracked.

**Broken symlink scenario** — if `gitconfig/` package is removed from the repo but `.stowrc` still excludes it, `~/.gitconfig` becomes a dangling symlink that silently breaks git identity. Fix:

```bash
rm ~/.gitconfig
# Either restore the package in the repo and re-stow, or create a plain local file
stow --target="$HOME" gitconfig
```

---

## Conflict resolution (if work config slipped into repo)

```bash
git add gitconfig/.gitconfig && git commit -m "gitconfig: restore personal email as default"
git rebase origin/main
# On conflict: keep local version (personal email, no work-only blocks)
git add gitconfig/.gitconfig && GIT_EDITOR=true git rebase --continue
```
