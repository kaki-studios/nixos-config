import QtQuick.Layouts
import QtQuick
import Quickshell.Networking
import qs

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
        color: Theme.textPrimary
        font {
            family: Theme.fontFamily
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
        color: Theme.accentPrimary
        font {
            family: Theme.fontFamily
            pixelSize: 16
        }
    }
}
