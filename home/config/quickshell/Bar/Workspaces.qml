pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

Item {
    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth

    Row {
        id: content
        spacing: 10
        Repeater {
            id: workspaceRepeater
            model: niri.groups
            delegate: Row {
                anchors.verticalCenter: parent.verticalCenter
                required property var modelData
                required property int index
                spacing: 10

                Repeater {
                    model: parent.modelData.workspaces
                    delegate: Text {
                        required property var modelData
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
                            onClicked: Qt.openUrlExternally("niri:workspace:" + parent.modelData.id)
                        }
                    }
                }
                Separator {
                    visible: parent.index < niri.groups.length - 1
                }
            }
        }
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
    QtObject {
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
    }

    Component.onCompleted: {
        niriWorkspacesProc.running = true;
    }
}
