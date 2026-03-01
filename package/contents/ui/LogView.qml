import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

// Scrollable log list – auto-scrolls unless user has scrolled up
Item {
    id: root

    required property var model
    // filterModel is optional; when set the unit-filter button is enabled
    property var filterModel: null

    // Auto-scroll binding
    property bool autoScroll: true

    // Hidden TextEdit used as clipboard conduit (Qt.clipboard is not available in QML)
    TextEdit {
        id: clipboardHelper
        visible: false
    }

    // Brief "Copied" toast
    Rectangle {
        id: copyToast
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: Kirigami.Units.gridUnit }
        width: toastLabel.implicitWidth + Kirigami.Units.gridUnit * 2
        height: Kirigami.Units.gridUnit * 1.6
        radius: height / 2
        color: Kirigami.Theme.positiveBackgroundColor
        opacity: 0
        visible: opacity > 0

        PlasmaComponents3.Label {
            id: toastLabel
            anchors.centerIn: parent
            text: i18n("Copied")
            color: Kirigami.Theme.positiveTextColor
            font.bold: true
        }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: copyToast; property: "opacity"; to: 1; duration: 120 }
            PauseAnimation  { duration: 1200 }
            NumberAnimation { target: copyToast; property: "opacity"; to: 0; duration: 300 }
        }

        function show() { toastAnim.restart() }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: root.model
        clip: true
        spacing: 1

        // Detect manual scroll-up to disable auto-scroll
        onMovementStarted: root.autoScroll = false
        onAtYEndChanged:   if (atYEnd) root.autoScroll = true

        delegate: Rectangle {
            id: delegateRoot
            width: listView.width
            height: rowLayout.implicitHeight + Kirigami.Units.smallSpacing * 2
            color: {
                if (model.isError)   return Qt.rgba(Kirigami.Theme.negativeTextColor.r,
                                                    Kirigami.Theme.negativeTextColor.g,
                                                    Kirigami.Theme.negativeTextColor.b, 0.15)
                if (model.isWarning) return Qt.rgba(Kirigami.Theme.neutralTextColor.r,
                                                    Kirigami.Theme.neutralTextColor.g,
                                                    Kirigami.Theme.neutralTextColor.b, 0.10)
                return index % 2 === 0 ? "transparent"
                                       : Qt.rgba(Kirigami.Theme.textColor.r,
                                                 Kirigami.Theme.textColor.g,
                                                 Kirigami.Theme.textColor.b, 0.04)
            }

            // Hover tracking (used to fade action buttons)
            HoverHandler { id: delegateHover }

            // ── Click-to-copy (declared FIRST = lower z; action buttons above it) ──
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: {
                    const text = "%1  %2  [%3]  %4".arg(
                        Qt.formatDateTime(model.timestamp, "yyyy-MM-dd hh:mm:ss.zzz"))
                        .arg(model.unit)
                        .arg(model.priorityName)
                        .arg(model.message)
                    clipboardHelper.text = text
                    clipboardHelper.selectAll()
                    clipboardHelper.copy()
                    copyToast.show()
                }
            }

            PlasmaComponents3.ToolTip {
                text: "[%1]  %2  (%3)\n%4".arg(model.priorityName)
                                           .arg(model.unit)
                                           .arg(Qt.formatDateTime(model.timestamp, "yyyy-MM-dd hh:mm:ss"))
                                           .arg(model.message)
            }

            // ── Row content (declared AFTER MouseArea = higher z; buttons get clicks) ─
            RowLayout {
                id: rowLayout
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                          leftMargin: Kirigami.Units.smallSpacing; rightMargin: Kirigami.Units.smallSpacing }
                spacing: Kirigami.Units.smallSpacing

                // Priority indicator dot
                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: {
                        if (model.priority <= 3) return Kirigami.Theme.negativeTextColor
                        if (model.priority == 4) return Kirigami.Theme.neutralTextColor
                        if (model.priority == 5) return Kirigami.Theme.positiveTextColor
                        return Kirigami.Theme.disabledTextColor
                    }
                }

                // Timestamp
                PlasmaComponents3.Label {
                    text: Qt.formatDateTime(model.timestamp, "hh:mm:ss.zzz")
                    font.family: "monospace"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.6
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 7
                }

                // Unit / service
                PlasmaComponents3.Label {
                    text: model.unit
                    font.family: "monospace"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    color: Kirigami.Theme.linkColor
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 9
                    elide: Text.ElideRight
                }

                // Priority tag
                PlasmaComponents3.Label {
                    text: model.priorityName
                    font.family: "monospace"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    font.bold: model.isError
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                }

                // Message
                PlasmaComponents3.Label {
                    text: model.message
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAnywhere
                    font.family: "monospace"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }

                // ── Filter to this unit ───────────────────────────────────────
                PlasmaComponents3.ToolButton {
                    visible: delegateHover.hovered || (root.filterModel && root.filterModel.filterUnits.length > 0)
                    opacity: delegateHover.hovered ? 1.0 : 0.4
                    icon.name: "view-filter"
                    implicitWidth:  Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing * 2
                    implicitHeight: implicitWidth
                    flat: true
                    checkable: false
                    highlighted: root.filterModel &&
                                 root.filterModel.filterUnits.length > 0 &&
                                 root.filterModel.filterUnits[0] === model.unit
                    onClicked: {
                        if (!root.filterModel) return
                        // Toggle: clicking again while this unit is active clears the filter
                        if (root.filterModel.filterUnits.length > 0 &&
                            root.filterModel.filterUnits[0] === model.unit)
                            root.filterModel.filterUnits = []
                        else
                            root.filterModel.filterUnits = [model.unit]
                    }
                    PlasmaComponents3.ToolTip {
                        readonly property bool isActive: root.filterModel &&
                                                         root.filterModel.filterUnits.length > 0 &&
                                                         root.filterModel.filterUnits[0] === model.unit
                        text: isActive ? i18n("Clear unit filter")
                                       : i18n("Filter to: %1", model.unit)
                    }
                }

                // ── Search Google ─────────────────────────────────────────────
                PlasmaComponents3.ToolButton {
                    visible: delegateHover.hovered
                    opacity: 1.0
                    icon.name: "internet-web-browser"
                    implicitWidth:  Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing * 2
                    implicitHeight: implicitWidth
                    flat: true
                    onClicked: {
                        const query = encodeURIComponent(model.unit + " " + model.message)
                        Qt.openUrlExternally("https://www.google.com/search?q=" + query)
                    }
                    PlasmaComponents3.ToolTip { text: i18n("Search Google for this error") }
                }
            }
        }

        // Auto-scroll to bottom when new items arrive
        onCountChanged: {
            if (root.autoScroll)
                positionViewAtEnd()
        }
    }
}
