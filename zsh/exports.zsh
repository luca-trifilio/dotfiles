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

# Colima — Docker socket for Testcontainers
export DOCKER_HOST="unix://${HOME}/.config/colima/default/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
