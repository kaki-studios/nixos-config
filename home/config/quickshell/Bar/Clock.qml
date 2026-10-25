import Quickshell
import QtQuick
import qs

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
        color: Theme.textPrimary
        font {
            family: Theme.fontFamily
            pixelSize: 16
            weight: Font.Bold
        }
    }
    // }
}
