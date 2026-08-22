#!/bin/zsh
# Kills Karabiner Core-Service/agents whenever KE Settings.app revives them,
# so kanata keeps exclusive HID access. See kanata-macos-setup skill.

USER_UID="$1"

for svc in \
  system/org.pqrs.service.daemon.Karabiner-Core-Service; do
  launchctl bootout "$svc" 2>/dev/null
done

for agent in \
  org.pqrs.service.agent.Karabiner-Core-Service \
  org.pqrs.service.agent.Karabiner-Core-Service-rev2 \
  org.pqrs.service.agent.karabiner_console_user_server \
  org.pqrs.service.agent.karabiner_session_monitor \
  org.pqrs.service.agent.Karabiner-NotificationWindow; do
  launchctl bootout "gui/${USER_UID}/${agent}" 2>/dev/null
done

exit 0
