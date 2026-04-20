bindkey -v
KEYTIMEOUT=1

function zle-keymap-select zle-line-init {
  case $KEYMAP in
    vicmd)      print -n '\e[1 q' ;;  # block cursor — normal mode
    viins|main) print -n '\e[5 q' ;;  # beam cursor — insert mode
  esac
  zle reset-prompt
}
zle -N zle-keymap-select
zle -N zle-line-init

# Restore beam cursor when shell exits or runs a command
preexec() { print -n '\e[5 q'; }
