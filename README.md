# DebugDeck

A KDE Plasma 6 panel widget that gives you a real-time systemd journal monitor, log filtering, desktop notifications for errors, and a one-click launcher for common debugging tools — all from your taskbar.

![DebugDeck log monitor](screenshots/view-logmonitor.png)

## Features

- **Live journal tail** — streams entries from `journald` in real time, coloured by severity
- **Filtering** — search by text, filter by priority (All / Warning+ / Error+ / Critical), or pin a specific systemd unit
- **Desktop notifications** — sends KDE system notifications when errors or warnings arrive; fully configurable
- **Alert banner** — an in-widget slide-in banner highlights the latest error for 8 seconds
- **Compact badge** — the panel icon shows a live error/warning count so you always know something needs attention
- **Info bar** — a configurable header showing hostname, kernel, Plasma, Frameworks, Qt, window system, and live uptime
- **Tools tab** — one-click launchers for CPU, GPU, Bluetooth, USB, storage, network, and log utilities (btop, htop, nvtop, Wireshark, and more)

![DebugDeck tools panel](screenshots/view-tools.png)

## Screenshots

| Config – General | Config – Notifications | Example Notification |
|---|---|---|
| ![General config](screenshots/config-general.png) | ![Notifications config](screenshots/config-notifications.png) | ![Notification](screenshots/example-notification.png) |

## Requirements

DebugDeck includes a C++ plugin and must be built from source. There is no pre-built binary package.

| Dependency | Version | Notes |
|---|---|---|
| KDE Plasma | 6.0+ | |
| Qt6 | 6.x | Core, Qml, Quick, DBus |
| KDE Frameworks 6 | 6.x | CoreAddons, I18n, Notifications |
| CMake | 3.20+ | |
| `libsystemd` | any | optional — native journal fd; falls back to `journalctl` without it |

## Installation

### Install build dependencies

**Arch / Manjaro**
```bash
sudo pacman -S cmake extra-cmake-modules qt6-base qt6-declarative \
               kf6-coreaddons kf6-i18n kf6-notifications plasma-framework \
               systemd-libs
```

**Fedora / RHEL**
```bash
sudo dnf install cmake extra-cmake-modules qt6-qtbase-devel qt6-qtdeclarative-devel \
                 kf6-kcoreaddons-devel kf6-ki18n-devel kf6-knotifications-devel \
                 plasma-devel systemd-devel
```

**Ubuntu / Debian (KDE Neon recommended)**
```bash
sudo apt install cmake extra-cmake-modules qt6-base-dev qt6-declarative-dev \
                 libkf6coreaddons-dev libkf6i18n-dev libkf6notifications-dev \
                 libplasma-dev libsystemd-dev
```

### Build and install

The first install requires a full build to get the C++ plugin onto your system:

```bash
git clone https://github.com/ryansinn/debugdeck.git
cd debugdeck
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build
```

Then right-click your panel → *Add Widgets* → search **DebugDeck**.

### Updating (after first install)

Once the C++ plugin is installed, UI-only updates can be applied without rebuilding. Either:

- Install from the [KDE Store](https://store.kde.org) via *System Settings → Plasma Widgets → Get New Widgets* → search **DebugDeck**, or
- Download the `.plasmoid` from [GitHub Releases](https://github.com/ryansinn/debugdeck/releases) and run:

```bash
kpackagetool6 --type Plasma/Applet --upgrade debugdeck-X.Y.Z.plasmoid
```

Then restart Plasma to load the updated QML:

```bash
systemctl --user restart plasma-plasmashell.service
```

To update the C++ plugin itself, pull the latest source and rebuild.

### Uninstall

```bash
sudo cmake --build build --target uninstall
```

## Configuration

| Setting | Default | Description |
|---|---|---|
| Watched units | *(empty = all)* | Comma-separated systemd unit names to filter the journal stream |
| Max log rows | 5000 | Maximum entries kept in memory |
| Auto-start | on | Begin watching the journal as soon as the widget loads |
| Notifications | on | Send KDE system notifications for important log entries |
| Notify on | Errors+ | Minimum severity that triggers a notification |

### Info Bar

| Setting | Default | Description |
|---|---|---|
| Show info bar | on | Show/hide the entire info bar |
| Show icons | on | Show a small icon beside each field label |
| Value inline | off | Show value to the right of the label instead of stacked below |
| Hostname | on | Toggle the Hostname field |
| Kernel | on | Toggle the Kernel field |
| KDE Plasma Version | on | Toggle the Plasma version field |
| KDE Frameworks Version | on | Toggle the Frameworks version field |
| Qt Version | on | Toggle the Qt version field |
| Window System | on | Toggle the Window System field |
| Uptime | on | Toggle the live Uptime field |

Each field also accepts a custom short label (shown in the bar); the full descriptive name is always shown as a tooltip on hover. Leave the label blank to use the built-in default.

## License

GPL-2.0-or-later — see [LICENSE](LICENSE). See [CHANGELOG](CHANGELOG.md) for release history.
