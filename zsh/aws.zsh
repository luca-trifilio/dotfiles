# Switch AWS profile with fzf fuzzy search, or directly by name
function awsp() {
  local profile
  if [[ -n "$1" ]]; then
    profile="$1"
  else
    profile=$(grep '^\[profile' ~/.aws/config | sed 's/\[profile //;s/\]//' | fzf --prompt="AWS profile: " --height=40%)
  fi
  [[ -z "$profile" ]] && return 1
  export AWS_PROFILE="$profile"
  echo "→ AWS_PROFILE=$AWS_PROFILE"
}

# Launch e1s with fzf profile picker (falls back to $AWS_PROFILE if set, else picks interactively)
function e1s() {
  local profile
  profile=$(grep '^\[profile' ~/.aws/config | sed 's/\[profile //;s/\]//' | fzf --prompt="AWS profile for e1s: " --height=40%)
  [[ -z "$profile" ]] && return 1
  command e1s --profile "$profile" "$@"
}

# Clear current AWS profile
function awsclear() {
  unset AWS_PROFILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
  echo "→ AWS profile cleared"
}
