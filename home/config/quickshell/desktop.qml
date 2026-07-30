import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Networking
import "Bar"
import "Notifications"

ShellRoot {

    // ========== LAUNCHER WINDOW ==========
    Launcher {
        id: launcherWindow
    }

    // ========== POWERMENU WINDOW ==========
    PowerMenu {
        id: powermenuWindow
    }

    // ========== IPC ==========
    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: ipcRead.running = true
    }

    Process {
        id: ipcRead
        command: ["sh", "-c", "[ -f /tmp/quickshell-overlay-cmd ] && cat /tmp/quickshell-overlay-cmd && echo -n > /tmp/quickshell-overlay-cmd || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                var cmd = this.text.trim();
                if (cmd === "launcher") {
                    if (launcherWindow.visible)
                        launcherWindow.visible = false;
                    else
                        launcherWindow.show();
                } else if (cmd === "powermenu") {
                    if (powermenuWindow.visible)
                        powermenuWindow.visible = false;
                    else
                        powermenuWindow.show();
                } else if (cmd === "hide") {
                    launcherWindow.visible = false;
                    powermenuWindow.visible = false;
                }
            }
        }
    }

    // ========== WAYBAR PANEL ==========
    Variants {
        model: Quickshell.screens
        PanelWindow {
            property var modelData
            screen: modelData
            implicitHeight: 40
            anchors {
                top: true
                left: true
                right: true
            }
            color: "transparent"

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }

                RowLayout {
                    id: leftSection
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    Workspaces {}
                    Mpris {}
                }
                Clock {
                    anchors.centerIn: parent
                }

                RowLayout {
                    id: rightSection
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    NotificationPopup {}

                    Network {}
                    Separator {}

                    Volume {}
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 1
                color: "#6c7086"
            }
        }
    }
}
