import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property string icon: "?"
    property color accentColor: Theme.accentPrimary

    color: rootArea.containsMouse ? Theme.bgHover : Theme.bgSurface

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
        font.family: Theme.fontFamily
        font.pixelSize: 40
    }
}
