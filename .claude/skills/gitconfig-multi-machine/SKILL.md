---
name: gitconfig-multi-machine
description: Use when user needs to manage gitconfig across multiple machines (work vs personal), handle machine-specific git settings, or set up local git overrides without polluting shared dotfiles.
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

### Work machine override (`~/.gitconfig-local`, not in repo)
```ini
[user]
    email = name@company.com
    signingkey = /Users/work-username/.ssh/id_ed25519.pub
```

### Verification
```bash
git config user.email
git config user.signingkey
git commit --allow-empty -m "test signing" && git reset HEAD~
```
