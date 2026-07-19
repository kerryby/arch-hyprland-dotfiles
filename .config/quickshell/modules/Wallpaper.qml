import Quickshell
import QtQuick
import QtQuick.Effects
import ".."
import Quickshell.Io

PopupWindow {
    id: root
    implicitWidth: 520
    implicitHeight: 420
    visible: false
    color: "transparent"

    property bool isOpen: false
    property var wallpapers: []
    property string selectedWall: ""

    function toggle() {
        isOpen = !isOpen
        if (isOpen) {
            visible = true
            container.scale = 0.85
            container.opacity = 0
            animIn.start()
            scanWallpapers()
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

    Process {
        id: scanProc
        command: ["bash", "-c", "ls /home/kerry/Pictures/wallpapers/*.{jpg,png,jpeg} 2>/dev/null"]
        stdout: StdioCollector { id: scanOut; waitForEnd: true }
        onExited: {
            var lines = scanOut.text.trim().split("\n")
            var list = []
            for (var i = 0; i < lines.length; i++) {
                var p = lines[i].trim()
                if (p.length > 0) list.push(p)
            }
            wallpapers = list
        }
    }

    signal wallpaperChanged()

    Process {
        id: setProc
        command: []
        running: false
        onExited: wallpaperChanged()
    }

    function scanWallpapers() {
        scanProc.running = true
    }

    function setWallpaper(path) {
        setProc.command = ["bash", "-c", "wal -i " + path + " -q -n && awww img " + path]
        setProc.running = true
        selectedWall = path
    }

    Rectangle {
        id: container
        anchors.fill: parent
        anchors.margins: 4
        radius: Theme.radiusLg
        color: Theme.bgAlt

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Row {
                width: parent.width
                spacing: 8

                Text {
                    text: "\uD83D\uDDBC \u041E\u0431\u043E\u0438"
                    color: Theme.fg
                    font.pixelSize: Theme.fontSize + 3
                    font.family: Theme.font
                    font.weight: Font.Bold
                }

                Item { width: parent.width - 170; height: 1 }

                Rectangle {
                    width: 90; height: 28; radius: 6
                    color: refreshBtn.containsMouse ? Qt.rgba(1,1,1,0.12) : Qt.rgba(1,1,1,0.06)
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\u21BB " + (wallpapers.length > 0 ? wallpapers.length + " \u0448\u0442" : "\u041E\u0431\u043D\u043E\u0432\u0438\u0442\u044C")
                        color: Theme.fgDim
                        font.pixelSize: Theme.fontSize - 1
                        font.family: Theme.font
                    }

                    MouseArea {
                        id: refreshBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: scanWallpapers()
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.borderDim }

            Rectangle {
                width: parent.width
                height: parent.height - 60
                radius: Theme.radiusSm
                color: Theme.bg
                clip: true

                GridView {
                    id: wallGrid
                    anchors.fill: parent
                    anchors.margins: 6
                    cellWidth: 120
                    cellHeight: 90
                    model: wallpapers
                    clip: true

                    delegate: Item {
                        required property var modelData
                        required property int index

                        width: wallGrid.cellWidth
                        height: wallGrid.cellHeight

                        Rectangle {
                            anchors { fill: parent; margins: 4 }
                            radius: 8
                            color: Theme.bgCard
                            border.color: selectedWall === modelData ? Theme.accent : ma.containsMouse ? Qt.rgba(1,1,1,0.15) : "transparent"
                            border.width: selectedWall === modelData ? 2 : 1
                            clip: true

                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            Image {
                                anchors.fill: parent
                                source: "file://" + modelData
                                fillMode: Image.PreserveAspectCrop
                                sourceSize { width: 240; height: 180 }
                                smooth: true
                                mipmap: true

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 20
                                    color: Qt.rgba(0, 0, 0, 0.5)

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.split("/").pop()
                                        color: Qt.rgba(1,1,1,0.8)
                                        font.pixelSize: 8
                                        font.family: Theme.font
                                        elide: Text.ElideRight
                                        width: parent.width - 8
                                    }
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: selectedWall === modelData ? Theme.accent : "transparent"
                                border.width: 2
                                radius: 8
                            }

                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: setWallpaper(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
