import Quickshell
import QtQuick

import ".."

PopupWindow {
    id: root
    implicitWidth: 520
    implicitHeight: appModel.count > 0 ? Math.min(28 + appModel.count * 48 + (appModel.count - 1) * 2, 500) : 1

    visible: false
    color: "transparent"

    property bool isOpen: false
    property var allApps: []
    property string filterText: ""
    property bool hasResults: appModel.count > 0

    function toggle() {
        isOpen = !isOpen
        if (isOpen) {
            visible = true
            filterText = ""
            rebuildModel()
            container.opacity = 0
            animIn.start()
        } else {
            animOut.start()
        }
    }

    SequentialAnimation {
        id: animIn
        NumberAnimation { target: container; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: animOut
        NumberAnimation { target: container; property: "opacity"; to: 0; duration: 150; easing.type: Easing.InCubic }
        onFinished: { visible = false; isOpen = false }
    }

    ListModel { id: appModel }

    function rebuildModel() {
        appModel.clear()
        allApps = []
        var apps = DesktopEntries.applications
        if (apps && apps.values) {
            for (var i = 0; i < apps.values.length; i++) {
                var e = apps.values[i]
                if (!e || e.noDisplay) continue
                var iconPath = e.icon ? Quickshell.iconPath(e.icon) || "" : ""
                allApps.push({name:e.name||"",genericName:e.genericName||"",icon:e.icon||"",iconPath:iconPath,entry:e})
            }
        }
        updateFilter()
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            if (root.isOpen) rebuildModel()
        }
    }

    function updateFilter() {
        appModel.clear()
        var q = filterText.toLowerCase().trim()
        if (q.length === 0) { appView.currentIndex = 0; return }
        for (var i = 0; i < allApps.length; i++) {
            var item = allApps[i]
            var name = item.name.toLowerCase()
            var genName = item.genericName.toLowerCase()
            if (name.indexOf(q) >= 0 || genName.indexOf(q) >= 0) {
                appModel.append(item)
            }
        }
        appView.currentIndex = 0
    }

    function handleKey(event) {
        if (event.key === Qt.Key_Down) {
            if (appView.currentIndex < appModel.count - 1)
                appView.currentIndex++
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            if (appView.currentIndex > 0)
                appView.currentIndex--
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            launchCurrent()
            event.accepted = true
        }
    }

    function launchCurrent() {
        if (appModel.count === 0) return
        var item = appModel.get(appView.currentIndex)
        if (item && item.entry) {
            item.entry.execute()
            root.toggle()
        }
    }

    onFilterTextChanged: updateFilter()

    Rectangle {
        id: container
        anchors.fill: parent
        anchors.margins: 4
        radius: Theme.radiusLg
        color: root.hasResults ? Theme.bgAlt : "transparent"
        border.color: root.hasResults ? Qt.rgba(1, 1, 1, 0.04) : "transparent"
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: 8
            radius: Theme.radius
            color: root.hasResults ? Theme.bg : "transparent"
            clip: true

            ListView {
                id: appView
                anchors.fill: parent
                anchors.margins: 4
                spacing: 2
                currentIndex: 0
                clip: true
                model: appModel

                delegate: Item {
                    required property var modelData
                    required property int index

                    width: appView.width
                    height: 48

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusSm
                        color: {
                            if (appView.currentIndex === index) return Theme.accent
                            if (ma.containsMouse) return Theme.surface
                            return "transparent"
                        }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Item {
                            anchors.fill: parent
                            anchors.margins: 8

                            Row {
                                anchors.fill: parent
                                spacing: 10

                            Rectangle {
                                width: 32; height: 32; radius: 8
                                color: Theme.bgCard
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    sourceSize { width: 28; height: 28 }
                                    asynchronous: true
                                    smooth: true
                                    fillMode: Image.PreserveAspectFit
                                    source: modelData.iconPath || undefined
                                }
                            }

                                Column {
                                    width: parent.width - 42
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        width: parent.width
                                        text: modelData.name
                                        color: appView.currentIndex === index ? "#fff" : Theme.fg
                                        font.pixelSize: Theme.fontSize + 2
                                        font.family: Theme.font
                                        font.weight: appView.currentIndex === index ? Font.Bold : Font.Normal
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        width: parent.width
                                        text: modelData.genericName
                                        color: appView.currentIndex === index ? Qt.rgba(1,1,1,0.75) : Theme.fgDim
                                        font.pixelSize: Theme.fontSize - 1
                                        font.family: Theme.font
                                        elide: Text.ElideRight
                                        visible: text.length > 0
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            appView.currentIndex = index
                            var entry = appModel.get(index).entry
                            if (entry) entry.execute()
                            root.toggle()
                        }
                    }
                }
            }
        }
    }
}