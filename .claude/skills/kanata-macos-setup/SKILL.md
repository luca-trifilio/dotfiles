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

**Critical**: kanata requires TWO components at boot:
1. `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice` — the kernel dext (usually auto-started)
2. `Karabiner-VirtualHIDDevice-Daemon` — the bridge daemon (needs its own LaunchDaemon)

If the daemon is missing, kanata loops with `connect_failed asio.system:61` at boot, which monopolizes the internal keyboard HID and blocks all input after login.

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

## LaunchDaemon plist templates

### 1. VirtualHIDDevice-Daemon (required — create if missing)

The daemon binary lives in `/Library/Application Support/org.pqrs/...` but has no LaunchDaemon plist by default after uninstalling KE. Must be created manually:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.pqrs.karabiner-virtualhiddevice-daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/karabiner-virtualhid-daemon.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/karabiner-virtualhid-daemon.log</string>
</dict>
</plist>
```

Install: write to `/tmp/` first (no sudo needed), then `sudo cp` to `/Library/LaunchDaemons/`.

### 2. Kanata LaunchDaemon

Kanata is invoked directly — no wrapper script needed. The VirtualHIDDevice-Daemon LaunchDaemon ensures the bridge is ready before kanata starts. Use `__HOME__` as placeholder — setup.sh substitutes it with `$HOME` at install time.

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

## Troubleshooting: keyboard blocked after boot

**Symptom**: internal keyboard works at login screen but stops after login. `cat /tmp/kanata.log` shows `connect_failed asio.system:61` in a loop.

**Cause**: kanata starts before `Karabiner-VirtualHIDDevice-Daemon` is ready, monopolizing the HID device.

**Diagnose**:
```bash
sudo launchctl list | grep -i "pqrs\|karabiner\|virtual"
# Should show VirtualHIDDevice-Daemon running. If missing, create its plist (see above).
ps aux | grep -E "kanata|VirtualHIDDevice-Daemon"
```

**Fix**:
1. Stop kanata: `sudo launchctl bootout system/com.lucatrifilio.kanata`
2. Create/start VirtualHIDDevice-Daemon plist if missing
3. Re-bootstrap kanata

**Note on `com.apple.provenance`**: files created via `sudo tee` get this xattr and become immutable even with sudo. Workaround: write to `/tmp/` first, then `sudo cp` to `/Library/LaunchDaemons/`.

## setup.sh steps

```bash
# Install VirtualHIDDevice-Daemon LaunchDaemon
sed "s|__HOME__|$HOME|g" "$(pwd)/kanata-daemon/org.pqrs.karabiner-virtualhiddevice-daemon.plist" \
  > /tmp/karabiner-vhid-daemon.plist
sudo cp /tmp/karabiner-vhid-daemon.plist /Library/LaunchDaemons/org.pqrs.karabiner-virtualhiddevice-daemon.plist
sudo launchctl bootout system/org.pqrs.karabiner-virtualhiddevice-daemon 2>/dev/null || true
sudo launchctl bootstrap system /Library/LaunchDaemons/org.pqrs.karabiner-virtualhiddevice-daemon.plist

# Install kanata LaunchDaemon (substitute $HOME at install time)
sed "s|__HOME__|$HOME|g" "$(pwd)/kanata-daemon/com.lucatrifilio.kanata.plist" \
  > /tmp/kanata.plist
sudo cp /tmp/kanata.plist /Library/LaunchDaemons/com.lucatrifilio.kanata.plist
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
