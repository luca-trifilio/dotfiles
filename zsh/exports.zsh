export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH
export PATH="$HOME/.opencode/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"

export EDITOR=$(which nvim)
export VISUAL=$EDITOR
export SUDO_EDITOR=$EDITOR

export XDG_CONFIG_HOME="$HOME/.config"

export STARSHIP_CONFIG=~/.config/starship/starship.toml

export _ZO_DOCTOR=0

# SOPS age key
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# Colima — Testcontainers config
# /var/run/docker.sock is symlinked to the colima XDG socket at boot via launchd.
# DOCKER_HOST is intentionally unset — the active docker context (colima) handles routing.
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
# Pin the Docker API version: the docker-java client used by Testcontainers
# defaults to an old API (1.32) that Colima's Docker engine rejects ("too old").
export DOCKER_API_VERSION=1.41
