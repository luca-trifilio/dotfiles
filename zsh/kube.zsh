# Auto-detect an expired/missing SSO session for the active kube context
# and trigger `aws sso login` before running kubectl/k9s against it.

# Print the AWS_PROFILE configured in the exec block of the given kube
# context's user entry (yq required).
function _kube_profile_for_context() {
  local ctx="$1"
  local user
  user=$(yq eval ".contexts[] | select(.name == \"$ctx\") | .context.user" ~/.kube/config)
  [[ -z "$user" || "$user" == "null" ]] && return 1
  yq eval ".users[] | select(.name == \"$user\") | .user.exec.env[]? | select(.name == \"AWS_PROFILE\") | .value" ~/.kube/config
}

# Ensure there's a valid SSO session for the AWS profile behind the current
# kube context, logging in interactively if it's missing/expired.
function _kube_ensure_login() {
  local ctx profile
  ctx=$(command kubectl config current-context 2>/dev/null) || return 0
  profile=$(_kube_profile_for_context "$ctx")
  [[ -z "$profile" ]] && return 0

  if ! aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
    echo "→ SSO session for profile '$profile' (context '$ctx') is missing/expired, logging in..." >&2
    aws sso login --profile "$profile" || return 1
  fi
}

function kubectl() {
  _kube_ensure_login || return 1
  command kubectl "$@"
}

function k9s() {
  _kube_ensure_login || return 1
  command k9s "$@"
}
