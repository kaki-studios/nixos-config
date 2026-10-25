import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs

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
        color: Theme.accentPrimary
        font {
            family: Theme.fontFamily
            pixelSize: 16
        }
    }
}
