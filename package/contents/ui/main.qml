import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.notification

import com.github.debugdeck

// ─────────────────────────────────────────────────────────────────────────────
//  DebugDeck – root plasmoid item
//  Compact view: icon + error/warning badge
//  Full view:    tabbed – Logs | Tools
// ─────────────────────────────────────────────────────────────────────────────
PlasmoidItem {
    id: root

    // ── Shared state: updated by fullRepresentation for compact icon ──────────
    property int  sharedErrorCount:   0
    property int  sharedWarningCount: 0
    property bool sharedRunning:      false

    // ── Plasmoid sizing ───────────────────────────────────────────────────────
    switchWidth:  Kirigami.Units.gridUnit * 28
    switchHeight: Kirigami.Units.gridUnit * 20

    // ── Compact representation (panel icon) ──────────────────────────────────
    compactRepresentation: CompactIcon {
        errorCount:   root.sharedErrorCount
        warningCount: root.sharedWarningCount
        running:      root.sharedRunning
    }

    // ── Full representation (popup / expanded) ────────────────────────────────
    // NOTE: fullRepresentation is a Component context in Plasma – ids declared
    // outside are NOT visible here. All backend objects must be local.
    fullRepresentation: Item {
        id: fullRep

        implicitWidth:  Kirigami.Units.gridUnit * 46
        implicitHeight: Kirigami.Units.gridUnit * 32

        // ── Backend objects (local so their ids are in scope below) ───────────
        LogModel {
            id: logModel
            maxRows: Plasmoid.configuration.maxRows
            onNewError:          (entry) => alertBanner.show(entry.unit + ": " + entry.message)
            onErrorCountChanged:   root.sharedErrorCount   = logModel.errorCount
            onWarningCountChanged: root.sharedWarningCount = logModel.warningCount
        }

        LogFilterModel {
            id: filterModel
            sourceModel: logModel
        }

        JournaldWatcher {
            id: watcher
            units: Plasmoid.configuration.watchedUnits.split(",").filter(s => s.trim().length > 0)
            onEntryReceived: (ts, unit, prio, msg) => {
                logModel.appendEntry(ts, unit, prio, msg)
                if (!Plasmoid.configuration.notificationsEnabled) return
                if (prio > Plasmoid.configuration.notificationMinPriority) return
                // Choose event: errors/critical → newError, warnings/notices → newWarning
                const notif = prio <= 3 ? errorNotification : warningNotification
                notif.title = i18n("DebugDeck: %1", unit)
                notif.text  = msg
                notif.sendEvent()
            }
            onRunningChanged: root.sharedRunning = watcher.running
        }

        // ── KNotification objects ─────────────────────────────────────────────
        Notification {
            id: errorNotification
            componentName: "debugdeck"
            eventId:       "newError"
            iconName:      "dialog-error"
            urgency:       Notification.HighUrgency
            flags:         Notification.CloseOnTimeout
        }

        Notification {
            id: warningNotification
            componentName: "debugdeck"
            eventId:       "newWarning"
            iconName:      "dialog-warning"
            urgency:       Notification.NormalUrgency
            flags:         Notification.CloseOnTimeout
        }

        Component.onCompleted: {
            if (Plasmoid.configuration.autoStart)
                watcher.start()
        }

        // ── UI ────────────────────────────────────────────────────────────────
        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Alert banner
            AlertBanner { id: alertBanner; Layout.fillWidth: true }

            // Tab bar
            PlasmaComponents3.TabBar {
                id: tabBar
                Layout.fillWidth: true

                PlasmaComponents3.TabButton { text: i18n("Logs") }
                PlasmaComponents3.TabButton { text: i18n("Tools") }
            }

            // Tab pages
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabBar.currentIndex

                // Tab 0 – Log view
                ColumnLayout {
                    spacing: 0
                    FilterBar {
                        Layout.fillWidth: true
                        filterModel: filterModel
                        logModel:    logModel
                        watcher:     watcher
                    }
                    LogView {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        model: filterModel
                        filterModel: filterModel
                    }
                }

                // Tab 1 – Tool launcher
                ToolsPanel {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
