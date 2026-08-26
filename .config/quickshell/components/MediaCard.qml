import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Widgets
import "../styles" as Styles

Rectangle {
    id: card

    property var player: null
    property var players: []
    property int playerIndex: 0
    signal selectPlayer(int index)

    readonly property bool playing: player?.isPlaying ?? false

    implicitHeight: inner.implicitHeight + 24
    radius: 18
    color: Styles.Theme.surface

    Timer {
        interval: 500
        repeat: true
        running: card.visible && card.playing && card.player !== null
        onTriggered: card.player.positionChanged()
    }

    ColumnLayout {
        id: inner
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // кнопки выбора плеера (видны, когда их больше одного)
        RowLayout {
            Layout.fillWidth: true
            visible: card.players.length > 1
            spacing: 6

            Repeater {
                model: card.players

                Rectangle {
                    id: playerChip
                    required property var modelData
                    required property int index

                    readonly property bool active: index === card.playerIndex

                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    radius: 13
                    color: active ? Styles.Theme.accent : (chipMa.containsMouse ? Styles.Theme.outline : Styles.Theme.groove)

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: playerChip.modelData?.identity || "Плеер"
                        color: playerChip.active ? Styles.Theme.bgBottom : Styles.Theme.textDim
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: playerChip.active
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    MouseArea {
                        id: chipMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.selectPlayer(playerChip.index)
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                id: art
                width: 56
                height: 56
                radius: 14
                clip: true
                color: Styles.Theme.surfaceHover
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1

                Image {
                    id: artImage
                    anchors.fill: parent
                    source: card.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }

                IconImage {
                    anchors.centerIn: parent
                    visible: artImage.status !== Image.Ready
                    source: Styles.Theme.icMusic
                    width: 22
                    height: 22
                    opacity: 0.7
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Item {
                    id: titleClip
                    Layout.fillWidth: true
                    height: titleText.implicitHeight
                    clip: true

                    Text {
                        id: titleText
                        text: card.player?.trackTitle || "Нет трека"
                        color: Styles.Theme.text
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true

                        readonly property bool overflow: contentWidth > titleClip.width + 2

                        onOverflowChanged: x = 0
                        SequentialAnimation on x {
                            loops: Animation.Infinite
                            running: titleText.overflow && card.visible
                            alwaysRunToEnd: true
                            PauseAnimation {
                                duration: 1600
                            }
                            NumberAnimation {
                                to: -(titleText.contentWidth - titleClip.width + 16)
                                duration: Math.max(1400, (titleText.contentWidth - titleClip.width) * 40)
                                easing.type: Easing.InOutSine
                            }
                            PauseAnimation {
                                duration: 2000
                            }
                            NumberAnimation {
                                to: 0
                                duration: Math.max(1400, (titleText.contentWidth - titleClip.width) * 40)
                                easing.type: Easing.InOutSine
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: card.player ? (card.player.trackArtist || "Неизвестный исполнитель") : ""
                    color: Styles.Theme.textDim
                    font.family: Styles.Theme.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: Styles.Theme.fmtSeconds(card.player?.position ?? 0)
                        color: Styles.Theme.textDim
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 9
                    }

                    Item {
                        id: seekTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 14

                        readonly property real ratio: card.player && card.player.length > 0 ? Math.min(1, (card.player?.position ?? 0) / card.player.length) : 0

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 4
                            radius: 2
                            color: Styles.Theme.groove
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: seekTrack.ratio * seekTrack.width
                            height: 4
                            radius: 2
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop {
                                    position: 0
                                    color: Styles.Theme.accent
                                }
                                GradientStop {
                                    position: 1
                                    color: Styles.Theme.accent2
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -5
                            cursorShape: Qt.PointingHandCursor

                            function seek(mouse) {
                                const p = card.player
                                if (!p || !p.canSeek || !p.positionSupported || p.length <= 0)
                                    return
                                const r = Math.max(0, Math.min(1, mouse.x / seekTrack.width))
                                p.position = r * p.length
                            }

                            onClicked: function(mouse) {
                                seek(mouse)
                            }
                            onPositionChanged: function(mouse) {
                                if (pressed)
                                    seek(mouse)
                            }
                        }
                    }

                    Text {
                        text: Styles.Theme.fmtSeconds(card.player?.length ?? 0)
                        color: Styles.Theme.textDim
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 9
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Rectangle {
                width: 38
                height: 38
                radius: 19
                color: prevMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                scale: prevMa.pressed ? 0.88 : prevMa.containsMouse ? 1.06 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: 110
                        easing.type: Easing.OutBack
                    }
                }

                IconImage {
                    anchors.centerIn: parent
                    source: Styles.Theme.icPrev
                    width: 17
                    height: 17
                    opacity: card.player?.canGoPrevious === false ? 0.3 : 1
                }

                MouseArea {
                    id: prevMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (card.player?.canGoPrevious)
                        card.player.previous()
                }
            }

            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: Styles.Theme.accent
                scale: playMa.pressed ? 0.9 : playMa.containsMouse ? 1.07 : 1

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0
                        color: Styles.Theme.accent
                    }
                    GradientStop {
                        position: 1
                        color: Styles.Theme.accent2
                    }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Styles.Theme.accent
                    shadowBlur: 0.6
                    shadowOpacity: card.playing ? 0.8 : 0.0
                    shadowVerticalOffset: 0
                    shadowHorizontalOffset: 0

                    Behavior on shadowOpacity {
                        NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutCubic
                        }
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 110
                        easing.type: Easing.OutBack
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Styles.Theme.surfaceHover
                    opacity: playMa.containsMouse ? 0.25 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 90
                        }
                    }
                }

                IconImage {
                    anchors.centerIn: parent
                    source: card.playing ? Styles.Theme.icPause : Styles.Theme.icPlay
                    width: 21
                    height: 21
                }

                MouseArea {
                    id: playMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (card.player?.canTogglePlaying)
                        card.player.togglePlaying()
                }
            }

            Rectangle {
                width: 38
                height: 38
                radius: 19
                color: nextMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                scale: nextMa.pressed ? 0.88 : nextMa.containsMouse ? 1.06 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: 110
                        easing.type: Easing.OutBack
                    }
                }

                IconImage {
                    anchors.centerIn: parent
                    source: Styles.Theme.icNext
                    width: 17
                    height: 17
                    opacity: card.player?.canGoNext === false ? 0.3 : 1
                }

                MouseArea {
                    id: nextMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (card.player?.canGoNext)
                        card.player.next()
                }
            }
        }
    }
}
