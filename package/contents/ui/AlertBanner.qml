import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

// Slide-in banner that shows the latest error briefly
Rectangle {
    id: root

    property alias text: label.text

    height: visible ? implicitHeight : 0
    implicitHeight: Kirigami.Units.gridUnit * 2
    visible: false
    color: Kirigami.Theme.negativeBackgroundColor
    clip: true

    Behavior on height { NumberAnimation { duration: 180 } }

    RowLayout {
        anchors { fill: parent; margins: Kirigami.Units.smallSpacing }
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            source: "dialog-error"
            width:  Kirigami.Units.iconSizes.small
            height: width
        }

        PlasmaComponents3.Label {
            id: label
            Layout.fillWidth: true
            color: Kirigami.Theme.negativeTextColor
            elide: Text.ElideRight
            font.bold: true
        }

        PlasmaComponents3.ToolButton {
            icon.name: "window-close"
            onClicked: root.visible = false
        }
    }

    // Auto-hide after 8 s
    Timer {
        id: hideTimer
        interval: 8000
        onTriggered: root.visible = false
    }

    function show(msg) {
        label.text = msg
        root.visible = true
        hideTimer.restart()
    }
}
