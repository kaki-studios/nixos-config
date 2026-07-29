import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    implicitHeight: backlightLayout.implicitHeight
    implicitWidth: backlightLayout.implicitWidth

    RowLayout {
        id: backlightLayout
        spacing: 5
        Text {
            id: backlightText
            text: ""
            color: "#cdd6f4"
            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 16
            }
        }
        Text {
            id: backlightIcon
            text: "󰃠"
            color: "#b4befe"
            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 18
            }
        }
    }

    Scope {
        id: backlightMonitor
        property int currectBrightness: {
            const max = parseInt(maxBrightnessFile.text().trim());
            return max === 0 ? 0 : Math.round((parseInt(brightnessFile.text()) / max) * 100);
        }
        property int actualBrightness: parseInt(brightnessFile.text())
        property int maxBrightness: parseInt(maxBrightnessFile.text())
        readonly property string backlightPath: "/sys/class/backlight/intel_backlight/actual_brightness"
        readonly property string maxBrightnessPath: "/sys/class/backlight/intel_backlight/max_brightness"

        FileView {
            id: brightnessFile
            path: backlightMonitor.backlightPath
        }
        FileView {
            id: maxBrightnessFile
            path: backlightMonitor.maxBrightnessPath
            blockLoading: true
        }
    }

    Process {
        id: brightnessProc
        command: ["udevadm", "monitor", "--udev", "--subsystem=backlight"]
        stdout: SplitParser {
            onRead: line => {
                backlightText.text = backlightMonitor.currectBrightness + "%";
                if (line.includes("change"))
                    brightnessFile.reload();
            }
        }
    }

    Component.onCompleted: {
        brightnessProc.running = true;
    }
}
