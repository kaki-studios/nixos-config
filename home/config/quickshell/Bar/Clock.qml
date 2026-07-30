import Quickshell
import QtQuick

Item {
    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // Region {
    // intersection: Intersection.Subtract
    // item: Text {
    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm")
        color: "#cdd6f4"
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 16
            weight: Font.Bold
        }
    }
    // }
}
