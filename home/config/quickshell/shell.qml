import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Io
import Quickshell.Networking

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
    PanelWindow {
        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }
        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }
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
                ListModel {
                    id: wsModel
                }

                Repeater {
                    model: wsModel
                    delegate: Text {
                        text: active ? "" : ""
                        color: active ? "#b4befe" : "#6c7086"
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 18
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally("niri:workspace:" + num)
                        }
                    }
                }

                // Text {
                // text: "apps"
                // color: "#6c7086"
                // font {
                // family: "JetBrainsMono Nerd Font"
                // pixelSize: 14
                // }
                // MouseArea {
                // anchors.fill: parent
                // cursorShape: Qt.PointingHandCursor
                // onClicked: launcherWindow.show()
                // }
                // }
                Text {
                    id: mprisText
                    text: ""
                    color: "#cdd6f4"
                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 16
                    }
                }
            }

            Text {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "hh:mm")
                color: "#cdd6f4"
                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 16
                    weight: Font.Bold
                }
            }

            RowLayout {
                id: rightSection
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                RowLayout {
                    id: networkLayout
                    spacing: 5

                    Text {
                        id: networkIcon
                        text: {
                            var devs = Networking.devices.values;
                            for (var i = 0; i < devs.length; i++) {
                                var dev = devs[i];
                                if (dev.connected) {
                                    if (dev.type === 1)
                                        return "󰖩";
                                    if (dev.type === 2)
                                        return "󰈀";
                                    return dev.name || "󰖟";
                                }
                            }
                            return "offline";
                        }
                        color: "#b4befe"
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 16
                        }
                    }
                    Text {
                        id: networkName
                        text: {
                            var devs = Networking.devices.values;
                            for (var i = 0; i < devs.length; i++) {
                                var dev = devs[i];
                                if (dev.connected) {
                                    return dev.name;
                                }
                            }
                            return "offline";
                        }
                        color: "#cdd6f4"
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 12
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: 40
                    color: "#6c7086"
                }
                RowLayout {
                    id: volumeLayout
                    spacing: 5
                    Text {
                        id: volumeText
                        text: Pipewire.defaultAudioSink ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : "0%"
                        color: "#cdd6f4"
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 16
                        }
                    }
                    Text {
                        id: volumeIcon
                        text: {
                            let vol = Pipewire.defaultAudioSink ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) : 0;
                            let volumeIcons = ["", "", "󰕾", "󰕾", "󰕾", "", "", ""]; // 8 icons
                            return volumeIcons[Math.floor((vol * 8 / 101))];
                            // return Math.round(vol / 12.5);
                        }
                        color: "#b4befe"
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 16
                        }
                    }
                }

                // Text {
                // text: "power"
                // color: "#6c7086"
                // font {
                // family: "JetBrainsMono Nerd Font"
                // pixelSize: 14
                // }
                // MouseArea {
                // anchors.fill: parent
                // cursorShape: Qt.PointingHandCursor
                // onClicked: powermenuWindow.show()
                // }
                // }
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

        Process {
            id: niriWorkspacesProc
            command: ["sh", "-c", "niri msg workspaces"]
            stdout: StdioCollector {
                onStreamFinished: {
                    var lines = this.text.split("\n");
                    wsModel.clear();
                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i];
                        if (!line.trim() || line.indexOf("Output") >= 0)
                            continue;
                        var active = line.indexOf("*") >= 0;
                        var num = parseInt(line.replace(/[*\s]/g, ""));
                        if (!isNaN(num))
                            wsModel.append({
                                num: num,
                                active: active
                            });
                    }
                }
            }
        }

        Component.onCompleted: {
            niriWorkspacesProc.running = true;
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: niriWorkspacesProc.running = true
        }
    }
}
