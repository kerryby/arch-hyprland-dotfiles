import Quickshell
import QtQuick

import ".."
PopupWindow {
    id: root

    property string title: ""
    property int subIndex: 0

    property var folders: [
        "Главная", "Медия", "Аудио", "Система",
        "Погода", "Календарь", "Уведомления"
    ]

    implicitWidth: Theme.subW
    implicitHeight: Math.max(180, contentLoader.implicitHeight + 70)
    visible: false

    function show() {
        visible = true
        box.scale = 0.9
        box.opacity = 0
        showAnim.start()
    }

    function hide() { hideAnim.start() }
    function hideNow() { hideAnim.stop(); visible = false }

    SequentialAnimation {
        id: showAnim
        ParallelAnimation {
            NumberAnimation { target: box; property: "scale"; from: 0.9; to: 1; duration: 250; easing.type: Easing.OutBack }
            NumberAnimation { target: box; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
        }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation { target: box; property: "scale"; to: 0.9; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { target: box; property: "opacity"; to: 0; duration: 150; easing.type: Easing.InCubic }
        }
        onFinished: visible = false
    }

    Rectangle {
        id: box
        anchors.fill: parent
        anchors.margins: 4
        radius: Theme.radius
        color: Theme.bgAlt

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
            spacing: 8

            Text {
                text: root.title
                color: Theme.accentGlow
                font.pixelSize: Theme.fontSize + 4
                font.family: Theme.font
                font.weight: Font.Bold
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.fgDim
                opacity: 0.2
            }

            Loader {
                id: contentLoader
                width: parent.width
                height: implicitHeight
                source: "../panels/" + folders[root.subIndex] + "/Content.qml"
            }
        }
    }
}
