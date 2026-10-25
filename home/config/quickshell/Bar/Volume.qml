// import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs

Item {
    implicitHeight: volumeLayout.implicitHeight
    implicitWidth: volumeLayout.implicitWidth
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
    RowLayout {
        id: volumeLayout
        spacing: 5

        Text {
            id: volumeText
            text: Pipewire.defaultAudioSink ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : "0%"
            color: Theme.textPrimary
            font {
                family: Theme.fontFamily
                pixelSize: 16
            }
        }
        Text {
            id: volumeIcon
            text: {
                if (Pipewire.defaultAudioSink.audio.muted) {
                    return "";
                }
                let vol = Pipewire.defaultAudioSink ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) : 0;
                let volumeIcons = ["", "", "󰕾", "󰕾", "󰕾", "", "", ""]; // 8 icons
                return volumeIcons[Math.floor((vol * 8 / 101))];
                // return Math.round(vol / 12.5);
            }
            color: Theme.accentPrimary
            font {
                family: Theme.fontFamily
                pixelSize: 16
            }
        }
    }
}
