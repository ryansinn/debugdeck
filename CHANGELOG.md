# Changelog

## [0.2.0] – 2026-03-01

### Added
- **Info bar** – a configurable header row at the top of the full view showing live system information sourced directly from `ksystemstats` (no extra C++ code):
  - Hostname, Kernel, KDE Plasma version, KDE Frameworks version, Qt version, Window System, and real-time Uptime (updates every ~1 s)
  - Each field can be individually shown or hidden
  - Custom short label per field (tooltip always shows the full descriptive name)
  - Global toggle to hide the entire info bar
  - **Layout modes** – *stacked* (label above, value below) or *inline* (label · value on one line); default is inline
  - **Icons** – optional small icon beside each label; default is off
  - All options configurable via the new **Info Bar** tab in the widget settings

### Changed
- Default info bar layout: inline mode, icons off
- Plasmashell reload instruction updated to use `systemctl --user restart plasma-plasmashell.service`

## [0.1.0] – initial release

- Live systemd journal tail with colour-coded severity
- Text search, priority filter (All / Warning+ / Error+ / Critical), unit pin filter
- Desktop notifications via KNotification (configurable severity threshold)
- In-widget slide-in alert banner (auto-hides after 8 s)
- Compact panel icon with live error/warning badge
- Tools tab with one-click launchers for common debugging utilities
