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
                        id: workspaceRepeater
                        model: niri.groups
                        delegate: Row {
                            height: 40
                            spacing: 10

                            Repeater {
                                model: modelData.workspaces
                                delegate: Text {
                                    text: modelData.active ? "" : ""
                                    color: modelData.focused ? "#b4befe" : "#6c7086"
                                    anchors.verticalCenter: parent.verticalCenter
                                    font {
                                        family: "JetBrainsMono Nerd Font"
                                        pixelSize: 18
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Qt.openUrlExternally("niri:workspace:" + modelData.id)
                                    }
                                }
                            }
                            Rectangle {
                                visible: index < niri.groups.length - 1
                                width: 1
                                height: 40
                                color: "#6c7086"
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

            Singleton {
                id: niri
                property var workspaces: ({}) //workspaceId to workspace object
                property var outputs: ({}) //outputs to activeWorkspace
                property var groups: [] //final product
                property int focusedId
                function workspaceGroups() {
                    let groups = {};

                    // Group workspaces by output
                    for (const id in workspaces) {
                        const ws = workspaces[id];

                        if (!groups[ws.output])
                            groups[ws.output] = [];

                        groups[ws.output].push({
                            id: ws.id,
                            idx: ws.idx,
                            active: false,
                            focused: false
                        });
                    }

                    // Mark active workspaces
                    for (const output in outputs) {
                        const activeId = outputs[output].activeWorkspace;

                        if (!groups[output])
                            continue;
                        for (const ws of groups[output]) {
                            ws.active = ws.id === activeId;
                            ws.focused = ws.id === focusedId;
                        }
                    }

                    // Convert object -> array for Repeater
                    return Object.keys(groups).map(output => ({
                                output: output,
                                workspaces: groups[output].sort((a, b) => a.idx - b.idx)
                            }));
                }
                Process {
                    id: niriWorkspacesProc
                    command: ["sh", "-c", "niri msg --json event-stream"]
                    stdout: SplitParser {
                        onRead: line => {
                            if (!line.trim())
                                return;
                            const event = JSON.parse(line);
                            switch (Object.keys(event)[0]) {
                            case "WorkspacesChanged": //we rebuild the data structure
                                niri.workspaces = ({});
                                niri.outputs = ({});
                                niri.groups = [];
                                for (const ws of event.WorkspacesChanged.workspaces) {
                                    niri.workspaces[ws.id] = ws;
                                    if (!(ws.output in niri.outputs)) {
                                        niri.outputs[ws.output] = {
                                            activeWorkspace: null
                                        };
                                    }
                                    if (ws.is_active) {
                                        niri.outputs[ws.output].activeWorkspace = ws.id;
                                    }
                                    if (ws.is_focused) {
                                        niri.focusedId = ws.id;
                                    }
                                }
                                break;
                            case "WorkspaceActivated":
                                let ws = niri.workspaces[event.WorkspaceActivated.id];
                                if (event.WorkspaceActivated.focused)
                                    niri.focusedId = event.WorkspaceActivated.id;
                                if (ws) {
                                    niri.outputs[ws.output].activeWorkspace = ws.id;
                                }
                                break;
                            }
                            const res = niri.workspaceGroups();
                            niri.groups = res;
                        }
                    }
                }
            }

            Scope {
                id: backlightMonitor
                property int currectBrightness: {
                    const max = parseInt(maxBrightnessFile.text().trim());
                    return max === 0 ? 0 : Math.round((parseInt(brightnessFile.text()) / max) * 100);
                }
                property int actualBrightness: parseInt(brightnessFile.text())
                property int maxBrightness: parseInt(maxBrightnessFile.text())
                readonly property string backlightPath: "/sys/class/backlight/intel_backlight/actual_brightness"
                readonly property string maxBrightnessPath: "/sys/class/backlight/intel_backlight/max_brightness"

                FileView {
                    id: brightnessFile
                    path: backlightMonitor.backlightPath
                }
                FileView {
                    id: maxBrightnessFile
                    path: backlightMonitor.maxBrightnessPath
                    blockLoading: true
                }
            }

            Process { // TODO don't run if not available
                id: brightnessProc
                command: ["udevadm", "monitor", "--udev", "--subsystem=backlight"]
                // property int lastExitCode: -1
                // onExited: (exitCode, exitStatus) => {
                // lastExitCode = exitCode;
                // }
                stdout: SplitParser {
                    onRead: line => {
                        backlightText.text = backlightMonitor.currectBrightness + "%";
                        if (line.includes("change"))
                            brightnessFile.reload();
                    }
                }
            }

            Component.onCompleted: {
                niriWorkspacesProc.running = true;
                brightnessProc.running = true;
            }
        }
    }
}
