pragma ComponentBehavior: Bound
import Quickshell.Services.Mpris
import QtQuick

Item {
    id: mprisItem
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0)
            seconds = 0;
        let m = Math.floor(seconds / 60);
        let s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }
    Row {
        anchors.verticalCenter: parent.verticalCenter
        Row {
            id: contentRow
            width: 630
            clip: true
            spacing: 10

            anchors.verticalCenter: parent.verticalCenter
            Repeater {
                id: repeater
                model: Mpris.players

                delegate: Row {
                    id: playerRow

                    required property MprisPlayer modelData
                    onModelDataChanged: {
                        cachedDuration = modelData.lengthSupported ? modelData.length : 0;
                    }

                    spacing: 10
                    property real cachedDuration: modelData.length

                    Connections {
                        target: playerRow.modelData

                        function onTrackChanged() {
                            playerRow.cachedDuration = playerRow.modelData.lengthSupported ? playerRow.modelData.length : playerRow.cachedDuration;
                        }
                        function onLengthChanged() {
                            if (playerRow.modelData.lengthSupported)
                                playerRow.cachedDuration = playerRow.modelData.length;
                        }
                        function onLengthSupportedChanged() {
                            if (playerRow.modelData.lengthSupported)
                                playerRow.cachedDuration = playerRow.modelData.length;
                        }
                    }

                    Timer {
                        interval: 500
                        running: parent.modelData.playbackState == MprisPlaybackState.Playing
                        repeat: true
                        onTriggered: parent.modelData.positionChanged()
                    }

                    Separator {}
                    Text {
                        text: {
                            switch (parent.modelData.playbackState) {
                            case MprisPlaybackState.Playing:
                                return "";
                            case MprisPlaybackState.Paused:
                                return "";
                            case MprisPlaybackState.Stopped:
                                return "";
                            }
                        }
                        // color: "#6c7086"
                        color: "#cdd6f4"
                        anchors.verticalCenter: parent.verticalCenter
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: playerRow.modelData.togglePlaying()
                        }
                    }
                    Text {
                        id: titleText
                        text: parent.modelData.trackTitle.trim() + " - " + parent.modelData.trackArtist.trim()
                        // color: "#6c7086"
                        color: "#cdd6f4"
                        anchors.verticalCenter: parent.verticalCenter
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 12
                        }
                    }
                    Text {
                        id: positionText
                        text: {
                            if (parent.modelData.identity == "Mozilla firefox") {
                                //this is because Firefox doesn't properly indicate length when seeking so we cache the length
                                return formatTime(parent.modelData.position) + "/" + formatTime(parent.cachedDuration);
                            }
                            //normal players like spotifyd should behave normally
                            return formatTime(parent.modelData.position) + "/" + formatTime(parent.modelData.length);
                        }

                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 12
                        }
                        color: "#6c7086"
                        // color: "#cdd6f4"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
