import Quickshell
import QtQuick
import QtQuick.Effects
import "../../"
import Quickshell.Services.Mpris

Item {
    clip: true

    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    Flickable {
        anchors.fill: parent
        contentHeight: col.height + 12
        clip: true
        interactive: contentHeight > height

        Column {
            id: col
            width: parent.width
            spacing: 10
            anchors.top: parent.top
            anchors.topMargin: 12

            Rectangle {
                width: parent.width
                height: 200
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: Theme.borderDim
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 12

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 100; height: 100; radius: 16
                        color: player ? Theme.bgAlt : Theme.bgAlt

                        Image {
                            id: trackArt
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: player ? player.trackArtUrl || "" : ""
                            sourceSize { width: 200; height: 200 }
                            visible: player && status === Image.Ready
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskThresholdMin: 0.5
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "\u266B"
                            color: Theme.fgMuted
                            font.pixelSize: 28
                            visible: !player || !trackArt.visible
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: player ? player.trackTitle || "Не играет" : "Нет плеера"
                        color: Theme.fg
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        font.family: Theme.font
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: player ? player.trackArtist || "" : ""
                        color: Theme.fgDim
                        font.pixelSize: 11
                        font.family: Theme.font
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 60
                radius: Theme.radiusLg
                color: Theme.bgCard
                border.color: Theme.borderDim
                border.width: 1
                visible: player != null

                Row {
                    anchors.centerIn: parent
                    spacing: 16

                    Item {
                        width: 40; height: 40
                        Rectangle {
                            anchors.fill: parent; radius: 10
                            color: prevMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                        Text { anchors.centerIn: parent; text: "\u23EE"; color: player && player.canGoPrevious ? Theme.fg : Theme.fgMuted; font.pixelSize: 16 }
                        MouseArea { id: prevMa; anchors.fill: parent; hoverEnabled: true; enabled: player && player.canGoPrevious; cursorShape: Qt.PointingHandCursor; onClicked: if (player) player.previous() }
                    }

                    Item {
                        width: 44; height: 44
                        Rectangle {
                            anchors.fill: parent; radius: 12
                            color: playMa.containsMouse ? Theme.accentDim : Theme.accent
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                        Text { anchors.centerIn: parent; text: player && player.isPlaying ? "\u23F8" : "\u25B6"; color: "#fff"; font.pixelSize: 18 }
                        MouseArea { id: playMa; anchors.fill: parent; hoverEnabled: true; enabled: player && (player.canPlay || player.canPause); cursorShape: Qt.PointingHandCursor; onClicked: if (player) player.togglePlaying() }
                    }

                    Item {
                        width: 40; height: 40
                        Rectangle {
                            anchors.fill: parent; radius: 10
                            color: nextMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                        Text { anchors.centerIn: parent; text: "\u23ED"; color: player && player.canGoNext ? Theme.fg : Theme.fgMuted; font.pixelSize: 16 }
                        MouseArea { id: nextMa; anchors.fill: parent; hoverEnabled: true; enabled: player && player.canGoNext; cursorShape: Qt.PointingHandCursor; onClicked: if (player) player.next() }
                    }
                }
            }
        }
    }
}
