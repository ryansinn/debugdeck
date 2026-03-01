import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property alias cfg_watchedUnits: watchedUnitsField.text
    property alias cfg_maxRows:      maxRowsSpin.value
    property alias cfg_autoStart:    autoStartCheck.checked

    // Unused on this page – declared so Plasma's config injection doesn't fail
    property int  cfg_alertPriority:            3
    property bool cfg_notificationsEnabled:     true
    property int  cfg_notificationMinPriority:  3

    Kirigami.FormLayout {
        anchors.fill: parent

        // ── Log source ────────────────────────────────────────────────────
        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Log Source") }

        QQC2.TextField {
            id: watchedUnitsField
            Kirigami.FormData.label: i18n("Watched units:")
            placeholderText: i18n("e.g. bluetooth.service, pipewire.service  (empty = all)")
            Layout.fillWidth: true
        }

        QQC2.Label {
            text: i18n("Comma-separated systemd unit names. Leave empty to watch all units.")
            wrapMode: Text.WordWrap
            opacity: 0.7
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            Layout.fillWidth: true
        }

        // ── Display ───────────────────────────────────────────────────────
        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Display") }

        QQC2.SpinBox {
            id: maxRowsSpin
            Kirigami.FormData.label: i18n("Max log rows:")
            from: 100
            to:   50000
            stepSize: 100
        }

        QQC2.CheckBox {
            id: autoStartCheck
            Kirigami.FormData.label: i18n("Auto-start:")
            text: i18n("Start log watching automatically when widget loads")
        }
    }
}
