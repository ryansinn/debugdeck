import QtQuick
import org.kde.plasma.plasmoid
import org.kde.notification
import com.github.debugdeck

// ─────────────────────────────────────────────────────────────────────────────
//  LogBackend – isolates the C++ plugin import so that main.qml can load this
//  file via Loader and detect a missing plugin (Loader.Error) gracefully.
// ─────────────────────────────────────────────────────────────────────────────
Item {
    id: backend

    // ── Expose internal objects to the parent ─────────────────────────────────
    property alias logModel:    logModel
    property alias filterModel: filterModel
    property alias watcher:     watcher
    // Launcher is a QML_SINGLETON – expose it as a plain var so ToolsPanel
    // can call it without importing com.github.debugdeck itself.
    readonly property var launcher: Launcher

    // ── Forwarded signals (parent connects to backend.item) ───────────────────
    signal newError(var entry)
    signal errorCountChanged(int count)
    signal warningCountChanged(int count)
    signal runningChanged(bool running)

    // ── Backend objects ───────────────────────────────────────────────────────
    LogModel {
        id: logModel
        maxRows: Plasmoid.configuration.maxRows
        onNewError:           (entry) => backend.newError(entry)
        onErrorCountChanged:  backend.errorCountChanged(logModel.errorCount)
        onWarningCountChanged: backend.warningCountChanged(logModel.warningCount)
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
            const notif = prio <= 3 ? errorNotification : warningNotification
            notif.title = i18n("DebugDeck: %1", unit)
            notif.text  = msg
            notif.sendEvent()
        }
        onRunningChanged: backend.runningChanged(watcher.running)
    }

    // ── KNotification objects ─────────────────────────────────────────────────
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
}
