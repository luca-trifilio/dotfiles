#!/usr/bin/env bash
# setup.sh — thin wrapper that drives the Ansible setup.
#
# Run ./bootstrap.sh first (Homebrew + base prereqs — Ansible can't install those).
#
# Profile selection:
#   DOTFILES_PROFILE=work ./setup.sh        # or personal
#   ./setup.sh                              # prompts if DOTFILES_PROFILE is unset
#
# Extra args are forwarded to ansible-playbook, e.g.:
#   DOTFILES_PROFILE=personal ./setup.sh --check --diff --tags stow
set -euo pipefail
cd "$(dirname "$0")"

ANSIBLE_DIR="$(pwd)/ansible"

# ── Ansible ─────────────────────────────────────────────────────────────────
if ! command -v ansible-playbook &>/dev/null; then
  echo "── Ansible not found — installing via pip3 (--user)"
  pip3 install --user ansible
  # ensure the freshly installed binaries are on PATH for this run
  export PATH="$HOME/.local/bin:$HOME/Library/Python/$(python3 -c 'import sys;print(f"{sys.version_info.major}.{sys.version_info.minor}")')/bin:$PATH"
fi

# ── Collections ─────────────────────────────────────────────────────────────
echo "── Installing Ansible collections"
ansible-galaxy collection install -r "$ANSIBLE_DIR/requirements.yml"

# ── Profile ─────────────────────────────────────────────────────────────────
PROFILE="${DOTFILES_PROFILE:-}"
if [ -z "$PROFILE" ]; then
  echo ""
  echo "Which machine profile?"
  select choice in work personal; do
    [ -n "$choice" ] && PROFILE="$choice" && break
  done
fi

case "$PROFILE" in
  work|personal) ;;
  *) echo "Invalid profile: '$PROFILE' (expected 'work' or 'personal')" >&2; exit 1 ;;
esac

# ── Run ─────────────────────────────────────────────────────────────────────
echo "── Running Ansible for profile: $PROFILE"
cd "$ANSIBLE_DIR"
exec ansible-playbook playbooks/mac.yml --limit "${PROFILE}-mac" --ask-become-pass "$@"
