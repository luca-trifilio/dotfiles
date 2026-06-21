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
CURRENT_HOSTNAME="$(ansible -m setup localhost -a 'filter=ansible_hostname' -i localhost, --connection=local 2>/dev/null \
  | grep -o '"ansible_hostname": "[^"]*"' | cut -d'"' -f4)"
if [ -z "$CURRENT_HOSTNAME" ]; then
  CURRENT_HOSTNAME="$(hostname -s)"
fi

WORK_HOSTNAME="$(grep 'expected_hostname' "$ANSIBLE_DIR/group_vars/work/main.yml" | cut -d'"' -f2)"
PERSONAL_HOSTNAME="$(grep 'expected_hostname' "$ANSIBLE_DIR/group_vars/personal/main.yml" | cut -d'"' -f2)"

PROFILE="${DOTFILES_PROFILE:-}"
if [ -z "$PROFILE" ]; then
  if [ "$CURRENT_HOSTNAME" = "$WORK_HOSTNAME" ]; then
    PROFILE="work"
    echo "── Detected profile: work (hostname: $CURRENT_HOSTNAME)"
  elif [ "$CURRENT_HOSTNAME" = "$PERSONAL_HOSTNAME" ]; then
    PROFILE="personal"
    echo "── Detected profile: personal (hostname: $CURRENT_HOSTNAME)"
  else
    echo ""
    echo "⚠ Unknown hostname: '$CURRENT_HOSTNAME'"
    echo "  Known work:     $WORK_HOSTNAME"
    echo "  Known personal: $PERSONAL_HOSTNAME"
    echo ""
    echo "Which machine profile is this?"
    select choice in work personal; do
      [ -n "$choice" ] && PROFILE="$choice" && break
    done
    # Update expected_hostname in group_vars so next run auto-detects
    sed -i '' "s/expected_hostname: .*/expected_hostname: \"$CURRENT_HOSTNAME\"/" \
      "$ANSIBLE_DIR/group_vars/$PROFILE/main.yml"
    echo "── Updated expected_hostname for '$PROFILE' to '$CURRENT_HOSTNAME'"
  fi
fi

case "$PROFILE" in
  work|personal) ;;
  *) echo "Invalid profile: '$PROFILE' (expected 'work' or 'personal')" >&2; exit 1 ;;
esac

# ── Run ─────────────────────────────────────────────────────────────────────
echo "── Running Ansible for profile: $PROFILE"
cd "$ANSIBLE_DIR"
exec ansible-playbook playbooks/site.yml --limit "${PROFILE}-mac" --ask-become-pass "$@"
