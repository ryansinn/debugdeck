import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

// Filter bar: search box, priority selector, errors-only toggle, start/stop/clear
RowLayout {
    id: root

    required property var filterModel
    required property var logModel
    required property var watcher

    spacing: Kirigami.Units.smallSpacing
    height:  Kirigami.Units.gridUnit * 2.4

    // Search
    PlasmaComponents3.TextField {
        id: searchField
        Layout.fillWidth: true
        placeholderText: i18n("Search logs…")
        onTextChanged: if (root.filterModel) root.filterModel.searchText = text
        leftPadding: Kirigami.Units.smallSpacing + searchIcon.width + Kirigami.Units.smallSpacing
        Kirigami.Icon {
            id: searchIcon
            anchors { left: parent.left; leftMargin: Kirigami.Units.smallSpacing; verticalCenter: parent.verticalCenter }
            source: "system-search"
            width: Kirigami.Units.iconSizes.small
            height: width
        }
    }

    // Priority combobox – index driven by model's minPriority so it stays in
    // sync when errorsOnly is toggled off and resets to 7.
    PlasmaComponents3.ComboBox {
        id: prioCombo
        model: ["All", "Warning+", "Error+", "Critical"]
        readonly property var priorityMap: [7, 4, 3, 2]
        // Derive index from model value so external changes are reflected
        currentIndex: {
            if (!root.filterModel) return 0
            const p = root.filterModel.minPriority
            const idx = priorityMap.indexOf(p)
            return idx >= 0 ? idx : 0
        }
        onActivated: {
            if (!root.filterModel) return
            root.filterModel.minPriority = priorityMap[currentIndex]
        }
    }

    // Errors-only quick toggle
    PlasmaComponents3.ToolButton {
        icon.name: "dialog-error"
        checkable: true
        checked: root.filterModel ? root.filterModel.errorsOnly : false
        onCheckedChanged: if (root.filterModel) root.filterModel.errorsOnly = checked
        PlasmaComponents3.ToolTip { text: i18n("Errors only") }
    }

    // Active unit filter chip – visible when a unit is pinned
    PlasmaComponents3.ToolButton {
        visible: root.filterModel && root.filterModel.filterUnits.length > 0
        text: visible ? root.filterModel.filterUnits[0] : ""
        icon.name: "dialog-close"
        display: PlasmaComponents3.AbstractButton.TextBesideIcon
        onClicked: if (root.filterModel) root.filterModel.filterUnits = []
        PlasmaComponents3.ToolTip { text: i18n("Clear unit filter") }
    }

    // Row counter
    PlasmaComponents3.Label {
        text: i18nc("shown / total rows", "%1 / %2",
                    root.filterModel ? root.filterModel.count : 0,
                    root.logModel    ? root.logModel.count    : 0)
        opacity: 0.7
        font.pointSize: Kirigami.Theme.smallFont.pointSize
    }

    // Start / Stop
    PlasmaComponents3.ToolButton {
        icon.name: root.watcher.running ? "media-playback-pause" : "media-playback-start"
        onClicked: root.watcher.running ? root.watcher.stop() : root.watcher.start()
        PlasmaComponents3.ToolTip { text: root.watcher.running ? i18n("Pause") : i18n("Resume") }
    }

    // Clear
    PlasmaComponents3.ToolButton {
        icon.name: "edit-clear-history"
        onClicked: root.logModel.clear()
        PlasmaComponents3.ToolTip { text: i18n("Clear log") }
    }
}
