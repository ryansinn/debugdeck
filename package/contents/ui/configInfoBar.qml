import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    // ── InfoBar config ────────────────────────────────────────────────────────
    property alias cfg_infoShowHostname:      showHostname.checked
    property alias cfg_infoShowKernel:        showKernel.checked
    property alias cfg_infoShowPlasma:        showPlasma.checked
    property alias cfg_infoShowKF:            showKF.checked
    property alias cfg_infoShowQt:            showQt.checked
    property alias cfg_infoShowWindowSystem:  showWindowSystem.checked
    property alias cfg_infoShowUptime:        showUptime.checked

    property alias cfg_infoLabelHostname:     labelHostname.text
    property alias cfg_infoLabelKernel:       labelKernel.text
    property alias cfg_infoLabelPlasma:       labelPlasma.text
    property alias cfg_infoLabelKF:           labelKF.text
    property alias cfg_infoLabelQt:           labelQt.text
    property alias cfg_infoLabelWindowSystem: labelWindowSystem.text
    property alias cfg_infoLabelUptime:       labelUptime.text

    // Plasma injects cfg_<name>Default for every String entry – must be declared
    property string cfg_infoLabelHostnameDefault:     "Host"
    property string cfg_infoLabelKernelDefault:       "Kernel"
    property string cfg_infoLabelPlasmaDefault:       "Plasma"
    property string cfg_infoLabelKFDefault:           "KF"
    property string cfg_infoLabelQtDefault:           "Qt"
    property string cfg_infoLabelWindowSystemDefault: "WS"
    property string cfg_infoLabelUptimeDefault:       "Uptime"

    property alias cfg_infoBarEnabled:  infoBarEnabledCheck.checked
    property alias cfg_infoShowIcons:   showIconsCheck.checked
    property alias cfg_infoValueInline: valueInlineCheck.checked

    // ── Stubs – unused on this page ───────────────────────────────────────────
    property string cfg_watchedUnits:            ""
    property int    cfg_maxRows:                 5000
    property bool   cfg_autoStart:              true
    property int    cfg_alertPriority:           3
    property bool   cfg_notificationsEnabled:    true
    property int    cfg_notificationMinPriority: 3

    // ── Data model for the grid rows ──────────────────────────────────────────
    // Each entry: [ fullName, checkId, fieldId ]  — links are done via aliases above
    // We render rows directly so aliases can reference root-level ids.

    ColumnLayout {
        anchors {
            top: parent.top; left: parent.left; right: parent.right
            margins: Kirigami.Units.largeSpacing
        }
        spacing: Kirigami.Units.smallSpacing

        // ── Master enable ─────────────────────────────────────────────────────
        QQC2.CheckBox {
            id: infoBarEnabledCheck
            text: i18n("Show info bar")
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        // Everything below dims when the bar is disabled
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            enabled: infoBarEnabledCheck.checked
            opacity: infoBarEnabledCheck.checked ? 1.0 : 0.4
            Behavior on opacity { NumberAnimation { duration: 120 } }

        // ── Description ───────────────────────────────────────────────────────
        QQC2.Label {
            text: i18n("Choose which fields appear in the info bar.\nThe short label is displayed in the bar; the full name appears as a tooltip.")
            wrapMode: Text.WordWrap
            opacity: 0.7
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        // ── Appearance ────────────────────────────────────────────────────────
        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        RowLayout {
            spacing: Kirigami.Units.largeSpacing
            Layout.fillWidth: true

            QQC2.CheckBox {
                id: showIconsCheck
                text: i18n("Show icons")
            }

            QQC2.CheckBox {
                id: valueInlineCheck
                text: i18n("Value inline (to the right of label)")
            }

            QQC2.Label {
                text: i18n("Unchecked = value stacked below label")
                opacity: 0.5
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                font.italic: true
                enabled: valueInlineCheck.checked === false
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        // ── Column header row ─────────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Layout.fillWidth: true

            Item { width: Kirigami.Units.gridUnit * 2 }   // checkbox column
            QQC2.Label {
                text: i18n("Field")
                font.bold: true
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
            QQC2.Label {
                text: i18n("Short label (shown in bar)")
                font.bold: true
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
            QQC2.Label {
                text: i18n("↑ leave blank to use default")
                opacity: 0.5
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                font.italic: true
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        // ── Hostname ──────────────────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            QQC2.CheckBox { id: showHostname; Layout.preferredWidth: Kirigami.Units.gridUnit * 2 }
            QQC2.Label {
                text: i18n("Hostname")
                opacity: showHostname.checked ? 1.0 : 0.4
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
            QQC2.TextField {
                id: labelHostname
                enabled: showHostname.checked
                placeholderText: i18nc("default short label", "Host")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
        }

        // ── Kernel ────────────────────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            QQC2.CheckBox { id: showKernel; Layout.preferredWidth: Kirigami.Units.gridUnit * 2 }
            QQC2.Label {
                text: i18n("Kernel")
                opacity: showKernel.checked ? 1.0 : 0.4
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
            QQC2.TextField {
                id: labelKernel
                enabled: showKernel.checked
                placeholderText: i18nc("default short label", "Kernel")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
        }

        // ── Plasma Version ────────────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            QQC2.CheckBox { id: showPlasma; Layout.preferredWidth: Kirigami.Units.gridUnit * 2 }
            QQC2.Label {
                text: i18n("KDE Plasma Version")
                opacity: showPlasma.checked ? 1.0 : 0.4
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
            QQC2.TextField {
                id: labelPlasma
                enabled: showPlasma.checked
                placeholderText: i18nc("default short label", "Plasma")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
        }

        // ── KDE Frameworks ────────────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            QQC2.CheckBox { id: showKF; Layout.preferredWidth: Kirigami.Units.gridUnit * 2 }
            QQC2.Label {
                text: i18n("KDE Frameworks Version")
                opacity: showKF.checked ? 1.0 : 0.4
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
            QQC2.TextField {
                id: labelKF
                enabled: showKF.checked
                placeholderText: i18nc("default short label", "KF")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
        }

        // ── Qt Version ────────────────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            QQC2.CheckBox { id: showQt; Layout.preferredWidth: Kirigami.Units.gridUnit * 2 }
            QQC2.Label {
                text: i18n("Qt Version")
                opacity: showQt.checked ? 1.0 : 0.4
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
            QQC2.TextField {
                id: labelQt
                enabled: showQt.checked
                placeholderText: i18nc("default short label", "Qt")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
        }

        // ── Window System ─────────────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            QQC2.CheckBox { id: showWindowSystem; Layout.preferredWidth: Kirigami.Units.gridUnit * 2 }
            QQC2.Label {
                text: i18n("Window System")
                opacity: showWindowSystem.checked ? 1.0 : 0.4
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
            QQC2.TextField {
                id: labelWindowSystem
                enabled: showWindowSystem.checked
                placeholderText: i18nc("default short label", "WS")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
        }

        // ── Uptime ────────────────────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            QQC2.CheckBox { id: showUptime; Layout.preferredWidth: Kirigami.Units.gridUnit * 2 }
            QQC2.Label {
                text: i18n("Uptime")
                opacity: showUptime.checked ? 1.0 : 0.4
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
            QQC2.TextField {
                id: labelUptime
                enabled: showUptime.checked
                placeholderText: i18nc("default short label", "Uptime")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
            }
        }

        }  // end sub-ColumnLayout (dims when bar disabled)
    }
}
