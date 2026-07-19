import Quickshell
import QtQuick

import ".."
PopupWindow {
    id: root
    implicitWidth: Theme.popupW + Theme.subW + 14
    implicitHeight: 340
    visible: false
    color: "transparent"

    property bool isOpen: false
    property int selectedIndex: 0

    property var folders: [
        "Главная", "Медия", "Аудио", "Система",
        "Погода", "Календарь", "Уведомления"
    ]

    function toggle() {
        isOpen = !isOpen
        if (isOpen) {
            visible = true
            container.scale = 0.85
            container.opacity = 0
            animIn.start()
        } else {
            animOut.start()
        }
    }

    SequentialAnimation {
        id: animIn
        ParallelAnimation {
            NumberAnimation { target: container; property: "scale"; from: 0.85; to: 1; duration: 250; easing.type: Easing.OutBack }
            NumberAnimation { target: container; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
        }
    }

    SequentialAnimation {
        id: animOut
        ParallelAnimation {
            NumberAnimation { target: container; property: "scale"; to: 0.85; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { target: container; property: "opacity"; to: 0; duration: 150; easing.type: Easing.InCubic }
        }
        onFinished: { visible = false; isOpen = false }
    }

    Rectangle {
        id: container
        anchors.fill: parent
        anchors.margins: 4
        radius: Theme.radius
        color: Theme.bgAlt

        Row {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            Rectangle {
                id: leftCol
                width: Theme.popupW
                height: parent.height
                radius: Theme.radius
                color: Theme.bg

                Column {
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 4 }
                    spacing: 2

                    Repeater {
                        model: [
                            { icon: "\u2302", label: "Главная" },
                            { icon: "\u266B", label: "Медия" },
                            { icon: "\u266A", label: "Аудио" },
                            { icon: "\u2699", label: "Система" },
                            { icon: "\u2600", label: "Погода" },
                            { icon: "\u25F7", label: "Календарь" },
                            { icon: "\u2630", label: "Уведомления" }
                        ]

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width: parent.width
                            height: 34

                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: selectedIndex = index
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: index === selectedIndex
                                    ? Theme.accent
                                    : ma.containsMouse
                                        ? Qt.rgba(1,1,1,0.08)
                                        : "transparent"
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            Text {
                                text: modelData.icon
                                color: Theme.fg
                                font.pixelSize: 16
                                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            }

                            Text {
                                text: modelData.label
                                color: Theme.fg
                                font.pixelSize: Theme.fontSize
                                font.family: Theme.font
                                font.weight: index === selectedIndex ? Font.Bold : Font.Normal
                                anchors { left: parent.left; leftMargin: 34; verticalCenter: parent.verticalCenter }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: contentBg
                width: Theme.subW
                height: parent.height
                radius: Theme.radius
                color: Theme.bgAlt

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    anchors.margins: 8
                    source: "../panels/" + folders[selectedIndex] + "/Content.qml"
                }

                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }
    }
}
