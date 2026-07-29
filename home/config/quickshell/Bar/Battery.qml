import QtQuick.Layouts
import Quickshell.Services.UPower
import QtQuick

RowLayout {
    id: batteryLayout
    spacing: 5
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
