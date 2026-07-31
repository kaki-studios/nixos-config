pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

RowLayout {
    id: keyboardLayout

    Text {
        id: keyboardText
        property int currentLayout: 0
        property var layouts: []
        text: {
            return layouts[currentLayout];
        }
        color: "#cdd6f4"
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 14
        }
    }

    Process {
        id: niriKeyboardProc
        command: ["sh", "-c", "niri msg --json event-stream"]
        stdout: SplitParser {
            onRead: line => {
                if (!line.trim())
                    return;
                const event = JSON.parse(line);
                switch (Object.keys(event)[0]) {
                case "KeyboardLayoutSwitched":
                    keyboardText.currentLayout = event.KeyboardLayoutSwitched.idx;
                    break;
                case "KeyboardLayoutsChanged":
                    keyboardText.layouts = event.KeyboardLayoutsChanged.keyboard_layouts.names;
                    keyboardText.currentLayout = event.KeyboardLayoutsChanged.keyboard_layouts.current_idx;
                    break;
                }
            }
        }
    }
    Component.onCompleted: {
        niriKeyboardProc.running = true;
    }
}
