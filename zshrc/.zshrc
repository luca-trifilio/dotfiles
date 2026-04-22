export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git kubectl aws fzf-tab zsh-syntax-highlighting zsh-autosuggestions)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
fpath=($HOME/.docker/completions $fpath)
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

source ~/.config/zsh/exports.zsh
source ~/.config/zsh/history.zsh
source ~/.config/zsh/completions.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/tmux.zsh
source ~/.config/zsh/aws.zsh

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

source ~/.config/zsh/vimode.zsh
eval "$(atuin init zsh)"
eval "$(starship init zsh)"
source ~/.config/zsh/zoxide.zsh
