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
  aws sso login --profile "$profile"
  command e1s --profile "$profile" "$@"
}

# Clear current AWS profile
function awsclear() {
  unset AWS_PROFILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
  echo "→ AWS profile cleared"
}

# SSO login with fzf profile picker, then export AWS_PROFILE.
# Refreshes the CodeArtifact token afterwards and pulls it into this shell.
function awslogin() {
  local profile
  if [[ -n "$1" ]]; then
    profile="$1"
  else
    profile=$(grep '^\[profile' ~/.aws/config | sed 's/\[profile //;s/\]//' | fzf --prompt="SSO login: " --height=40%)
  fi
  [[ -z "$profile" ]] && return 1

  aws sso login --profile "$profile" || return 1
  export AWS_PROFILE="$profile"
  echo "→ AWS_PROFILE=$AWS_PROFILE"

  # LaunchAgent WatchPaths may not have fired yet; refresh synchronously.
  if [[ -x ~/bin/refresh-codeartifact-token.sh ]]; then
    ~/bin/refresh-codeartifact-token.sh && catoken
  fi
}

# Pull the CodeArtifact token from launchctl into the current shell.
# Needed because `launchctl setenv` only reaches processes started after it.
function catoken() {
  local token
  token=$(launchctl getenv CODEARTIFACT_AUTH_TOKEN)
  if [[ -z "$token" ]]; then
    echo "✗ CODEARTIFACT_AUTH_TOKEN not set — run: ~/bin/refresh-codeartifact-token.sh" >&2
    return 1
  fi
  export CODEARTIFACT_AUTH_TOKEN="$token"
  echo "→ CODEARTIFACT_AUTH_TOKEN set (${#token} chars)"
}
