import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: powerProfilesLayout
    spacing: 5
    Text {
        id: powerProfilesText
        text: {
            const profile = PowerProfiles.profile;
            if (profile == PowerProfile.Performance) {
                return "";
            }
            if (profile == PowerProfile.Balanced) {
                return "";
            }
            if (profile == PowerProfile.PowerSaver) {
                return "";
            }
            return "";
        }
        color: "#b4befe"
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 16
        }
    }
}
