export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

source ~/.config/zsh/exports.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/tmux.zsh

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Docker CLI completions
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit

source ~/.config/zsh/vimode.zsh
source ~/.config/zsh/zoxide.zsh
eval "$(starship init zsh)"
