# Auto-detect an expired/missing SSO session for the kube context a command
# targets and trigger `aws sso login` before running kubectl/k9s against it.
# Honours --context, skips purely local subcommands, and caches a successful
# check for _KUBE_LOGIN_TTL seconds.

zmodload zsh/datetime
typeset -gA _KUBE_LOGIN_OK
: ${_KUBE_LOGIN_TTL:=300}

# Print the context targeted by the arguments: --context/--context=X, else the
# current context.
function _kube_context_from_args() {
  local i
  for ((i = 1; i <= $#; i++)); do
    case "${@[i]}" in
      --context) print -r -- "${@[i+1]}"; return ;;
      --context=*) print -r -- "${${@[i]}#--context=}"; return ;;
    esac
  done
  command kubectl config current-context 2>/dev/null
}

# Succeed when the kubectl invocation never talks to a cluster
# (config, completion, help, options, plugin, kustomize, version --client).
function _kube_is_local_cmd() {
  local a skip=0
  for a in "$@"; do
    if ((skip)); then skip=0; continue; fi
    case "$a" in
      --context|--kubeconfig|--cluster|--user|-n|--namespace|-s|--server) skip=1 ;;
      -*) ;;
      config|completion|help|options|plugin|kustomize) return 0 ;;
      version) [[ " $* " == *" --client "* || " $* " == *" --client=true "* ]] && return 0; return 1 ;;
      *) return 1 ;;
    esac
  done
  return 0
}

# Print the AWS_PROFILE set in the exec block of the given context's user.
function _kube_profile_for_context() {
  command kubectl config view --minify --context "$1" \
    -o jsonpath='{.users[0].user.exec.env[?(@.name=="AWS_PROFILE")].value}' 2>/dev/null
}

# Ensure there's a valid SSO session for the AWS profile behind the targeted
# kube context, logging in interactively if it's missing/expired.
function _kube_ensure_login() {
  local ctx profile now=$EPOCHSECONDS
  ctx=$(_kube_context_from_args "$@")
  [[ -z "$ctx" ]] && return 0
  profile=$(_kube_profile_for_context "$ctx")
  [[ -z "$profile" ]] && return 0

  (( now - ${_KUBE_LOGIN_OK[$profile]:-0} < _KUBE_LOGIN_TTL )) && return 0

  if ! aws sts get-caller-identity --profile "$profile" \
      --cli-connect-timeout 5 --cli-read-timeout 10 >/dev/null 2>&1; then
    echo "→ SSO session for profile '$profile' (context '$ctx') is missing/expired, logging in..." >&2
    aws sso login --profile "$profile" || return 1
  fi
  _KUBE_LOGIN_OK[$profile]=$now
}

function kubectl() {
  _kube_is_local_cmd "$@" || _kube_ensure_login "$@" || return 1
  command kubectl "$@"
}

function k9s() {
  _kube_is_local_cmd "$@" || _kube_ensure_login "$@" || return 1
  command k9s "$@"
}
