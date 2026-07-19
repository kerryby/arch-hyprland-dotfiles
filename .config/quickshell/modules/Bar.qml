import Quickshell
import QtQuick
import QtQuick.Effects
import ".."

PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barH
    exclusiveZone: Theme.barH
    color: "transparent"

    property bool launcherActive: false
    property string launcherQuery: ""

    focusable: true

    signal openLauncher()
    signal openWallpaper()
    signal lockScreen()

    Row {
        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
        spacing: 4

        BarButton {
            text: "\uD83D\uDD0D"
            onClicked: bar.openLauncher()
        }

        BarButton {
            text: "\uD83D\uDDBC"
            onClicked: bar.openWallpaper()
        }
    }

    Item {
        id: pill
        anchors.centerIn: parent
        width: pillWidth
        height: parent.height - 2

        property real pillWidth: clockText.width + 36
        property real targetWidth: clockText.width + 36

        NumberAnimation {
            id: pillAnim
            target: pill
            property: "pillWidth"
            duration: 250
            easing.type: Easing.OutCubic
            onFinished: {
                if (bar.launcherActive) {
                    searchFadeTimer.start()
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: height / 2
            color: launcherActive ? Theme.bgAlt : Theme.bg
            Behavior on color { ColorAnimation { duration: 200 } }

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "transparent"
                border.color: launcherActive ? Theme.accent : Theme.fgDim
                border.width: launcherActive ? 2 : 1
                opacity: launcherActive ? 0.8 : 0.12
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on border.width { NumberAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: mouse.containsMouse && !launcherActive ? Qt.rgba(1,1,1,0.06) : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Timer {
            id: searchFadeTimer
            interval: 1
            onTriggered: { if (bar.launcherActive) searchRow.opacity = 1 }
        }

        Row {
            id: searchRow
            anchors.centerIn: parent
            spacing: 8
            visible: launcherActive
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

            Text {
                text: "\uF002"
                color: searchInput.activeFocus ? Theme.accent : Theme.fgDim
                font.family: Theme.font
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            TextInput {
                id: searchInput
                width: 200
                color: Theme.fg
                font.pixelSize: Theme.fontSize + 1
                font.family: Theme.font
                clip: true
                verticalAlignment: TextInput.AlignVCenter
                cursorVisible: true
                focus: launcherActive
                Keys.onEscapePressed: bar.openLauncher()
                Keys.onPressed: {
                    if (event.key === Qt.Key_Down || event.key === Qt.Key_Up || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        launcher.handleKey(event)
                        event.accepted = true
                    }
                }
                onTextChanged: launcherQuery = text
            }
        }

        Text {
            id: clockText
            anchors.centerIn: parent
            color: Theme.fg
            font.pixelSize: Theme.fontSize + 3
            font.family: Theme.font
            font.weight: launcherActive ? Font.Bold : Font.Medium
            visible: !launcherActive
            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }
            text: Qt.formatDateTime(clock.date, "HH:mm")
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!launcherActive) {
                    menu.toggle()
                }
            }
        }
    }

    Row {
        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
        spacing: 4

        BarButton {
            text: "\uD83D\uDD12"
            onClicked: bar.lockScreen()
        }
    }

    MainMenu {
        id: menu
        anchor.window: bar
        anchor.rect.x: bar.width / 2 - width / 2
        anchor.rect.y: bar.height
    }

    onLauncherActiveChanged: {
        if (launcherActive) {
            searchInput.text = ""
            searchRow.opacity = 0
            pill.targetWidth = searchRow.implicitWidth + 24
        } else {
            pill.targetWidth = clockText.width + 36
        }
        pillAnim.from = pill.pillWidth
        pillAnim.to = pill.targetWidth
        pillAnim.start()
    }
}