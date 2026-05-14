#!/usr/bin/env zsh

session=$(tmux list-sessions -F '#{session_name}' | fzf \
  --height=100% --border=none \
  --preview 'tmux list-windows -t {} -F "  #{window_index}: #{window_name}  #{?window_active,(active),}"' \
  --preview-window=right:50% \
  --prompt='session > ' \
  --header='Enter → session  Tab → pick window' \
  --bind='j:down,k:up' \
  --expect='tab')

[[ -z "$session" ]] && exit 0

key=$(echo "$session" | head -1)
session=$(echo "$session" | tail -1)

if [[ "$key" == "tab" ]]; then
  window=$(tmux list-windows -t "$session" \
    -F '#{window_index}: #{window_name}  #{?window_active,(active),}' \
    | fzf --height=100% --border=none \
          --prompt='window > ' \
          --header="$session" \
          --bind='j:down,k:up' \
    | cut -d: -f1)
  [[ -z "$window" ]] && exit 0
  tmux switch-client -t "${session}:${window}"
else
  tmux switch-client -t "$session"
fi
