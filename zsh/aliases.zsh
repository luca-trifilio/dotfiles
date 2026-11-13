alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias lt='eza --tree --icons'
alias n='nvim'
alias cheat='open ~/Progetti/dotfiles/cheatsheet.html'
alias c='clear'
alias python=python3
alias pip=pip3
alias cdd='cd ~'
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

function dotfiles-apply() {
  local dotfiles_dir="$HOME/Progetti/dotfiles"
  case "$(hostname -s)" in
    0876-Pro-14)                 local limit=work-mac ;;
    MacBook-Pro-M4-Max-di-Luca) local limit=personal-mac ;;
    *) echo "dotfiles-apply: unknown hostname"; return 1 ;;
  esac
  # ansible.cfg (inventory, roles_path) is only read from the cwd: run from ansible/.
  # Subshell so the caller's cwd is untouched.
  (
    cd "$dotfiles_dir/ansible" || return 1
    SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" \
      ansible-playbook playbooks/site.yml \
      --limit "$limit" \
      --ask-become-pass
  )
}
alias kns='kubens'
alias kx='kubectx'

alias hp='herdr --session personal'
alias hw='herdr --session work'

alias floci-ui='open http://localhost:4566/_floci/ui'

function ts() { ~/.config/tmux/session-picker.sh }

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Work machine only: `claude` uses the work login, `clp` runs Claude Code with the personal login
# (separate config dir, so a one-time `/login` with the personal account is needed)
if [[ "$(<~/.config/zsh/machine_profile)" == work ]]; then
  alias clp='CLAUDE_CONFIG_DIR="$HOME/.claude-personal" claude'
fi

# Claude Code through the local LiteLLM proxy (~/Progetti/Personale/llm-proxy); starts the containers if needed.
# Plain `claude` bypasses the proxy.
claude-proxy() {
  local dir=~/Progetti/Personale/llm-proxy url=http://localhost:4000
  if ! curl -fsS -m 2 "$url/health/liveliness" >/dev/null 2>&1; then
    docker info >/dev/null 2>&1 || { echo "claude-proxy: docker is not running" >&2; return 1; }
    echo "claude-proxy: starting proxy containers..." >&2
    docker compose --project-directory "$dir" up -d >/dev/null || return 1
    local i
    for i in {1..40}; do
      curl -fsS -m 2 "$url/health/liveliness" >/dev/null 2>&1 && break
      sleep 2
    done
    curl -fsS -m 2 "$url/health/liveliness" >/dev/null 2>&1 || { echo "claude-proxy: proxy did not become healthy" >&2; return 1; }
  fi
  env -u ANTHROPIC_AUTH_TOKEN -u ANTHROPIC_API_KEY \
    ANTHROPIC_BASE_URL=$url \
    ANTHROPIC_CUSTOM_HEADERS="x-litellm-api-key: Bearer $(<$dir/.claude-code.key)" \
    command claude "$@"
}
