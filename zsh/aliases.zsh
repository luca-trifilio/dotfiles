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

function ts() { ~/.config/tmux/session-picker.sh }

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
