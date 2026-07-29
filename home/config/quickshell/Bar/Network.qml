import QtQuick.Layouts
import QtQuick
import Quickshell.Networking

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
