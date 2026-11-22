---
name: colima-setup
description: This skill should be used when the user asks to "set up Colima", "replace Docker Desktop", "install Colima", "configure Testcontainers with Colima", or needs a free Docker Desktop alternative on macOS.
---

# Colima Setup — Docker Desktop replacement on macOS

## Purpose

Replace Docker Desktop with Colima (free, open source) on macOS Apple Silicon,
configured for Java Testcontainers with Ryuk support.

## Prerequisites

- macOS Apple Silicon (aarch64)
- Homebrew installed
- `docker` CLI already present (or install via `brew install docker`)
- Dotfiles at `~/Progetti/dotfiles`, managed with GNU Stow

## Installation

```bash
brew install colima
```

## First start (saves profile)

```bash
colima start --cpus 4 --memory 8 --disk 100 --network-address
```

`--network-address` assigns a static IP to the VM — required for Testcontainers Ryuk
to reach the VM from the host. Without it, Ryuk fails at test startup.

## Enable autostart at login

```bash
brew services start colima
```

## Configure env vars for Testcontainers

Add to `~/Progetti/dotfiles/zsh/exports.zsh`:

```bash
# Colima — Testcontainers config
# /var/run/docker.sock is symlinked to the colima XDG socket at boot via launchd.
# DOCKER_HOST is intentionally unset — the active docker context (colima) handles routing.
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
# Pin the Docker API version: the docker-java client used by Testcontainers
# defaults to an old API (1.32) that Colima's Docker engine rejects ("too old").
export DOCKER_API_VERSION=1.41
```

Do NOT set `DOCKER_HOST` — it overrides the active docker context and causes routing issues.

Then reload: `source ~/.zshrc`

## ~/.testcontainers.properties

Verify (or create) `~/.testcontainers.properties` contains:

```properties
docker.client.strategy=org.testcontainers.dockerclient.UnixSocketClientProviderStrategy
```

No need for `ryuk.disabled=true` — Ryuk works with Colima when
`--network-address` is used and `TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE` is set.

## Verify setup

```bash
colima list                        # should show: Running, aarch64, address assigned
docker run --rm hello-world        # should print "Hello from Docker!"
docker context list                # colima should be active (*)
```

## Notes

- Socket path: `~/.config/colima/default/docker.sock` (not `/var/run/docker.sock`)
- Colima creates a Docker context named `colima` automatically on first start
- Idle memory on host: ~74 MB (limactl processes); VM allocates lazily via
  Apple Virtualization Framework — does not physically reserve 8 GB upfront
- Docker Desktop can coexist during transition; switch context with
  `docker context use colima` / `docker context use desktop-linux`

## Uninstall Docker Desktop (after validation)

```bash
brew uninstall --cask docker
```

## Cleanup after manual Docker Desktop removal

If Docker Desktop was removed by hand (without `brew uninstall --cask docker`),
broken symlinks can remain in `/usr/local/bin`:

```bash
ls -la /usr/local/bin/docker* 2>/dev/null
# if they point to /Applications/Docker.app (gone) → remove them
sudo rm /usr/local/bin/docker /usr/local/bin/docker-compose
sudo rm /usr/local/bin/docker-credential-desktop /usr/local/bin/docker-credential-osxkeychain
# ignore "no such file or directory" for ones already missing
```

Then install the standalone docker CLI:

```bash
brew install docker
```

## Fix: Colima XDG config (`~/.colima` → `~/.config/colima`)

Colima creates `~/.colima` by default and reads `XDG_CONFIG_HOME` only if that directory
doesn't exist yet. `brew services` regenerates the LaunchAgent plist from the formula on every
start/restart/upgrade, **never including `XDG_CONFIG_HOME`** — so a one-shot migration
(`mv ~/.colima ~/.config/colima`) or a plist patch regresses on the next reboot
(looks fixed, then the problem returns).

**Permanent fix:** make `~/.colima` a **symlink** to `~/.config/colima` instead of moving
the directory. Colima always resolves `~/.colima` first, so it lands on the XDG directory
however the service starts — no dependency on an env var brew can drop.

**Ansible handles this** (task `Symlink ~/.colima to ~/.config/colima` in
`roles/macos/tasks/main.yml`, idempotent — reapplied every run).

Manual (without Ansible):

```bash
colima stop
rm -rf ~/.colima          # or: mv ~/.colima ~/.config/colima if it still holds real data
ln -sfn ~/.config/colima ~/.colima
colima start
```

The warning `found ~/.colima, ignoring $XDG_CONFIG_HOME` keeps appearing with the symlink
(colima can't tell a real directory from a symlink) — cosmetic, ignore it: `colima status`
still shows `docker socket: unix:///Users/.../.colima/default/docker.sock`, which resolves to
`~/.config/colima/default/docker.sock`.

## Fix: `/var/run/docker.sock` missing or pointing to Docker Desktop

After removing Docker Desktop, `/var/run/docker.sock` may be missing or point to
`~/.docker/run/docker.sock` (gone). Testcontainers fails with
`Could not find a valid Docker environment`.

**Ansible handles this** via a LaunchDaemon (`com.lucatrifilio.colima-docker-sock`)
installed in `/Library/LaunchDaemons/`. The daemon recreates the symlink at boot:

```
/var/run/docker.sock → ~/.config/colima/default/docker.sock
```

Manual (without Ansible):

```bash
sudo ln -sf "$HOME/.config/colima/default/docker.sock" /var/run/docker.sock
```

**Note:** the manual fix doesn't survive reboots — use the Ansible LaunchDaemon.

## Fix: `default` docker context points to a missing path

The `default` context is built in and can't be removed or updated. If it shows a wrong
path (e.g. `~/.colima/default/docker.sock`), ignore it — cosmetic.
Check that the `colima` context is active (`*`) with `docker context list`.

If `DOCKER_HOST` is set in the shell, it overrides the active context and shows
`default *` even when colima is selected. Fix: don't set `DOCKER_HOST`.
