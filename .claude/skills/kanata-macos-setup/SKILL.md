---
name: kanata-macos-setup
description: Use when the user asks to "set up kanata", "replace karabiner",
  "remap caps lock", "key remapper macOS", or needs to configure kanata as a
  Karabiner-Elements replacement on macOS.
---

## Context

On macOS, kanata uses the Karabiner DriverKit VirtualHIDDevice for output.
KE app can be fully uninstalled — only the VirtualHID driver must remain.
Kanata must run as root via LaunchDaemon (not LaunchAgent).

## File layout in dotfiles

| Path | Purpose |
|---|---|
| `kanata/kanata.kbd` | Config (XDG, stowed to `~/.config/kanata/`) |
| `kanata-daemon/com.lucatrifilio.kanata.plist` | LaunchDaemon template (excluded from stow, installed to `/Library/LaunchDaemons/` via setup.sh) |

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

Use `__HOME__` as placeholder — setup.sh substitutes it with `$HOME` at install time.

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
        <string>__HOME__/.config/kanata/kanata.kbd</string>
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
# Install kanata LaunchDaemon (substitute $HOME at install time)
sed "s|__HOME__|$HOME|g" "$(pwd)/kanata-daemon/com.lucatrifilio.kanata.plist" \
  | sudo tee /Library/LaunchDaemons/com.lucatrifilio.kanata.plist > /dev/null
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
# karabiner-elements cask NOT needed — only VirtualHID driver required,
# which persists after uninstalling KE app
```

## Manual steps (new machine)

1. Add `/opt/homebrew/bin/kanata` to **System Settings → Privacy & Security → Input Monitoring**
2. Remove leftover KE entries from Input Monitoring if present

## KE cleanup (new machine)

After setup.sh disables KE daemons, remove KE app files:

```bash
sudo rm -rf '/Applications/Karabiner-Elements.app'
sudo rm -rf '/Applications/Karabiner-EventViewer.app'
sudo rm -rf '/Library/Application Support/org.pqrs/Karabiner-Elements'
```

Leave `/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice` intact.

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
