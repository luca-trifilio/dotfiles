---
name: kanata-macos-setup
description: Use when the user asks to "set up kanata", "replace karabiner",
  "remap caps lock", "key remapper macOS", or needs to configure kanata as a
  Karabiner-Elements replacement on macOS.
---

## Context

On macOS, kanata uses the Karabiner DriverKit VirtualHIDDevice for output.
KE cannot be fully uninstalled — keep it installed but disable all its daemons.
Kanata must run as root via LaunchDaemon (not LaunchAgent).

## File layout in dotfiles

| Path | Purpose |
|---|---|
| `kanata/kanata.kbd` | Config (XDG, stowed to `~/.config/kanata/`) |
| `kanata-daemon/com.lucatrifilio.kanata.plist` | LaunchDaemon (excluded from stow, installed to `/Library/LaunchDaemons/` via setup.sh) |

Add `--ignore=^kanata-daemon$` to `.stowrc`.

## kanata.kbd template

```
(defcfg
  macos-dev-names-include (
    "Apple Internal Keyboard / Trackpad"
  )
  process-unmapped-keys yes
)

(defsrc
  caps
)

(deflayer base
  @cap
)

(defalias
  cap (tap-hold 200 200 esc lctl)
)
```

`macos-dev-names-include` is a whitelist — only listed devices are intercepted.
All others (external keyboards, Glove80, etc.) are ignored automatically.

## LaunchDaemon plist template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.lucatrifilio.kanata</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/kanata</string>
        <string>--cfg</string>
        <string>/Users/lucatrifilio/.config/kanata/kanata.kbd</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/kanata.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/kanata.log</string>
</dict>
</plist>
```

## setup.sh steps

```bash
# Install kanata LaunchDaemon
sudo cp "$(pwd)/kanata-daemon/com.lucatrifilio.kanata.plist" /Library/LaunchDaemons/
sudo launchctl bootout system/com.lucatrifilio.kanata 2>/dev/null || true
sudo launchctl bootstrap system /Library/LaunchDaemons/com.lucatrifilio.kanata.plist

# Disable KE daemons (keep only VirtualHID driver)
for agent in \
  org.pqrs.service.agent.Karabiner-Core-Service \
  org.pqrs.service.agent.Karabiner-Core-Service-rev2 \
  org.pqrs.service.agent.karabiner_console_user_server \
  org.pqrs.service.agent.karabiner_session_monitor \
  org.pqrs.service.agent.Karabiner-NotificationWindow; do
  launchctl disable gui/$(id -u)/$agent 2>/dev/null || true
  launchctl bootout gui/$(id -u)/$agent 2>/dev/null || true
done
sudo launchctl disable system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true
sudo launchctl bootout system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true
```

## Brewfile

```
brew "kanata"
cask "karabiner-elements"  # needed for VirtualHID driver
```

## Manual step (new machine)

Add `/opt/homebrew/bin/kanata` to **System Settings → Privacy & Security → Input Monitoring**.

## KE services reference

| Service | Keep? | Reason |
|---|---|---|
| `Karabiner-VirtualHIDDevice-Daemon` | YES | kanata output driver |
| `Karabiner-DriverKit-VirtualHIDDevice` | YES | kernel extension |
| `Karabiner-Core-Service` (daemon) | NO | karabiner_grabber |
| `Karabiner-Core-Service` (agent) | NO | KE UI agent |
| `karabiner_console_user_server` | NO | keyboard type dialog |
| `karabiner_session_monitor` | NO | session handling |
| `Karabiner-NotificationWindow` | NO | annoying dialog |
