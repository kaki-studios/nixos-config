import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    focusable: true
    aboveWindows: true
    visible: false
    color: "transparent"

    property int buttonSize: 80
    property int spacing: 8

    implicitWidth: 5 * buttonSize + 2 * spacing - 6
    implicitHeight: buttonSize + 2 * spacing - 8 //these substractions are eyeballed
    WlrLayershell.layer: WlrLayer.Overlay

    ListModel {
        id: powerModel
        ListElement {
            icon: "󰌾"
            accent: "#b4befe"
            action: "lock"
        }
        ListElement {
            icon: "󰒲"
            accent: "#b4befe"
            action: "sleep"
        }
        ListElement {
            icon: "󰍃"
            accent: "#b4befe"
            action: "logout"
        }
        ListElement {
            icon: "󰜉"
            accent: "#a6e3a1"
            action: "reboot"
        }
        ListElement {
            icon: ""
            accent: "#f38ba8"
            action: "shutdown"
        }
    }

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.visible = false
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        border.width: 2
        border.color: "#b4befe"

        GridView {
            id: grid
            anchors.fill: parent
            // anchors.margins: 8
            anchors.topMargin: 8
            anchors.leftMargin: 8

            cellWidth: buttonSize
            cellHeight: buttonSize

            interactive: false
            keyNavigationEnabled: true
            focus: true

            model: powerModel
            delegate: powerDelegate

            highlight: Rectangle {
                // width: buttonSize + 10
                // height: buttonSize + 10
                color: "transparent"
                border.width: 2
                border.color: "#cdd6f4"
                z: 10
            }

            // highlight: Rectangle {
            // color: "#45475a"
            // }
            highlightMoveDuration: 0
            highlightFollowsCurrentItem: true

            Component {
                id: powerDelegate
                PowerButton {
                    id: btn
                    width: buttonSize - 8
                    height: buttonSize - 8
                    icon: model.icon
                    accentColor: model.accent
                    onClicked: executeAction(model.action)
                }
            }

            // Keyboard navigation
            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab) {
                    grid.moveCurrentIndexLeft();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                    grid.moveCurrentIndexRight();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    executeAction(model.get(grid.currentIndex).action);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Escape) {
                    root.visible = false;
                    event.accepted = true;
                }
            }
        }
    }

    function executeAction(action) {
        root.visible = false;
        switch (action) {
        case "lock":
            lockProc.running = true;
            break;
        case "sleep":
            sleepProc.running = true;
            break;
        case "logout":
            logoutProc.running = true;
            break;
        case "reboot":
            rebootProc.running = true;
            break;
        case "shutdown":
            shutdownProc.running = true;
            break;
        }
    }

    function show() {
        root.visible = true;
        grid.currentIndex = 0;
        grid.forceActiveFocus();
    }

    // Power processes
    Process {
        id: lockProc
        command: ["sh", "-c", "swaylock"]
    }
    Process {
        id: sleepProc
        command: ["sh", "-c", "systemctl suspend"]
    }
    Process {
        id: logoutProc
        command: ["sh", "-c", "pkill -9 -u $USER"]
    }
    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
    }
    Process {
        id: shutdownProc
        command: ["systemctl", "poweroff"]
    }
}
