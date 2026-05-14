unalias tmux 2>/dev/null
tmux() {
  if [[ $# -eq 0 ]]; then
    command tmux new-session -A -s home
  else
    command tmux "$@"
  fi
}
