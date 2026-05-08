---
name: gitconfig-multi-machine
description: This skill should be used when the user asks to "set up work email in git", "different git email per machine", "gitconfig work vs personal", "local git override", or needs to manage machine-specific git identity without polluting shared dotfiles.
---

## Pattern: base config personal + local override per machine

Base `.gitconfig` (stowed, in repo) holds personal defaults. Machine-specific overrides live in `~/.gitconfig-local` (not stowed, never committed).

### Base config rules
- Use `~` instead of absolute paths (`signingkey = ~/.ssh/id_ed25519.pub`)
- Use personal email as default
- Add at the end:
  ```ini
  [include]
      path = ~/.gitconfig-local
  ```
  Git silently ignores missing includes — safe on machines without the file.

### What belongs in the repo vs on the machine

**In repo** (`gitconfig/.gitconfig`, stowed):
- Personal email as default
- Shared tooling (delta, credential helpers, includeIf for dotfiles repo)
- `[includeIf]` for project dirs that exist on ALL machines (e.g. `~/Progetti/dotfiles/`)

**NOT in repo** — machine-specific only (`~/.gitconfig-local`):
- Work email
- `[includeIf]` for work project dirs (e.g. `~/Progetti/brio/`) — they only exist on the work machine

### Work machine override (`~/.gitconfig-local`, not in repo)
```ini
[user]
    email = name@company.com
[includeIf "gitdir:~/Progetti/work-project/"]
    path = ~/.gitconfig-personal
```

### Common mistake to avoid
Do NOT put work email or work-only `[includeIf]` blocks in the shared `.gitconfig`. If a commit from the work machine changes the default email to the work one, revert it — it will affect all machines that pull the dotfiles.

### Conflict resolution (if a bad commit slipped in)
```bash
# Commit correct local state, then rebase on remote
git add gitconfig/.gitconfig && git commit -m "gitconfig: restore personal email as default"
git rebase origin/main
# On conflict: keep local version (personal email, no work-only includeIf)
git add gitconfig/.gitconfig && GIT_EDITOR=true git rebase --continue
```

### Verification
```bash
git config user.email
git config user.signingkey
git commit --allow-empty -m "test signing" && git reset HEAD~
```
