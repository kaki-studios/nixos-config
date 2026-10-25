import Quickshell.Bluetooth
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs

Item {
    implicitHeight: bluetoothLayout.implicitHeight
    implicitWidth: bluetoothLayout.implicitWidth

    RowLayout {
        id: bluetoothLayout
        spacing: 5
        Text {
            text: {
                const adapter = Bluetooth.defaultAdapter;
                if (!adapter.enabled) {
                    return "";
                }
                if (adapter.devices.values) {
                    return adapter.devices.values[0].name;
                }
                return "";
            }
            color: Theme.textPrimary
            font {
                family: Theme.fontFamily
                pixelSize: 14
            }
        }
        Text {
            text: {
                const adapter = Bluetooth.defaultAdapter;
                if (!adapter || !adapter.enabled) {
                    return "󰂲";
                }
                if (adapter.devices.values) {
                    const device = adapter.devices.values[0];
                    if (device.connected) {
                        return "󰂯";
                    }
                    if (device.state == BluetoothDeviceState.Connecting || device.state == BluetoothDeviceState.Disconnecting) {
                        return "󰂱";
                    }
                    return "󰂲";
                }
                if (adapter.discovering) {
                    return "󰂱";
                }
                return "";
            }
            color: Theme.accentPrimary
            font {
                family: Theme.fontFamily
                pixelSize: 20
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {
            console.log("here");
            Quickshell.execDetached("blueman-manager");
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            const adapter = Bluetooth.defaultAdapter;
            console.log(Bluetooth.adapters.values.length);
            for (const device of adapter.devices.values) {
                device.connected = !device.connected;
            }
            if (!adapter.devices.values) {
                adapter.enabled = adapter.enabled;
            }
        }
    }
}
