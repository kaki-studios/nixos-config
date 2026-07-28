import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
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
    Variants {
        model: Quickshell.screens
        PanelWindow {
            property var modelData
            screen: modelData
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
                    Component {
                        id: separatorComponent
                        Rectangle {
                            width: 1
                            height: 40
                            color: "#6c7086"
                        }
                    }

                    Repeater {
                        model: wsModel
                        delegate: Row {
                            height: 40
                            spacing: 10
                            Loader {
                                active: insertSeparator
                                sourceComponent: separatorComponent
                            }

                            Text {
                                text: active ? "" : ""
                                color: active ? "#b4befe" : "#6c7086"
                                anchors.verticalCenter: parent.verticalCenter
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
                    }

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
                                pixelSize: 14
                            }
                        }

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
                    }
                    Rectangle {
                        width: 1
                        height: 40
                        color: "#6c7086"
                    }
                    RowLayout { //TODO disable when not available
                        id: backlightLayout
                        spacing: 5
                        Text {
                            id: backlightText
                            text: ""
                            color: "#cdd6f4"
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 16
                            }
                        }
                        Text {
                            id: backlightIcon
                            text: "󰃠"
                            color: "#b4befe"
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 18
                            }
                        }
                    }
                    Rectangle {
                        width: 1
                        height: 40
                        color: "#6c7086"
                    }
                    RowLayout { // TODO only render if UPower.displayDevice.ready
                        id: batteryLayout
                        spacing: 5
                        visible: UPower.displayDevice.ready //Need better solution with components and loaders (see this bar's workspace setup)
                        property real battery: Math.round(UPower.displayDevice.percentage * 100)
                        Text {
                            id: batteryText
                            text: parent.battery + "%"
                            color: "#cdd6f4"
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 16
                            }
                        }
                        Text {
                            id: batteryIcon
                            text: {
                                if (UPower.displayDevice.state == UPowerDeviceState.Charging) {
                                    return "󰂄";
                                }
                                let batteryIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]; // 10 icons
                                return batteryIcons[Math.floor(parent.battery * 10 / 101)];
                            }
                            color: "#b4befe"
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 20
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
                                if (Pipewire.defaultAudioSink.audio.muted) {
                                    return "";
                                }
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
                        var monitorCount = 0;
                        var insertSeparatorNext = false;
                        wsModel.clear();
                        for (var i = 0; i < lines.length; i++) {
                            var line = lines[i];
                            if (!line.trim())
                                continue;
                            if (line.indexOf("Output") >= 0) {
                                monitorCount++;
                                insertSeparatorNext = true;
                                continue;
                            }
                            var active = line.indexOf("*") >= 0;
                            var num = parseInt(line.replace(/[*\s]/g, "")); // NOTE doesn't support named workspaces
                            if (!isNaN(num)) {
                                var separator = (monitorCount > 1) && insertSeparatorNext;
                                wsModel.append({
                                    insertSeparator: separator,
                                    num: num,
                                    active: active
                                });
                            }
                            insertSeparatorNext = false;
                        }
                    }
                }
            }

            Process { // TODO don't run if not available
                id: brightnessProc
                command: ["sh", "-c", "brightnessctl -m"]
                property int lastExitCode: -1
                onExited: (exitCode, exitStatus) => {
                    lastExitCode = exitCode;
                }
                stdout: StdioCollector {
                    onStreamFinished: {
                        var items = this.text.split(",");
                        var text = items[3];
                        backlightText.text = text;
                    }
                }
            }

            Component.onCompleted: {
                niriWorkspacesProc.running = true;
                brightnessProc.running = true;
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    niriWorkspacesProc.running = true;
                    if (brightnessProc.lastExitCode == 0) //only if it's working correctly
                        brightnessProc.running = true;
                }
            }
        }
    }
}
