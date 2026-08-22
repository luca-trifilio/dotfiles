# CLI secrets, decrypted from a SOPS+age store into the environment so that
# auth-requiring tools (and agents driving them) run without interactive prompts.
#
# Sourced from .zshenv, not .zshrc: non-interactive shells (scripts, and the
# shells coding agents spawn) never read .zshrc, and those are exactly the
# shells that need the credentials.
#
# Fail-soft by design: with no age key, no store, or no sops binary, every
# function here no-ops silently rather than breaking the shell.
#
# Edit values with `secrets-edit` ($EDITOR on decrypted content, re-encrypts on
# save). Never paste secret values into a command line — they land in history.

# Per-machine override (gitignored) for machines where homelab isn't cloned
# at the default path, e.g.: echo 'CLI_SECRETS_FILE=~/wherever/homelab/secrets/cli.sops.yaml' > ~/.config/zsh/secrets.local.zsh
[[ -r ~/.config/zsh/secrets.local.zsh ]] && source ~/.config/zsh/secrets.local.zsh

: ${CLI_SECRETS_FILE:="$HOME/Progetti/homelab/secrets/cli.sops.yaml"}

# .zshenv runs before PATH is set up, so locate sops explicitly.
_cli_secrets_sops() {
  local candidate
  for candidate in /opt/homebrew/bin/sops /usr/local/bin/sops /usr/bin/sops; do
    [[ -x "$candidate" ]] && { print -r -- "$candidate"; return 0 }
  done
  whence -p sops 2>/dev/null
}

# age key lives in different places per OS (XDG on Linux, Application Support on macOS)
if [[ ! -r "$SOPS_AGE_KEY_FILE" ]]; then
  for _key in "$HOME/.config/sops/age/keys.txt" \
              "$HOME/Library/Application Support/sops/age/keys.txt"; do
    [[ -r "$_key" ]] && export SOPS_AGE_KEY_FILE="$_key" && break
  done
  unset _key
fi

_cli_secrets_load() {
  [[ -r "$CLI_SECRETS_FILE" && -r "$SOPS_AGE_KEY_FILE" ]] || return 0

  local sops_bin decrypted line
  sops_bin=$(_cli_secrets_sops) || return 0
  [[ -n "$sops_bin" ]] || return 0

  decrypted=$("$sops_bin" -d --output-type dotenv "$CLI_SECRETS_FILE" 2>/dev/null) || return 0

  while IFS= read -r line; do
    [[ -z "$line" || "$line" == '#'* ]] && continue
    export "$line"
  done <<< "$decrypted"

  # Terraform reads TF_VAR_cloudflare_api_token; alias it instead of storing
  # the same token twice in the encrypted store.
  [[ -n "$CLOUDFLARE_API_TOKEN" ]] && export TF_VAR_cloudflare_api_token="$CLOUDFLARE_API_TOKEN"

  # Children inherit the exports, so they can skip decrypting again.
  export CLI_SECRETS_LOADED=1
}
[[ -n "$CLI_SECRETS_LOADED" ]] || _cli_secrets_load

secrets-edit() { "$(_cli_secrets_sops)" "$CLI_SECRETS_FILE"; }

# Re-read the store into the current shell after editing it.
secrets-reload() { unset CLI_SECRETS_LOADED; _cli_secrets_load && print "secrets reloaded"; }

# List which secrets are loaded, never their values.
secrets-status() {
  local name
  print "store: $CLI_SECRETS_FILE"
  print "key:   ${SOPS_AGE_KEY_FILE:-<none found>}"
  for name in CLOUDFLARE_API_TOKEN B2_ACCESS_KEY_ID B2_SECRET_ACCESS_KEY; do
    if [[ -n "${(P)name}" ]]; then print "  set    $name"; else print "  empty  $name"; fi
  done
  if [[ -n "$TF_VAR_cloudflare_api_token" ]]; then
    print "  set    TF_VAR_cloudflare_api_token (aliased from CLOUDFLARE_API_TOKEN)"
  else
    print "  empty  TF_VAR_cloudflare_api_token"
  fi
}

# Backblaze B2 speaks the S3 API, so tooling expects the AWS_* names. Map them
# only for the wrapped command: exporting AWS_ACCESS_KEY_ID globally would
# shadow the AWS_PROFILE set in aws.zsh and silently break real AWS work.
with-b2() {
  if [[ -z "$B2_ACCESS_KEY_ID" || -z "$B2_SECRET_ACCESS_KEY" ]]; then
    print -u2 "with-b2: B2 credentials not loaded (run secrets-status)"
    return 1
  fi
  AWS_ACCESS_KEY_ID="$B2_ACCESS_KEY_ID" \
  AWS_SECRET_ACCESS_KEY="$B2_SECRET_ACCESS_KEY" \
  AWS_PROFILE="" \
    "$@"
}
