# ADR-0005: Herdr Session/Workspace Design — Session as Area, Workspace as Project

**Date**: 2026-08-18
**Status**: Accepted

## Context

Herdr (herdr.dev) was adopted as a trial replacement for tmux. Its model is Session (a background server process with its own socket/log — not a lightweight UI grouping) > Workspace (project-level, aggregates git branch/status tracking and scopes actions like `close_workspace`, `rename_workspace`, and git worktrees) > Tab (a layout within one workspace) > Pane (terminal). A mapping was needed for two personal/work "areas" of work and the individual projects/repos worked on within each, given that both areas can coexist on either machine on a given day.

## Decision

Session = area: two named, persistent sessions (`personal`, `work`), each a separate herdr server process with its own LaunchAgent, giving real process isolation — work cannot appear while attached to personal. Workspace = project: one workspace per repo/project, living inside whichever session it belongs to, keeping git tracking and workspace-scoped actions meaningful per project. Tab stays a layout within one project workspace (e.g. editor+shell / agent split), unchanged from Herdr's design intent. A pre-existing unnamed `default` session remains as an informal catch-all, untouched by this design. Both `personal` and `work` sessions are configured on both machines, since they're areas of work, not machine profiles.

## Alternatives Considered

**Tab = area** (personal/work as two tabs inside one shared workspace): rejected because a tab is layout-only inside a single workspace — it shares one sidebar entry and has no process or config isolation, far shallower than the real isolation required. **Workspace = area, tab = project** (two workspaces "personal"/"work", each project as a tab inside): rejected because git branch/status tracking and worktree/close/rename/rename_workspace actions are all workspace-scoped in Herdr's API, not tab-scoped — cramming multiple unrelated repos as tabs under one workspace makes git context ambiguous and workspace-level actions operate on the wrong granularity (the whole area instead of one project).

## Consequences

Git branch/status tracking and workspace-scoped actions (close, rename, worktree create/remove) now operate at the correct granularity — one project — instead of an ambiguous area-wide scope. Real isolation between personal and work is achieved, matching the explicit requirement that work must never appear while attached to personal. The trade-off is a heavier footprint than tmux's lightweight session concept: two separate background server processes run persistently via two LaunchAgents, and switching between personal/work requires an explicit session attach (`herdr --session personal` / `--session work`, aliased to `hp`/`hw`) rather than a single unified sidebar glance across both areas.
