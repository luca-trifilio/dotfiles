#!/usr/bin/env bash
# rtk-wrapper.sh — NOT managed by `rtk init`, so it survives re-init.
# Claude Code runs hooks with a restricted PATH (/usr/bin:/bin:...) that
# omits Homebrew, so a bare `rtk` is not found and the hook fails silently
# (see chopratejas/headroom#487). Inject Homebrew's bin, then exec rtk.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
exec rtk hook claude
