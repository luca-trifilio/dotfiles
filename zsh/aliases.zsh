alias ls='eza --icons'
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
  SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" \
    ansible-playbook "$dotfiles_dir/ansible/playbooks/site.yml" \
    --limit "$limit" \
    --ask-become-pass
}
alias kns='kubens'
alias kx='kubectx'

function ts() { ~/.config/tmux/session-picker.sh }

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
