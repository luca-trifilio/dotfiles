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
model, etc.). Add this block manually on a fresh machine, or run the Ansible task in
`roles/shell/tasks/main.yml` that patches it (see below).

The Ansible task uses `community.general.json_patch` to insert the `hooks` key idempotently so the
rest of the file is left untouched. After running `--tags shell` on a new machine, the hook is live.

## The rtk hook — never run `rtk init -g`

The hook at `~/.claude/hooks/rtk-rewrite.sh` is **versioned in the `claude` stow package**
(`claude/.claude/hooks/rtk-rewrite.sh`), not created by `rtk init`. It injects Homebrew's bin into
PATH before `exec rtk hook claude`, because Claude Code runs hooks with a restricted PATH
(`/usr/bin:/bin:…`) that omits Homebrew — a bare `rtk` fails silently (chopratejas/headroom#487).

Do NOT run `rtk init -g`: it overwrites the wrapper with a bare hook that hits exactly that bug.

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

## Notes

- `rtk` is in homebrew-core (no custom tap). Watch for a name collision with `reachingforthejack/rtk`
  (Rust Type Kit) — verify with `which rtk` → `/opt/homebrew/bin/rtk` and `rtk gain` working.
- The `bootstrap.sh` / Ansible `shell` role installs `headroom-ai` via `uv` (uv is in `brew_packages_dev`).
