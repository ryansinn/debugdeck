import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

// NOTE: com.github.debugdeck is loaded dynamically via LogBackend.qml so that
// a missing plugin shows a helpful error rather than crashing the widget.

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

        // ── C++ plugin backend ────────────────────────────────────────────────
        // Loaded dynamically so Loader.Error can be caught if the plugin is absent.
        Loader {
            id: backend
            source: "LogBackend.qml"
            onStatusChanged: {
                if (status === Loader.Ready && Plasmoid.configuration.autoStart)
                    item.watcher.start()
            }
        }

        // Forward backend signals to shared state and alert banner
        Connections {
            target: backend.item
            function onNewError(entry)            { alertBanner.show(entry.unit + ": " + entry.message) }
            function onErrorCountChanged(count)   { root.sharedErrorCount   = count }
            function onWarningCountChanged(count) { root.sharedWarningCount = count }
            function onRunningChanged(running)    { root.sharedRunning = running }
        }

        // ── Plugin missing screen ─────────────────────────────────────────────
        QQC2.ScrollView {
            anchors.fill: parent
            visible: backend.status === Loader.Error
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter

                // Header
                Kirigami.Icon {
                    source: "dialog-error"
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth:  Kirigami.Units.iconSizes.huge
                    implicitHeight: Kirigami.Units.iconSizes.huge
                }

                QQC2.Label {
                    text: i18n("C++ backend plugin not installed")
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                QQC2.Label {
                    text: i18n("The DebugDeck C++ plugin (com.github.debugdeck) could not be loaded. " +
                               "This plugin is required for journal monitoring and must be built from source and installed via CMake.")
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 36
                    Layout.alignment: Qt.AlignHCenter
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 36
                    Layout.alignment: Qt.AlignHCenter
                    height: 1
                    color: Kirigami.Theme.separatorColor
                }

                // Install steps
                QQC2.Label {
                    text: i18n("Installation instructions:")
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // Hidden TextEdit used solely for clipboard writes
                TextEdit {
                    id: clipboardHelper
                    visible: false
                    function copyText(txt) {
                        text = txt
                        selectAll()
                        copy()
                    }
                }

                // Step boxes
                Repeater {
                    model: [
                        { step: "1", label: i18n("Clone the repository"), code: "git clone https://github.com/ryansinn/debugdeck.git\ncd debugdeck" },
                        { step: "2", label: i18n("Configure and build"), code: "cmake -B build -DCMAKE_BUILD_TYPE=Release\ncmake --build build" },
                        { step: "3", label: i18n("Install the plugin (requires sudo)"), code: "sudo cmake --install build" },
                        { step: "4", label: i18n("Restart Plasma"), code: "systemctl --user restart plasma-plasmashell.service" }
                    ]

                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        Layout.maximumWidth: Kirigami.Units.gridUnit * 36
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Kirigami.Units.smallSpacing

                        // Step label row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            QQC2.Label {
                                text: i18n("Step %1 – %2", modelData.step, modelData.label)
                                font.bold: true
                                Layout.fillWidth: true
                            }
                        }

                        // Code box with copy button overlay
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: codeLabel.implicitHeight + Kirigami.Units.smallSpacing * 2
                            color: Kirigami.Theme.alternateBackgroundColor
                            radius: Kirigami.Units.cornerRadius

                            QQC2.Label {
                                id: codeLabel
                                anchors {
                                    left: parent.left
                                    right: copyBtn.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: Kirigami.Units.smallSpacing * 2
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                text: modelData.code
                                font.family: "monospace"
                                wrapMode: Text.WrapAnywhere
                            }

                            // Copy button – top-right corner
                            QQC2.ToolButton {
                                id: copyBtn
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                icon.name: copiedTimer.running ? "dialog-ok" : "edit-copy"
                                opacity: hovered ? 1.0 : 0.5
                                display: QQC2.AbstractButton.IconOnly
                                onClicked: {
                                    clipboardHelper.copyText(modelData.code)
                                    copiedTimer.restart()
                                }

                                Timer {
                                    id: copiedTimer
                                    interval: 1500
                                }

                                QQC2.ToolTip {
                                    visible: copyBtn.hovered
                                    text: copiedTimer.running ? i18n("Copied!") : i18n("Copy to clipboard")
                                }
                            }
                        }
                    }
                }

                // GitHub button
                QQC2.Button {
                    text: i18n("View on GitHub")
                    icon.name: "internet-web-browser"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: Qt.openUrlExternally("https://github.com/ryansinn/debugdeck")
                }

                // Bottom padding
                Item { implicitHeight: Kirigami.Units.largeSpacing }
            }
        }

        // ── Normal UI ─────────────────────────────────────────────────────────
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            visible: backend.status === Loader.Ready

            // System info titlebar
            SystemInfoBar {
                Layout.fillWidth: true
                visible: Plasmoid.configuration.infoBarEnabled
            }

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
                        filterModel: backend.item ? backend.item.filterModel : null
                        logModel:    backend.item ? backend.item.logModel    : null
                        watcher:     backend.item ? backend.item.watcher     : null
                    }
                    LogView {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        model:       backend.item ? backend.item.filterModel : null
                        filterModel: backend.item ? backend.item.filterModel : null
                    }
                }

                // Tab 1 – Tool launcher
                ToolsPanel {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    launcher: backend.item ? backend.item.launcher : null
                }
            }
        }
    }
}
