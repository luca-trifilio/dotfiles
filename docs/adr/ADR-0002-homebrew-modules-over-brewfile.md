# ADR-0002: Use Ansible Homebrew Modules Instead of Brewfile as Package Source of Truth

---
id: ADR-0002
title: Use Ansible Homebrew Modules Instead of Brewfile as Package Source of Truth
status: Accepted
date: 2026-06-16
---

## Context

The dotfiles repo currently uses a single flat `brew/Brewfile` as the source of truth for
all Homebrew packages across all machines. During the Ansible migration, a decision was
needed on how to manage Homebrew packages: keep the Brewfile (running `brew bundle` from
Ansible) or migrate package lists into Ansible group_vars and use the
`community.general.homebrew*` modules directly.

The migration also introduces a work/personal machine split, creating a need to install
different packages on different machines.

## Decision

Migrate all package lists from `brew/Brewfile` into Ansible group_vars:
- `group_vars/all/main.yml`: `brew_taps`, `brew_packages`, `brew_casks` (common to all machines)
- `group_vars/work/main.yml`: `brew_packages_extra`, `brew_casks_extra` (work-only)
- `group_vars/personal/main.yml`: `brew_packages_extra`, `brew_casks_extra` (personal-only)

The `homebrew` role uses `community.general.homebrew_tap`, `community.general.homebrew`,
and `community.general.homebrew_cask` modules. The existing Brewfile is kept as a reference
backup but is no longer the run target.

## Alternatives Considered

- **Keep Brewfile + per-machine override files (`Brewfile.work`, `Brewfile.personal`)**: Minimal
  migration effort, familiar tooling. Rejected because `brew bundle` gives no per-package
  idempotency visibility to Ansible — `changed_when` relies on stdout parsing which is fragile
  and version-dependent. Work/personal split would be a second-class citizen managed outside
  Ansible's variable system.
- **Hybrid: `brew bundle` for common packages + modules for machine-specific extras**: Reduces
  migration effort but introduces two different package management mechanisms in the same role,
  making the mental model more complex without a clear long-term benefit.

## Consequences

**Positive:**
- Native Ansible `--check` mode works per-package without stdout parsing heuristics.
- Work/personal package differentiation is first-class via group_vars — the same mechanism
  used for all other machine-specific configuration.
- Full visibility into what is installed on each machine type directly from the inventory.
- Consistent with the homelab Ansible style (package lists in group_vars/all/main.yml).

**Negative / Trade-offs:**
- One-time migration effort: ~40+ packages must be manually triaged from the Brewfile into
  common/work/personal lists, with risk of miscategorisation.
- `brew bundle` can no longer be run standalone to restore packages without Ansible.
- Three separate modules (`homebrew_tap`, `homebrew`, `homebrew_cask`) replace the single
  `brew bundle` command, increasing role verbosity.
- `community.general >= 3.2` required; pinned in `requirements.yml`.
