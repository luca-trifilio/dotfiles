# ADR-0004: Pin Karabiner-DriverKit-VirtualHIDDevice to v6.2.0

**Date**: 2026-07-07
**Status**: Accepted

## Context

Kanata (used as a Karabiner-Elements replacement for caps-lock remapping) depends on the `Karabiner-DriverKit-VirtualHIDDevice` driver as its output bridge. `brew install --cask karabiner-elements` always installs the latest driver release, which reached v8.0.0 by 2026-07. Kanata's own release notes — including its latest, v1.12.0 (2026-07-05) — document support only up to driver v6.2.0. Driver v7.0.0+ introduced breaking protocol changes with no clear error surfaced to kanata: it simply loops `connect_failed asio.system:2` forever, and the daemon logs show it binding successfully but never completing a peer handshake with kanata. This is hard to diagnose because the failure looks identical to an ordinary HID-device-conflict or daemon-not-running problem. Kanata's maintainer has no macOS hardware and does not validate this integration, so the drift between driver releases and kanata's supported ceiling goes uncaught upstream.

## Decision

Pin the installed `Karabiner-DriverKit-VirtualHIDDevice` package to v6.2.0 by installing pqrs-org's official standalone pkg directly (`gh release download v6.2.0 --repo pqrs-org/Karabiner-DriverKit-VirtualHIDDevice`, checksum-verified), overriding whatever version the `karabiner-elements` brew cask most recently installed. This requires no reboot or driver-extension re-approval, since the bundle/team ID is unchanged between driver versions — only a daemon + kanata LaunchDaemon restart.

## Alternatives Considered

- **Remove Karabiner-Elements entirely, run only the driver**: tried during this incident and made things worse. The full KE app bundle hosts the `Karabiner-VirtualHIDDevice-Daemon` LaunchDaemon plist; there is no supported standalone-driver-only install, so removing the app removed the daemon's launch mechanism too.
- **Drop kanata, configure remapping in Karabiner-Elements directly**: rejected — loses kanata's more expressive/portable config format and cross-machine setup already in place.
- **Wait for kanata upstream to support newer drivers**: rejected as sole strategy — no ETA, and the immediate need was a working keyboard.

## Consequences

The keyboard remapping setup is now decoupled from whatever driver version `brew` considers "latest." Any future `brew upgrade`/`brew reinstall --cask karabiner-elements` will silently re-pull the incompatible latest driver and must be followed by re-applying this downgrade — documented as a troubleshooting entry in the `kanata-macos-setup` skill, including the diagnostic (`fs_usage` trace, `pkgutil --pkg-info` version check) to recognize the symptom versus an ordinary HID-conflict issue. This should be revisited if kanata upstream adds explicit support for newer driver protocol versions.
