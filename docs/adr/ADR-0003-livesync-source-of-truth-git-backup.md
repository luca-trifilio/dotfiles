# ADR-0003: Obsidian LiveSync as Vault Source of Truth, Git as Subordinate Backup

---
id: ADR-0003
title: Obsidian LiveSync as Vault Source of Truth, Git as Subordinate Backup
status: Accepted
date: 2026-06-22
---

## Context

The "Taccuino Cerusico" Obsidian vault is synced across machines and also backed up to git. Notes started accumulating git conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) committed directly into their content, corrupting them.

Root cause: an orphan launchd backup job ran `git merge origin/main` *before* committing local changes and *without* checking the merge exit code — on a failed merge it proceeded to `git add -A` (staging the markers), commit, and push. The problem was amplified by two machines (work + personal Mac) pushing to the same GitHub repo, producing concurrent backups that diverged on the same lines.

The vault already syncs content via the Obsidian LiveSync plugin (CouchDB), which resolves content conflicts before files reach the disk. Git and LiveSync were implicitly treated as co-equal sync paths, which is the design flaw.

## Decision

LiveSync (CouchDB) is the **single source of truth** for vault content. Git is a **subordinate backup only**, never a sync path. Concretely:

1. The git backup runs **only from the personal Mac**, gated by the Ansible toggle `enable_obsidian_backup` (true only in the `personal` profile).
2. Because LiveSync has already resolved content before files hit disk, the git backup treats **local as authoritative**. Strategy: `commit → fetch → rebase -X ours origin/main → conflict-marker guard → push`. No blind `merge`, no `--force`.
3. On the work Mac, `.git` was removed entirely — the vault there is managed purely by LiveSync.

## Alternatives Considered

- **Multi-device backup with `git merge`**: rejected — it caused the original conflict markers and requires every device to reconcile remote content it doesn't own.
- **Mono-source with `git push --force`**: rejected — simpler, but silently destroys remote history if the remote ever advances (manual commit, future second device), causing silent data loss.

## Consequences

**Positive:**
- Conflict markers can no longer be committed into notes (commit-first + rebase + pre-push marker guard).
- No concurrent-push races (single backup source).
- Clear ownership: content questions → LiveSync; backup/history → git on personal Mac.

**Negative / Trade-offs:**
- The work Mac has no local git history of the vault (acceptable: backup lives on the personal Mac, content lives in LiveSync).
- `rebase -X ours` means a genuine remote-only edit on the same lines is silently dropped in favor of local — tolerable under the mono-source assumption.
- Reintroducing a second backup source requires revisiting this decision.
