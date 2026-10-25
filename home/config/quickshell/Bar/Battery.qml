import QtQuick.Layouts
import Quickshell.Services.UPower
import QtQuick
import qs

RowLayout {
    id: batteryLayout
    spacing: 5
    property real battery: Math.round(UPower.displayDevice.percentage * 100)
    Text {
        id: batteryText
        text: parent.battery + "%"
        color: Theme.textPrimary
        font {
            family: Theme.fontFamily
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
        color: Theme.accentPrimary
        font {
            family: Theme.fontFamily
            pixelSize: 20
        }
    }
}
