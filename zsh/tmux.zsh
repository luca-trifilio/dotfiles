unalias tmux 2>/dev/null
tmux() {
  if [[ $# -eq 0 ]]; then
    command tmux new-session -A -s scratch
  else
    command tmux "$@"
  fi
}
