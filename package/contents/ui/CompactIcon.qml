import QtQuick
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

// Compact panel icon with error/warning badge
Item {
    id: root

    property int  errorCount:   0
    property int  warningCount: 0
    property bool running:      false

    Kirigami.Icon {
        anchors.centerIn: parent
        width:  Math.min(parent.width, parent.height)
        height: width
        source: "utilities-log-viewer"
        opacity: root.running ? 1.0 : 0.5
    }

    // Badge (errors take precedence over warnings)
    Rectangle {
        visible: root.errorCount > 0 || root.warningCount > 0
        anchors { top: parent.top; right: parent.right; margins: 2 }
        width:  Kirigami.Units.iconSizes.small * 0.9
        height: width
        radius: width / 2
        color:  root.errorCount > 0 ? Kirigami.Theme.negativeTextColor
                                    : Kirigami.Theme.neutralTextColor

        PlasmaComponents3.Label {
            anchors.centerIn: parent
            font.pixelSize: parent.width * 0.6
            font.bold: true
            color: "white"
            text: root.errorCount > 0 ? root.errorCount : root.warningCount
        }
    }
}
