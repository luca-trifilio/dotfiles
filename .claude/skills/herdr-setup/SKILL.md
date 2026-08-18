---
name: herdr-setup
description: Use when the user asks to "set up herdr", "configure herdr sessions", "herdr vs tmux", "herdr LaunchAgent", or needs to install/configure Herdr (herdr.dev) as a terminal workspace manager, including named persistent sessions for isolating work contexts.
---

# Herdr Setup

Terminal workspace manager for AI coding agents — candidate tmux replacement.

## Concept model

Session (background server, own socket/log) > Workspace (project-level,
git branch/status tracking) > Tab (layout within a workspace) > Pane
(actual terminal). Agent = detected process in a pane with state:
working/blocked/done/idle/unknown.

**Session is NOT a lightweight grouping** like tmux sessions — it's a
separate server process. Two sessions = two sockets, two independent
sidebars, explicit switching. Don't reach for multiple sessions just for
visual grouping; use workspaces for that (shown together in one sidebar).

Design guidance for splitting sessions vs workspaces:
- Need real isolation (context A must never appear while in context B) →
  separate sessions
- Need per-project git tracking / worktree / close / rename to work
  cleanly → workspace = project, not session = project and tab = project
- Tabs are layout only, inside one workspace — never a substitute for
  either of the above

## Install

Via Homebrew (`brew "herdr"` in `ansible/group_vars/all/main.yml` for this
repo), not the curl install.sh script — keeps it inside the same
declarative package management as every other CLI tool. If a curl-installed
binary exists on PATH (e.g. `~/.local/bin/herdr`), remove it after
installing via brew so the two don't shadow each other; `brew install`
warns about this ("shadowed by...") — take the warning seriously,
`hash -r` after removing the old one.

## Named persistent sessions via LaunchAgent

`herdr server --session <name>` runs a named session's server. Each gets
its own subdir: `~/.config/herdr/sessions/<name>/` (socket + log), separate
from the unnamed `default` session's server (which `brew services start
herdr` manages by default).

To make a named session persistent (survive reboot/login), template a
LaunchAgent per session — see this repo's pattern:
- `ansible/roles/macos/templates/herdr-session.plist.j2` — parameterized
  by session name via task-level `vars:`
- Deployed with `ansible.builtin.template` + idempotent
  `launchctl bootstrap gui/{{ ansible_user_uid }}` guarded by checking
  `launchctl print` rc first
- Reload handler does `bootout` then `bootstrap` on config change

Gotcha: when looping a `template` task with a custom variable name for
readability, either use a matching `loop_control.loop_var` AND reference
that name consistently everywhere in the task, or simpler — keep the loop
variable as `item` and only introduce the friendly name via task-level
`vars: { friendly_name: "{{ item }}" }` for use inside the template/dest
string. Mixing `loop_control.loop_var: X` with `{{ item }}` elsewhere in
the same task is a real, easy-to-make bug — `ansible-playbook --check`
catches it immediately ("'item' is undefined").

## Safety — `herdr session stop`/`delete` is disruptive

These commands drop any client currently attached to that session without
warning — no confirmation prompt, no graceful detach notice to the user.
**Never run session stop/delete against a session the user might be live
in** (especially an unnamed `default` or any session name that could
collide with real, in-use sessions) without explicitly confirming with the
user first. For throwaway testing, use an unambiguous scratch name
(e.g. `herdr-scratch-test`), never a name that matches or could later
become a real session in the design being discussed.

Always run `herdr session list` before any stop/delete to see what's
actually running and what's attached.

## tmux relationship — do not nest

Herdr is designed to replace tmux, not run inside it — confirmed by a
herdr maintainer closing github.com/herdrdev/herdr#2135 as "not planned".
Nesting is technically possible (`experimental.allow_nested`, off by
default) but has known unfixed clipboard/OSC52 bugs (#2057, #2056).
Detach from tmux (prefix+d) before launching herdr standalone, or open a
fresh terminal window not attached to any tmux client.

## Shell gotcha — `autocd` intercepting the command

If a shell hasn't rehashed its PATH since herdr was installed (e.g. just
switched from curl-install to Homebrew), typing `herdr` while `autocd`
is enabled (Oh My Zsh default) and a same-named directory exists in the
cwd (e.g. a `herdr/` dotfiles package dir) silently `cd`s into the
directory instead of running the command — no error, no explanation.
Fix: `hash -r`, or open a new shell.

## Config

`herdr config check` validates config.toml without launching the TUI.
`herdr --default-config` prints the full commented default reference.
Settings changed via herdr's own in-app Settings UI write directly back
to config.toml — if that file is a stow-managed symlink into a dotfiles
repo, those changes land in the tracked file automatically, no manual
sync needed (but also no diff review before it happens — check
`git diff` after a herdr settings session if you want to see what
changed).
