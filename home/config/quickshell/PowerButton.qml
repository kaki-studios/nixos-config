import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property string icon: "?"
    property color accentColor: "#b4befe"

    color: rootArea.containsMouse ? "#45475a" : "#313244"

    MouseArea {
        id: rootArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    signal clicked

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.accentColor
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 40
    }
}
