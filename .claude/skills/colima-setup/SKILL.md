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
# Colima — Docker socket for Testcontainers
export DOCKER_HOST="unix://${HOME}/.config/colima/default/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
```

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
- `~/.config/zsh/exports.zsh` may be a hardlink (not symlink) to dotfiles source —
  edits propagate automatically to `~/Progetti/dotfiles/zsh/exports.zsh`
- Idle memory on host: ~74 MB (limactl processes); VM allocates lazily via
  Apple Virtualization Framework — does not physically reserve 8 GB upfront
- Docker Desktop can coexist during transition; switch context with
  `docker context use colima` / `docker context use desktop-linux`

## Uninstall Docker Desktop (after validation)

```bash
brew uninstall --cask docker
```

## Cleanup dopo rimozione manuale di Docker Desktop

Se Docker Desktop era già stato rimosso manualmente (senza `brew uninstall --cask docker`),
possono restare symlink rotti in `/usr/local/bin`:

```bash
ls -la /usr/local/bin/docker* 2>/dev/null
# se puntano ad /Applications/Docker.app (non esistente) → rimuoverli
sudo rm /usr/local/bin/docker /usr/local/bin/docker-compose
sudo rm /usr/local/bin/docker-credential-desktop /usr/local/bin/docker-credential-osxkeychain
# ignora "no such file or directory" per quelli già mancanti
```

Poi installa il docker CLI standalone:

```bash
brew install docker
```

## Fix: Colima XDG config (`~/.colima` → `~/.config/colima`)

Colima crea `~/.colima` per default, ma emette warning se `XDG_CONFIG_HOME` è impostato.
Per allinearlo all'XDG:

```bash
colima stop
mv ~/.colima ~/.config/colima
colima start
```

Verifica che nessun warning appaia: `colima status 2>&1 | grep -v info`.

## Fix: `/var/run/docker.sock` punta ancora a Docker Desktop

Dopo la rimozione di Docker Desktop, `/var/run/docker.sock` può puntare a
`~/.docker/run/docker.sock` (non più esistente). Testcontainers fallisce con
`Could not find a valid Docker environment`.

Fix:

```bash
sudo ln -sf "$HOME/.config/colima/default/docker.sock" /var/run/docker.sock
```

**Nota:** questo fix non persiste ai reboot. Per renderlo permanente usare le env var
`DOCKER_HOST` e `TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE` (già documentate nella sezione
"Configure env vars") — così Testcontainers non dipende da `/var/run/docker.sock`.
