import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

// ─────────────────────────────────────────────────────────────────────────────
//  Common debugging & monitoring tool launcher
// ─────────────────────────────────────────────────────────────────────────────
QQC2.ScrollView {
    id: root

    // Passed in from main.qml via backend.item.launcher (Launcher singleton proxy).
    // Null-safe calls below (launcher?.run / launcher?.runInTerminal) mean buttons
    // are visible but inert if the plugin is somehow missing.
    property var launcher: null
    clip: true
    contentWidth: availableWidth

    component ToolButton: PlasmaComponents3.Button {
        property string program: ""
        property var    args:    []
        property string shellCmd: ""   // set this to run in a terminal instead
        property string tooltip: ""

        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 10
        display: QQC2.AbstractButton.TextBesideIcon
        onClicked: {
            if (shellCmd !== "")
                root.launcher?.runInTerminal(shellCmd)
            else
                root.launcher?.run(program, args)
        }

        PlasmaComponents3.ToolTip { text: parent.tooltip || parent.text }
    }

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.smallSpacing

        // ── CPU ──────────────────────────────────────────────────────────────
        Kirigami.ListSectionHeader { label: i18n("CPU") }
        GridLayout { columns: 3; columnSpacing: 4; rowSpacing: 4; Layout.fillWidth: true

            ToolButton { text: "btop";      icon.name: "utilities-system-monitor"
                         shellCmd: "btop";  tooltip: "Rich terminal CPU/mem/proc monitor (btop++)" }
            ToolButton { text: "htop";      icon.name: "utilities-system-monitor"
                         shellCmd: "htop";  tooltip: "Interactive process viewer (htop)" }
            ToolButton { text: "KSysGuard"; icon.name: "ksysguard"; program: "plasma-systemmonitor"
                         tooltip: "KDE System Monitor" }
            ToolButton { text: "stress-ng"; icon.name: "applications-engineering"
                         shellCmd: "stress-ng --cpu 0 --timeout 60s"
                         tooltip: "Run stress-ng CPU load test for 60 s" }
            ToolButton { text: "perf top";  icon.name: "show-gpu-effects"
                         shellCmd: "sudo perf top"
                         tooltip: "Live kernel perf profiler (requires perf)" }
        }

        // ── GPU ──────────────────────────────────────────────────────────────
        Kirigami.ListSectionHeader { label: i18n("GPU") }
        GridLayout { columns: 3; columnSpacing: 4; rowSpacing: 4; Layout.fillWidth: true

            ToolButton { text: "nvtop";         icon.name: "show-gpu-effects"
                         shellCmd: "nvtop";      tooltip: "GPU process monitor (NVIDIA/AMD/Intel)" }
            ToolButton { text: "radeontop";      icon.name: "show-gpu-effects"
                         shellCmd: "sudo radeontop"; tooltip: "AMD GPU load monitor" }
            ToolButton { text: "intel_gpu_top";  icon.name: "show-gpu-effects"
                         shellCmd: "sudo intel_gpu_top"; tooltip: "Intel GPU utilisation" }
            ToolButton { text: "glxinfo";        icon.name: "preferences-desktop-display"
                         shellCmd: "glxinfo | head -40"; tooltip: "OpenGL renderer info" }
            ToolButton { text: "amdgpu_top";      icon.name: "show-gpu-effects"
                         shellCmd: "amdgpu_top"; tooltip: "AMD GPU real-time monitor (amdgpu_top)" }
        }

        // ── Bluetooth ────────────────────────────────────────────────────────
        Kirigami.ListSectionHeader { label: i18n("Bluetooth") }
        GridLayout { columns: 3; columnSpacing: 4; rowSpacing: 4; Layout.fillWidth: true

            ToolButton { text: "bluetoothctl"; icon.name: "bluetooth"
                         shellCmd: "bluetoothctl"; tooltip: "Interactive Bluetooth CLI" }
            ToolButton { text: "btmon";         icon.name: "bluetooth"
                         shellCmd: "sudo btmon";   tooltip: "Bluetooth monitor (HCI packet sniffer)" }
            ToolButton { text: "BT Settings";   icon.name: "preferences-system-bluetooth"
                         program: "kcmshell6"; args: ["kcm_bluetooth"]
                         tooltip: "KDE Bluetooth settings" }
        }

        // ── USB ──────────────────────────────────────────────────────────────
        Kirigami.ListSectionHeader { label: i18n("USB") }
        GridLayout { columns: 3; columnSpacing: 4; rowSpacing: 4; Layout.fillWidth: true

            ToolButton { text: "lsusb";     icon.name: "drive-removable-media-usb"
                         shellCmd: "lsusb -v 2>&1 | less"; tooltip: "List USB devices" }
            ToolButton { text: "usbview";   icon.name: "usbview"; program: "usbview"
                         tooltip: "USB device tree viewer (usbview)" }
            ToolButton { text: "dmesg USB"; icon.name: "dialog-information"
                         shellCmd: "sudo dmesg --follow --level err,warn | grep -i usb"
                         tooltip: "Live dmesg filtered to USB errors" }
        }

        // ── Storage / IO ─────────────────────────────────────────────────────
        Kirigami.ListSectionHeader { label: i18n("Storage & IO") }
        GridLayout { columns: 3; columnSpacing: 4; rowSpacing: 4; Layout.fillWidth: true

            ToolButton { text: "iotop";         icon.name: "drive-harddisk"
                         shellCmd: "sudo iotop -o"; tooltip: "Per-process IO monitor" }
            ToolButton { text: "Disks";         icon.name: "gnome-disks"; program: "gnome-disks"
                         tooltip: "GNOME Disks (partition / SMART)" }
            ToolButton { text: "KDE Partition"; icon.name: "partitionmanager"; program: "partitionmanager"
                         tooltip: "KDE Partition Manager" }
            ToolButton { text: "smartctl";      icon.name: "drive-harddisk"
                         shellCmd: "sudo smartctl -a /dev/sda"
                         tooltip: "SMART disk health (edit device as needed)" }
        }

        // ── Network ──────────────────────────────────────────────────────────
        Kirigami.ListSectionHeader { label: i18n("Network") }
        GridLayout { columns: 3; columnSpacing: 4; rowSpacing: 4; Layout.fillWidth: true

            ToolButton { text: "nethogs";   icon.name: "network-wired"
                         shellCmd: "sudo nethogs"; tooltip: "Per-process bandwidth monitor" }
            ToolButton { text: "ss ports";  icon.name: "network-connect"
                         shellCmd: "ss -tulnp"; tooltip: "Open sockets and listening ports" }
            ToolButton { text: "Wireshark"; icon.name: "wireshark"; program: "wireshark"
                         tooltip: "Packet capture / analysis" }
            ToolButton { text: "NM TUI";    icon.name: "network-wireless"
                         shellCmd: "nmtui"; tooltip: "NetworkManager text-UI" }
        }

        // ── Logs / Kernel ─────────────────────────────────────────────────────
        Kirigami.ListSectionHeader { label: i18n("Logs & Kernel") }
        GridLayout { columns: 3; columnSpacing: 4; rowSpacing: 4; Layout.fillWidth: true

            ToolButton { text: "Journal follow";   icon.name: "text-x-log"
                         shellCmd: "journalctl -f"; tooltip: "Tail all journal messages in a terminal" }
            ToolButton { text: "Errors only";       icon.name: "dialog-error"
                         shellCmd: "journalctl -f -p err"; tooltip: "Follow journal – errors and above only" }
            ToolButton { text: "dmesg -w";           icon.name: "dialog-warning"
                         shellCmd: "sudo dmesg --follow --human"; tooltip: "Follow kernel ring buffer" }
            ToolButton { text: "KDE Info";           icon.name: "help-about"; program: "kinfocenter"
                         tooltip: "KDE Info Center (hardware overview)" }
            ToolButton { text: "SDDM/Wayland log";   icon.name: "text-x-log"
                         shellCmd: "journalctl -f -u sddm -u plasma-kwin_wayland"
                         tooltip: "Follow SDDM + KWin Wayland logs" }
        }

        Item { Layout.preferredHeight: Kirigami.Units.gridUnit }
    }
}
