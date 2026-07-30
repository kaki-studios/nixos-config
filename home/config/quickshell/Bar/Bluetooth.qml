import Quickshell.Bluetooth
import Quickshell
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 5
    // property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    Text {
        text: {
            const adapter = Bluetooth.defaultAdapter;
            if (!adapter.enabled) {
                return "";
            }
            if (adapter.devices.values) {
                if (adapter.devices.values[0].connected) {
                    return adapter.devices.values[0].name;
                }
                if (adapter.devices.values[0].state == BluetoothDeviceState.Connecting) {
                    return adapter.devices.values[0].name;
                }
                return adapter.devices.values[0].name;
            }
            return "";
        }
        color: "#cdd6f4"
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 14
        }
    }
    Text {
        text: {
            const adapter = Bluetooth.defaultAdapter;
            if (!adapter.enabled) {
                return "󰂲";
            }
            if (adapter.devices.values) {
                if (adapter.devices.values[0].connected) {
                    return "󰂯";
                }
                if (adapter.devices.values[0].state == BluetoothDeviceState.Connecting) {
                    return "󰂱";
                }
                return "󰂲";
            }
            if (adapter.discovering) {
                return "󰂱";
            }
            return "";
        }
        color: "#b4befe"
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 18
        }
    }

    MouseArea {
        visible: false
        // anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {
            console.log("here");
            Quickshell.execDetached("blueman-manager");
        }
    }

    MouseArea {
        // anchors.fill: parent
        visible: false
        acceptedButtons: Qt.RightButton
        onClicked: {
            const adapter = Bluetooth.defaultAdapter;
            for (const device of adapter.devices.values) {
                device.connected = !device.connected;
            }
            if (!adapter.devices.values) {
                adapter.enabled = adapter.enabled;
            }
        }
    }
}
