# ADR-0001: Keep Stow as the Dotfiles Symlink Engine During Ansible Migration

---
id: ADR-0001
title: Keep Stow as the Dotfiles Symlink Engine During Ansible Migration
status: Accepted
date: 2026-06-16
---

## Context

The dotfiles repo is migrating from a pure Stow + bash script setup to Ansible for
orchestration (package install, launchd, services, secrets). During the migration design,
the question arose whether to replace Stow's symlink management with Ansible's native
`ansible.builtin.file: state=link` tasks, which would eliminate the Stow dependency
entirely and allow `--check` mode to work natively on symlink tasks.

## Decision

Keep Stow as the symlink engine. The Ansible `stow` role calls `stow --simulate` (for
`changed_when` detection) followed by `stow --no-folding` (guarded by
`when: not ansible_check_mode`). Stow is not replaced by Ansible-native file tasks.

## Alternatives Considered

- **`ansible.builtin.file: state=link` for every symlink**: Would enable native `--check`
  mode and remove the Stow dependency, but requires enumerating every symlink path
  explicitly in Ansible tasks. The current stow package set has 15+ XDG packages plus
  3 home-target packages, each potentially with deep subdirectory trees. Maintaining this
  list manually introduces toil and drift risk every time a new config file is added.
- **chezmoi instead of Stow**: A dedicated dotfile manager with templating and secrets
  support. Rejected because it would require a full rewrite of the symlink layer with no
  incremental migration path, and the existing Stow setup is well-understood.

## Consequences

**Positive:**
- Zero additional work to handle new config files — adding a file to a stow package just works.
- Consistent with the community-recommended hybrid pattern (Ansible for orchestration, Stow for symlinks).
- Operator familiarity: no new mental model needed for symlink management.
- `stow --simulate` provides explicit `changed_when` output without requiring Ansible to understand Stow's directory semantics.

**Negative / Trade-offs:**
- `--check` mode for the stow role is approximate: it relies on `stow --simulate` stderr parsing (`LINK:` string), which may vary across Stow versions.
- Stow remains a runtime dependency — a machine must have Stow installed before any symlinks are applied (handled by the `homebrew` role running first).
- The two-task pattern (simulate + apply) is slightly more verbose than a single Ansible file task.
