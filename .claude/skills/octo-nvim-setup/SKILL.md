---
name: octo-nvim-setup
description: Use when Octo.nvim shows "You are not logged into any accounts on <host>", "error connecting to github", "Cannot request Projects", or a gh token-scope error — troubleshooting Octo.nvim auth and GitHub Projects access in this dotfiles repo.
---

## Octo shows "not logged into <ssh-alias>" / "error connecting to github"

Octo determines the API host by running `git remote get-url origin`. This
command applies git's `insteadOf` URL rewriting — so a repo whose remote was
set via the `github-personal` SSH alias (see `gitconfig-multi-machine` skill
and `gitconfig/.gitconfig`'s `[url "git@github-personal:..."] insteadOf`
rules) reports back `git@github-personal:...`, not `github.com`. Octo takes
that literal string as the hostname, and since `gh` only has auth configured
for `github.com`, every request fails.

**Does NOT fix it**: pointing the remote at the canonical
`git@github.com:...` form and relying on `insteadOf` to rewrite it under the
hood. `git remote get-url` (and `git remote -v`) both apply the rewrite when
displaying/resolving the URL, so Octo still sees the alias either way. Only
`git config --get remote.origin.url` returns the raw, unrewritten value —
and Octo doesn't use that.

**Fix**: map the alias back to the real host in Octo's config
(`nvim/lua/plugins/coding.lua`):

```lua
{
  "pwntester/octo.nvim",
  opts = {
    ssh_aliases = { ["github-personal"] = "github.com" },
  },
},
```

This mapping is inert on machines whose remotes don't use the alias (e.g. a
work Mac using direnv-injected HTTPS tokens instead) — safe to keep
unconditional in the shared nvim config rather than branching on machine
profile.

## Octo shows "Cannot request Projects" / "gh: Your token has not been granted the required scopes"

The `gh` CLI token (stored in macOS Keychain — check with `gh auth status`,
look for `(keyring)`) lacks the `project`/`read:project` scope needed for
GitHub Projects (v2) GraphQL queries. Regular repo/PR/issue operations work
fine without it, so this only surfaces when opening Octo's Projects view.

**Fix**: refresh the token with the extra scope (opens a device-code browser
flow — give the user the URL + code, this is not something you can complete
non-interactively):

```bash
gh auth refresh -h github.com -s project,read:project
```

Verify with `gh auth status` — scopes list should now include `project`.

## Debugging checklist

```bash
gh auth status                        # confirms login + lists granted scopes
git remote get-url origin             # what Octo actually sees (post-insteadOf)
git config --get remote.origin.url    # raw configured value (not what Octo sees)
```
