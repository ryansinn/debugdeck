import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property alias cfg_notificationsEnabled:    notifyEnabledCheck.checked
    property int   cfg_notificationMinPriority: 3

    // Unused on this page – declared so Plasma's config injection doesn't fail
    property string cfg_watchedUnits: ""
    property int    cfg_maxRows:      5000
    property bool   cfg_autoStart:    true
    property int    cfg_alertPriority: 3

    // Map between combo index and raw priority value
    readonly property var prioValues: [2, 3, 4, 5]

    function priorityToIndex(prio) {
        const idx = prioValues.indexOf(prio)
        return idx >= 0 ? idx : 1   // default to Error+
    }

    Component.onCompleted: prioCombo.currentIndex = priorityToIndex(cfg_notificationMinPriority)

    Kirigami.FormLayout {
        anchors.fill: parent

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("System Notifications") }

        QQC2.CheckBox {
            id: notifyEnabledCheck
            Kirigami.FormData.label: i18n("Enabled:")
            text: i18n("Send system notifications for important log entries")
        }

        QQC2.ComboBox {
            id: prioCombo
            Kirigami.FormData.label: i18n("Notify on:")
            enabled: notifyEnabledCheck.checked
            model: [
                i18n("Critical only  (emerg / alert / crit)"),
                i18n("Errors+        (critical and errors)"),
                i18n("Warnings+      (errors and warnings)"),
                i18n("Notice+        (warnings, notices and above)"),
            ]
            onCurrentIndexChanged: cfg_notificationMinPriority = root.prioValues[currentIndex]
        }

        QQC2.Label {
            text: i18n("A system notification is sent each time a log entry at or above the selected severity arrives.")
            wrapMode: Text.WordWrap
            opacity: 0.7
            enabled: notifyEnabledCheck.checked
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            Layout.fillWidth: true
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("In-widget Banner") }

        QQC2.Label {
            text: i18n("The alert banner inside the widget always shows for errors regardless of notification settings.")
            wrapMode: Text.WordWrap
            opacity: 0.7
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            Layout.fillWidth: true
        }
    }
}
