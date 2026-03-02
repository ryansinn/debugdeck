import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

// ─────────────────────────────────────────────────────────────────────────────
//  System info titlebar
//  Each chip: small icon + configurable short label (tooltip = full name)
//  Visibility and labels are controlled via the "Info Bar" config page.
// ─────────────────────────────────────────────────────────────────────────────
Rectangle {
    id: root

    implicitHeight: row.implicitHeight + Kirigami.Units.smallSpacing * 2
    color: Kirigami.Theme.alternateBackgroundColor

    // ── Sensors ──────────────────────────────────────────────────────────────
    Sensors.Sensor { id: sHostname; sensorId: "os/system/hostname" }
    Sensors.Sensor { id: sKernel;   sensorId: "os/kernel/prettyName" }
    Sensors.Sensor { id: sPlasma;   sensorId: "os/plasma/plasmaVersion" }
    Sensors.Sensor { id: sKF;       sensorId: "os/plasma/kfVersion" }
    Sensors.Sensor { id: sQt;       sensorId: "os/plasma/qtVersion" }
    Sensors.Sensor { id: sWinSys;   sensorId: "os/plasma/windowsystem" }
    Sensors.Sensor { id: sUptime;   sensorId: "os/system/uptime"; updateRateLimit: 500 }

    // ── Global appearance from config ─────────────────────────────────────────
    readonly property bool showIcons:   Plasmoid.configuration.infoShowIcons
    readonly property bool valueInline: Plasmoid.configuration.infoValueInline

    // ── Chip component ────────────────────────────────────────────────────────
    //  showIcon=true  → icon shown beside label
    //  valueInline=false → value stacked below label (default)
    //  valueInline=true  → value shown inline to the right of label
    component InfoChip: Item {
        id: chip
        required property string iconName
        required property string shortLabel   // from config; empty → use fullName
        required property string fullName     // always shown in tooltip
        required property string val
        required property bool   showIcon
        required property bool   valueInline

        implicitWidth:  chip.valueInline ? chipRow.implicitWidth  : chipCol.implicitWidth
        implicitHeight: chip.valueInline ? chipRow.implicitHeight : chipCol.implicitHeight

        HoverHandler { id: hov }
        PlasmaComponents3.ToolTip {
            visible: hov.hovered && chip.fullName.length > 0
            text:    chip.fullName
        }

        // ── Stacked mode: label above, value below ────────────────────────────
        ColumnLayout {
            id: chipCol
            visible: !chip.valueInline
            spacing: 0

            RowLayout {
                spacing: Kirigami.Units.smallSpacing / 2
                Layout.alignment: Qt.AlignHCenter

                Kirigami.Icon {
                    visible: chip.showIcon
                    source:  chip.iconName
                    width:   Kirigami.Units.iconSizes.small
                    height:  width
                    opacity: 0.6
                }
                PlasmaComponents3.Label {
                    text: chip.shortLabel.length > 0 ? chip.shortLabel : chip.fullName
                    font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.85
                    opacity: 0.6
                }
            }
            PlasmaComponents3.Label {
                text: chip.val.length > 0 ? chip.val : "…"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // ── Inline mode: icon + label · value all on one line ─────────────────
        RowLayout {
            id: chipRow
            visible: chip.valueInline
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                visible: chip.showIcon
                source:  chip.iconName
                width:   Kirigami.Units.iconSizes.small
                height:  width
                opacity: 0.6
            }
            PlasmaComponents3.Label {
                text: chip.shortLabel.length > 0 ? chip.shortLabel : chip.fullName
                font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.85
                opacity: 0.6
            }
            PlasmaComponents3.Label {
                text: chip.val.length > 0 ? chip.val : "…"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                font.bold: true
            }
        }
    }

    // ── Thin vertical separator ───────────────────────────────────────────────
    component VSep: Rectangle {
        width: 1
        Layout.fillHeight: true
        Layout.topMargin:    Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        color:   Kirigami.Theme.textColor
        opacity: 0.15
    }

    // ── Row ───────────────────────────────────────────────────────────────────
    RowLayout {
        id: row
        anchors {
            fill: parent
            leftMargin:   Kirigami.Units.smallSpacing * 2
            rightMargin:  Kirigami.Units.smallSpacing * 2
            topMargin:    Kirigami.Units.smallSpacing
            bottomMargin: Kirigami.Units.smallSpacing
        }
        spacing: Kirigami.Units.smallSpacing * 2

        InfoChip {
            visible:     Plasmoid.configuration.infoShowHostname
            iconName:    "network-server-symbolic"
            shortLabel:  Plasmoid.configuration.infoLabelHostname
            fullName:    i18n("Hostname")
            val:         sHostname.formattedValue
            showIcon:    root.showIcons
            valueInline: root.valueInline
        }
        VSep { visible: Plasmoid.configuration.infoShowHostname && anyAfterHostname }

        InfoChip {
            visible:     Plasmoid.configuration.infoShowKernel
            iconName:    "system-run-symbolic"
            shortLabel:  Plasmoid.configuration.infoLabelKernel
            fullName:    i18n("Kernel")
            val:         sKernel.formattedValue
            showIcon:    root.showIcons
            valueInline: root.valueInline
        }
        VSep { visible: Plasmoid.configuration.infoShowKernel && anyAfterKernel }

        InfoChip {
            visible:     Plasmoid.configuration.infoShowPlasma
            iconName:    "plasma-symbolic"
            shortLabel:  Plasmoid.configuration.infoLabelPlasma
            fullName:    i18n("KDE Plasma Version")
            val:         sPlasma.formattedValue
            showIcon:    root.showIcons
            valueInline: root.valueInline
        }
        VSep { visible: Plasmoid.configuration.infoShowPlasma && anyAfterPlasma }

        InfoChip {
            visible:     Plasmoid.configuration.infoShowKF
            iconName:    "kde-symbolic"
            shortLabel:  Plasmoid.configuration.infoLabelKF
            fullName:    i18n("KDE Frameworks Version")
            val:         sKF.formattedValue
            showIcon:    root.showIcons
            valueInline: root.valueInline
        }
        VSep { visible: Plasmoid.configuration.infoShowKF && anyAfterKF }

        InfoChip {
            visible:     Plasmoid.configuration.infoShowQt
            iconName:    "applications-development-symbolic"
            shortLabel:  Plasmoid.configuration.infoLabelQt
            fullName:    i18n("Qt Version")
            val:         sQt.formattedValue
            showIcon:    root.showIcons
            valueInline: root.valueInline
        }
        VSep { visible: Plasmoid.configuration.infoShowQt && anyAfterQt }

        InfoChip {
            visible:     Plasmoid.configuration.infoShowWindowSystem
            iconName:    "video-display-symbolic"
            shortLabel:  Plasmoid.configuration.infoLabelWindowSystem
            fullName:    i18n("Window System")
            val:         sWinSys.formattedValue
            showIcon:    root.showIcons
            valueInline: root.valueInline
        }
        VSep { visible: Plasmoid.configuration.infoShowWindowSystem && Plasmoid.configuration.infoShowUptime }

        InfoChip {
            visible:     Plasmoid.configuration.infoShowUptime
            iconName:    "chronometer-symbolic"
            shortLabel:  Plasmoid.configuration.infoLabelUptime
            fullName:    i18n("Uptime")
            val:         sUptime.formattedValue
            showIcon:    root.showIcons
            valueInline: root.valueInline
        }

        Item { Layout.fillWidth: true }
    }

    // ── Separator visibility helpers (suppress orphan separators) ─────────────
    readonly property bool anyAfterHostname:    Plasmoid.configuration.infoShowKernel
                                             || Plasmoid.configuration.infoShowPlasma
                                             || Plasmoid.configuration.infoShowKF
                                             || Plasmoid.configuration.infoShowQt
                                             || Plasmoid.configuration.infoShowWindowSystem
                                             || Plasmoid.configuration.infoShowUptime
    readonly property bool anyAfterKernel:      Plasmoid.configuration.infoShowPlasma
                                             || Plasmoid.configuration.infoShowKF
                                             || Plasmoid.configuration.infoShowQt
                                             || Plasmoid.configuration.infoShowWindowSystem
                                             || Plasmoid.configuration.infoShowUptime
    readonly property bool anyAfterPlasma:      Plasmoid.configuration.infoShowKF
                                             || Plasmoid.configuration.infoShowQt
                                             || Plasmoid.configuration.infoShowWindowSystem
                                             || Plasmoid.configuration.infoShowUptime
    readonly property bool anyAfterKF:          Plasmoid.configuration.infoShowQt
                                             || Plasmoid.configuration.infoShowWindowSystem
                                             || Plasmoid.configuration.infoShowUptime
    readonly property bool anyAfterQt:          Plasmoid.configuration.infoShowWindowSystem
                                             || Plasmoid.configuration.infoShowUptime
}
