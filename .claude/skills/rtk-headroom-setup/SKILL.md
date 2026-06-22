---
name: rtk-headroom-setup
description: Use when the user asks to "set up rtk", "set up headroom", "verify rtk/headroom", manage Claude Code token tooling, debug the rtk hook, or fix the `rtk gain` "No hook installed" warning in dotfiles.
---

# rtk + headroom Setup

Two cooperating layers cut Claude Code token usage. Installed and wired by Ansible; both apply to
**work and personal** profiles (shared scope — nothing per-profile).

| Layer | Role | Lives in repo at |
|---|---|---|
| **rtk** | Rewrites dev commands so output is token-compact, via a `PreToolUse` hook | `ansible/group_vars/all/main.yml` → `brew_packages` (homebrew-core) + `claude/.claude/hooks/rtk-rewrite.sh` (stow) |
| **headroom** | Local proxy `127.0.0.1:8787`, compresses API payloads | `uv tool install headroom-ai` in `ansible/roles/shell/tasks/main.yml` |

Pipeline: `command → rtk (compact output) → request → headroom (compress payload) → Anthropic`.

Both layers land on every host because rtk is in the `all` group, the headroom task is in the
untagged-by-profile `shell` role, and the hook ships in the `claude` stow package. Nothing needs
to be added to `group_vars/work` or `group_vars/personal`.

## Hook registration in `~/.claude/settings.json`

The hook script must be **declared** in `~/.claude/settings.json` under `hooks.PreToolUse` —
without this entry Claude Code never calls the wrapper, even if the file exists.

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/rtk-rewrite.sh"
        }
      ]
    }
  ]
}
```

`settings.json` is **not stowable** — Claude Code rewrites it continuously (permissions, plugins,
model, etc.). The Ansible `shell` role patches it automatically via a `jq`-based shell task
(idempotent: checks for `rtk-rewrite.sh` in the existing PreToolUse array before patching).
After running `--tags shell` on a new machine, the hook is live.

## The rtk hook — never run `rtk init -g`

The hook at `~/.claude/hooks/rtk-rewrite.sh` is **versioned in the `claude` stow package**
(`claude/.claude/hooks/rtk-rewrite.sh`). It:

1. Injects `PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"` — Claude Code runs hooks with a
   restricted PATH (`/usr/bin:/bin:…`) that omits Homebrew (chopratejas/headroom#487).
2. Checks for `jq` and `rtk` (exits 0 silently if missing).
3. Guards against rtk < 0.23.0 (when `rtk rewrite` was added).
4. Calls `rtk rewrite "$CMD"` and returns a JSON `updatedInput` block if a rewrite applies.

Do NOT run `rtk init -g` or `rtk init -g --auto-patch`: both overwrite the hook, losing the
PATH fix. `--auto-patch` also resets the sha256 hash (see next section).

## rtk sha256 integrity check

rtk verifies `~/.claude/hooks/.rtk-hook.sha256` on **every run** — a hash mismatch blocks all
rtk commands with an error. This file must stay in sync with the hook content.

**Automatic**: the `stow` role recomputes the hash after every stow run:
```yaml
- name: Update rtk hook integrity hash
  ansible.builtin.shell:
    cmd: >
      shasum -a 256 "~/.claude/hooks/rtk-rewrite.sh" |
      awk '{print $1 "  rtk-rewrite.sh"}' > "~/.claude/hooks/.rtk-hook.sha256"
```

**Manual fix** (if hash mismatch outside Ansible):
```zsh
shasum -a 256 ~/.claude/hooks/rtk-rewrite.sh \
  | awk '{print $1 "  rtk-rewrite.sh"}' \
  > ~/.claude/hooks/.rtk-hook.sha256
rtk verify   # should print PASS
```

The `.rtk-hook.sha256` file is a real file (not stowed) — rtk writes to it directly.

## `rtk gain` "No hook installed" is a FALSE POSITIVE

`rtk gain` only recognizes its own `rtk init` signature, not the custom wrapper. The hook is
working as long as `rtk gain` shows a non-zero command count.

## ANTHROPIC_BASE_URL is not versioned

`headroom wrap` sets it at runtime — do not commit it anywhere. Launch Claude through the proxy
with the alias defined in `zshrc/.zshrc`:

```zsh
alias hrclaude='headroom wrap claude --no-rtk'   # --no-rtk stops headroom re-running rtk init
```

## Verify

```zsh
rtk --version                      # homebrew-core build (not a name-collision rtk)
rtk verify                         # PASS + sha256 hash
rtk gain                           # non-zero command count → hook active
uv tool list | grep headroom       # headroom-ai installed
# inside a `hrclaude` session:
lsof -nP -iTCP:8787 -sTCP:LISTEN   # proxy listening
echo "$ANTHROPIC_BASE_URL"         # → http://127.0.0.1:8787
```

## Reading files while headroom is active

headroom compresses tool output, so `Read`/`cat`/`grep` may return `[N items compressed... hash=…]`
instead of the full content. Retrieve the original with the headroom MCP `headroom_retrieve` tool,
passing that hash. The same applies to `Read` calls — a stale-read error may actually be compressed
output that was never seen in full; retrieve by hash.

Note: headroom hashes **expire between sessions** — retrieve while in the same session.

## Notes

- `rtk` is in homebrew-core (no custom tap). Watch for a name collision with `reachingforthejack/rtk`
  (Rust Type Kit) — verify with `which rtk` → `/opt/homebrew/bin/rtk` and `rtk gain` working.
- The `bootstrap.sh` / Ansible `shell` role installs `headroom-ai` via `uv` (uv is in `brew_packages_dev`).
- **`.stowrc` gotcha**: `--ignore=^\.claude$` would silently block stow from deploying the `.claude/`
  directory inside the `claude` package. Only `--ignore=^claude$` is needed (excludes the package
  from `stow .`). If the hook symlink is never created, check `.stowrc` for this pattern.
