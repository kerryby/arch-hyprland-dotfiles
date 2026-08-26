import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../styles" as Styles

Item {
    id: row

    property string icon: ""
    property real value: 0
    property bool muted: false
    property color accentColor: Styles.Theme.accent

    signal edited(real v)
    signal toggleMuted()

    implicitHeight: 30

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Item {
            width: 30
            height: 30

            Rectangle {
                anchors.fill: parent
                radius: 9
                color: muteMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            IconImage {
                anchors.centerIn: parent
                source: row.icon
                width: 16
                height: 16
            }

            MouseArea {
                id: muteMa
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: row.toggleMuted()
            }
        }

        Item {
            id: track
            Layout.fillWidth: true
            Layout.preferredHeight: 22

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 5
                radius: 2.5
                color: Styles.Theme.groove
            }

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(5, row.value * track.width)
                height: 5
                radius: 2.5
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0
                        color: row.muted ? Styles.Theme.textDim : row.accentColor
                    }
                    GradientStop {
                        position: 1
                        color: Qt.lighter(row.muted ? Styles.Theme.textDim : row.accentColor, 1.3)
                    }
                }
                Behavior on width {
                    enabled: !dragArea.pressed
                    NumberAnimation {
                        duration: 80
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Rectangle {
                readonly property real cx: Math.min(track.width, Math.max(0, row.value * track.width))
                x: cx - width / 2
                anchors.verticalCenter: parent.verticalCenter
                width: 13
                height: 13
                radius: 6.5
                color: "#e6e9f5"
                border.color: row.muted ? Styles.Theme.red : row.accentColor
                border.width: 3
                scale: dragArea.containsMouse || dragArea.pressed ? 1.25 : 1
                Behavior on scale {
                    NumberAnimation {
                        duration: 80
                    }
                }
            }

            MouseArea {
                id: dragArea
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: function(mouse) {
                    commit(mouse.x)
                }
                onPositionChanged: function(mouse) {
                    if (pressed)
                        commit(mouse.x)
                }

                function commit(x) {
                    row.edited(Math.max(0, Math.min(1, x / track.width)))
                }
            }
        }

        Text {
            Layout.preferredWidth: 44
            text: Math.round(row.value * 100) + "%"
            color: row.muted ? Styles.Theme.red : Styles.Theme.textDim
            font.family: Styles.Theme.fontFamily
            font.pixelSize: 11
            horizontalAlignment: Text.AlignRight
        }
    }
}
