import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    focusable: true
    aboveWindows: true
    visible: false
    color: "transparent"

    implicitWidth: 580
    implicitHeight: 420
    WlrLayershell.layer: WlrLayer.Overlay

    // No anchors - floats over windows

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.visible = false
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        focus: true

        // Keyboard handling - ESC closes
        Keys.onEscapePressed: root.visible = false

        property string query: ""

        border.width: 2
        border.color: "#b4befe"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 0

            // Search bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: "#313244"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    // Image {
                    // source: Quickshell.iconPath("nix-snowflake", true)
                    // Layout.preferredWidth: 20
                    // Layout.preferredHeight: 20
                    // Layout.alignment: Qt.AlignVCenter
                    // }
                    Text {
                        text: ""
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                        color: "#b4befe"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignCenter
                    }

                    TextInput {
                        id: searchInput
                        color: "#cdd6f4"
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                        focus: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        onTextChanged: {
                            parent.parent.parent.parent.query = text;
                            filterApps();
                        }
                        Keys.onEscapePressed: {
                            root.visible = false;
                        }
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                root.visible = false;
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                appList.incrementCurrentIndex();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up) {
                                appList.decrementCurrentIndex();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return) {
                                root.launchSelected();
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            // Results
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: filteredApps
                currentIndex: 0
                keyNavigationEnabled: true
                clip: true

                highlightFollowsCurrentItem: true
                highlight: Rectangle {
                    color: "#45475a"
                }
                highlightMoveDuration: 0

                delegate: Item {
                    required property var modelData
                    width: appList.width
                    height: 48

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appList.currentIndex = index
                        onDoubleClicked: root.launchSelected()
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Image {
                            source: Quickshell.iconPath(modelData.icon, true)
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            color: "#cdd6f4"
                            text: modelData.name
                            font.pixelSize: 18
                            font.family: "JetBrainsMono Nerd Font"
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    property var allApps: []
    property var filteredApps: []

    // The apps might not be ready at startup, we load the apps when they're ready
    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            loadApps();
        }
    }

    Component.onCompleted: loadApps()

    function loadApps() {
        allApps = [...DesktopEntries.applications.values].filter(d => d.name).map(d => ({
                    name: d.name,
                    icon: d.icon,
                    id: d.id
                }));
        filterApps();
    }

    function filterApps() {
        var q = searchInput.text.toLowerCase().trim();
        if (q === "") {
            filteredApps = allApps.slice(0, 50);
        } else {
            filteredApps = allApps.filter(app => app.name.toLowerCase().includes(q)).slice(0, 50);
        }
        appList.currentIndex = 0;
    }

    function launchSelected() {
        if (appList.currentItem && appList.currentItem.modelData) {
            var entry = DesktopEntries.byId(appList.currentItem.modelData.id);
            if (entry) {
                entry.execute();
                root.visible = false;
            }
        }
    }

    function show() {
        searchInput.text = "";
        filterApps();
        root.visible = true;
        searchInput.forceActiveFocus();
    }
}
