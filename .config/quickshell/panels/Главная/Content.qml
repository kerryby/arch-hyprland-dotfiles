import Quickshell
import QtQuick
import QtQuick.Effects
import "../../"
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland._IdleInhibitor

Item {
    id: rootItem
    clip: true

    property string userName: ""
    property string wallpaperPath: ""
    property color wallpaperColor: "#1a1a2e"
    property bool hasWallpaper: false
    property bool wifiOn: false
    property bool caffeineOn: false
    property bool nightLightOn: false
    property bool dndOn: false
    property string perfMode: "balanced"

    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: wallProc.running = true
    }

    Process {
        id: userProc
        command: ["bash", "-c", "whoami"]
        stdout: StdioCollector {
            onDataChanged: {
                var t = text.trim()
                if (t.length > 0) userName = t
            }
        }
        running: true
    }

    Process {
        id: wallProc
        command: ["bash", "-c", "ls /home/kerry/Pictures/wallpapers/*.{jpg,png,jpeg} 2>/dev/null | head -1"]
        stdout: StdioCollector {
            id: wallStdout
        }
        onExited: {
            var v = wallStdout.text.trim()
            if (v.length > 0 && v.charAt(0) === "/") {
                wallpaperPath = v
                hasWallpaper = true
            }
        }
        running: true
    }

    Process {
        id: schemeProc
        command: ["bash", "-c", "grep 'background' /home/kerry/.config/hypr/scheme/current.lua 2>/dev/null | grep -oP '\\\"[0-9a-fA-F]+\\\"' | tr -d '\"'"]
        stdout: StdioCollector {
            onDataChanged: {
                var v = text.trim()
                if (v.match(/^[0-9a-fA-F]{6,8}$/)) {
                    wallpaperColor = "#" + v
                }
            }
        }
        running: true
    }



    Process {
        id: wifiProc
        command: ["bash", "-c", "nmcli -t -f WIFI general status"]
        stdout: StdioCollector {
            onDataChanged: wifiOn = text.trim() === "enabled"
        }
        running: true
    }

    Process {
        id: dndProc
        command: ["bash", "-c", "makoctl mode"]
        stdout: StdioCollector {
            onDataChanged: dndOn = text.indexOf("dnd") >= 0
        }
        running: true
    }

    Process {
        id: perfProc
        command: ["bash", "-c", "powerprofilesctl get"]
        stdout: StdioCollector {
            onDataChanged: {
                var t = text.trim()
                if (t.length > 0) perfMode = t
            }
        }
        running: true
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mainRow.height + 12
        clip: true
        interactive: contentHeight > height

        Row {
            id: mainRow
            anchors { top: parent.top; topMargin: 12 }
            width: parent.width
            spacing: 10

            Column {
                id: leftCol
                width: parent.width - rightCol.width - 10
                spacing: 10

                Rectangle {
                    width: parent.width
                    height: 130
                    radius: Theme.radiusLg
                    border.color: Theme.borderDim
                    border.width: 1

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusLg
                        clip: true
                        color: "transparent"

                        Image {
                            id: wallpaperImg
                            anchors.fill: parent
                            source: hasWallpaper ? "file://" + wallpaperPath : ""
                            fillMode: Image.PreserveAspectCrop
                            visible: hasWallpaper
                            smooth: true
                            mipmap: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: hasWallpaper ? Qt.rgba(0,0,0,0.2) : wallpaperColor
                        }

                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Qt.rgba(0,0,0,0.5) }
                                GradientStop { position: 0.45; color: Qt.rgba(0,0,0,0.1) }
                                GradientStop { position: 1.0; color: Qt.rgba(0,0,0,0) }
                            }
                        }

                        Rectangle {
                            anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                            height: 1
                            color: Qt.rgba(1,1,1,0.06)
                        }

                        Row {
                            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                            spacing: 12

                            Rectangle {
                                width: 46; height: 46; radius: 23
                                color: Theme.accent

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: Theme.accentGlow
                                    shadowBlur: 0.5
                                    shadowOpacity: 0.6
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: userName.charAt(0).toUpperCase()
                                    color: "#fff"
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: userName
                                    color: "#fff"
                                    font.pixelSize: 17
                                    font.weight: Font.Bold
                                    font.family: Theme.font
                                    font.letterSpacing: 0.3
                                }

                                Text {
                                    text: "Welcome to Arch Linux Hyprland"
                                    color: Qt.rgba(1,1,1,0.65)
                                    font.pixelSize: 11
                                    font.family: Theme.font
                                    font.letterSpacing: 0.5
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: playerSection
                    width: parent.width
                    height: playerCol.height + 14
                    radius: Theme.radiusLg
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Column {
                        id: playerCol
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
                        spacing: 8

                        Row {
                            spacing: 6

                            Text {
                                text: "\u266B"
                                color: Theme.accent
                                font.pixelSize: 10
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Сейчас играет"
                                color: Theme.fgMuted
                                font.pixelSize: 9
                                font.family: Theme.font
                                font.letterSpacing: 1.2
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Item {
                            width: parent.width
                            height: 52

                            Rectangle {
                                id: coverArt
                                width: 52; height: 52; radius: 8
                                color: Theme.bgAlt
                                visible: !trackArt.visible

                                Text { anchors.centerIn: parent; text: "\u266B"; color: Theme.fgMuted; font.pixelSize: 22 }
                            }

                            Rectangle {
                                width: 52; height: 52; radius: 8
                                color: "transparent"
                                visible: trackArt.visible
                                border.color: Qt.rgba(1,1,1,0.08)
                                border.width: 1

                                Image {
                                    id: trackArt
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop
                                    source: player ? player.trackArtUrl || "" : ""
                                    sourceSize { width: 104; height: 104 }
                                    visible: player && status === Image.Ready
                                    layer.enabled: true
                                    layer.effect: MultiEffect { maskEnabled: true; maskThresholdMin: 0.5 }
                                }
                            }

                            Column {
                                anchors { left: coverArt.right; leftMargin: 10; right: controlsRow.left; rightMargin: 8; verticalCenter: parent.verticalCenter }

                                Text {
                                    width: parent.width
                                    text: player ? player.trackTitle || "Не играет" : "Не играет"
                                    color: player ? Theme.fg : Theme.fgMuted
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    font.family: Theme.font
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    text: player ? player.trackArtist || "" : "Запустите музыкальный плеер"
                                    color: player ? Theme.fgDim : Theme.fgMuted
                                    font.pixelSize: 10
                                    font.family: Theme.font
                                    elide: Text.ElideRight
                                }
                            }

                            Row {
                                id: controlsRow
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                spacing: 2
                                visible: player != null

                                Item {
                                    width: 34; height: 34
                                    Rectangle {
                                        anchors.fill: parent; radius: 8
                                        color: prevMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }
                                    Text { anchors.centerIn: parent; text: "\u23EE"; color: player && player.canGoPrevious ? Theme.fg : Theme.fgMuted; font.pixelSize: 13 }
                                    MouseArea { id: prevMa; anchors.fill: parent; hoverEnabled: true; enabled: player && player.canGoPrevious; cursorShape: Qt.PointingHandCursor; onClicked: if (player) player.previous() }
                                }

                                Item {
                                    width: 34; height: 34
                                    Rectangle {
                                        anchors.fill: parent; radius: 8
                                        color: playMa.containsMouse ? Theme.accentDim : "transparent"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }
                                    Text { anchors.centerIn: parent; text: player && player.isPlaying ? "\u23F8" : "\u25B6"; color: player && (player.canPlay || player.canPause) ? Theme.fg : Theme.fgMuted; font.pixelSize: 13 }
                                    MouseArea { id: playMa; anchors.fill: parent; hoverEnabled: true; enabled: player && (player.canPlay || player.canPause); cursorShape: Qt.PointingHandCursor; onClicked: if (player) player.togglePlaying() }
                                }

                                Item {
                                    width: 34; height: 34
                                    Rectangle {
                                        anchors.fill: parent; radius: 8
                                        color: nextMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }
                                    Text { anchors.centerIn: parent; text: "\u23ED"; color: player && player.canGoNext ? Theme.fg : Theme.fgMuted; font.pixelSize: 13 }
                                    MouseArea { id: nextMa; anchors.fill: parent; hoverEnabled: true; enabled: player && player.canGoNext; cursorShape: Qt.PointingHandCursor; onClicked: if (player) player.next() }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 78
                    radius: Theme.radiusLg
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Row {
                        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom; leftMargin: 16; rightMargin: 16 }
                        spacing: 14

                        Item {
                            width: 60
                            height: parent.height

                            Text {
                                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 14 }
                                text: Qt.formatDateTime(clock.date, "HH")
                                color: Theme.fg
                                font.pixelSize: 30
                                font.weight: Font.Light
                                font.letterSpacing: 3
                            }

                            Text {
                                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 48 }
                                text: Qt.formatDateTime(clock.date, "mm")
                                color: Theme.accent
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                font.letterSpacing: 4
                            }
                        }

                        Rectangle {
                            width: 1; height: 40
                            color: Theme.borderDim
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: Qt.formatDateTime(clock.date, "dddd")
                                color: Theme.fgDim
                                font.pixelSize: 11
                                font.family: Theme.font
                                font.letterSpacing: 1
                                font.weight: Font.Medium
                            }

                            Text {
                                text: Qt.formatDateTime(clock.date, "d MMMM yyyy")
                                color: Theme.fgMuted
                                font.pixelSize: 10
                                font.family: Theme.font
                                font.letterSpacing: 0.5
                            }
                        }

                        SystemClock { id: clock; precision: SystemClock.Minutes }
                    }
                }
            }

            Column {
                id: rightCol
                width: 100
                spacing: 6
                anchors.top: parent.top

                Rectangle {
                    width: parent.width
                    height: 290
                    radius: Theme.radiusLg
                    color: Theme.bgCard
                    border.color: Theme.borderDim
                    border.width: 1

                    Column {
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 6 }
                        spacing: 4

                        Repeater {
                            model: [
                                { icon: "\u2630", label: "Wi-Fi", toggle: "wifi" },
                                { icon: "\u2615", label: "Caffeine", toggle: "caffeine" },
                                { icon: "\u2600", label: "Ночь", toggle: "nightlight" },
                                { icon: "\uD83D\uDD15", label: "DND", toggle: "dnd" },
                                { icon: "\u26A1", label: "Режим", toggle: "perf" }
                            ]

                            delegate: Item {
                                required property var modelData
                                width: parent.width
                                height: 48

                                readonly property bool active: {
                                    switch (modelData.toggle) {
                                    case "wifi": return rootItem.wifiOn
                                    case "caffeine": return rootItem.caffeineOn
                                    case "nightlight": return rootItem.nightLightOn
                                    case "dnd": return rootItem.dndOn
                                    case "perf": return rootItem.perfMode === "performance"
                                    default: return false
                                    }
                                }

                                readonly property string displayIcon: {
                                    switch (modelData.toggle) {
                                    case "nightlight": return rootItem.nightLightOn ? "\uD83C\uDF19" : "\u2600"
                                    case "perf": return rootItem.perfMode === "performance" ? "\u26A1" : rootItem.perfMode === "power-saver" ? "\uD83D\uDC0C" : "\u2B50"
                                    default: return modelData.icon
                                    }
                                }

                                readonly property string displayLabel: {
                                    switch (modelData.toggle) {
                                    case "perf":
                                        if (rootItem.perfMode === "performance") return "Турбо"
                                        else if (rootItem.perfMode === "power-saver") return "Эконом"
                                        else return "Баланс"
                                    case "nightlight": return rootItem.nightLightOn ? "Ночь" : "День"
                                    default: return modelData.label
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    color: active ? Theme.accent : "transparent"

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 10
                                        color: Qt.rgba(1,1,1,0.04)
                                        visible: !active && !ma.containsMouse
                                    }

                                    border.color: active ? "transparent" : ma.containsMouse ? Qt.rgba(1,1,1,0.15) : Theme.borderDim
                                    border.width: 1

                                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                                    layer.enabled: active
                                    layer.effect: MultiEffect {
                                        shadowEnabled: true
                                        shadowColor: Theme.accentGlow
                                        shadowBlur: 0.4
                                        shadowOpacity: 0.5
                                    }

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 1

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: displayIcon
                                            color: active ? "#fff" : Theme.fg
                                            font.pixelSize: 18
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: displayLabel
                                            color: active ? Qt.rgba(1,1,1,0.85) : Theme.fgMuted
                                            font.pixelSize: 8
                                            font.family: Theme.font
                                            font.letterSpacing: 0.5
                                        }
                                    }
                                }

                                MouseArea {
                                    id: ma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: rootItem.handleToggle(modelData.toggle)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IdleInhibitor {
        id: inhibitor
        enabled: caffeineOn
    }

    Binding {
        target: inhibitor
        property: "window"
        value: rootItem.window
        when: rootItem.window != null
    }

    Process {
        id: actionProc
        property var onDone: null
        running: false
        stdout: StdioCollector { waitForEnd: true }
        onExited: {
            if (onDone) { onDone(); onDone = null }
        }
    }

    function runAction(cmd, cb) {
        actionProc.command = ["bash", "-c", cmd]
        actionProc.onDone = cb || null
        actionProc.running = true
    }

    function handleToggle(type) {
        switch (type) {
        case "wifi":
            runAction(wifiOn ? "nmcli radio wifi off" : "nmcli radio wifi on", function() {
                wifiProc.running = true
            })
            break
        case "caffeine":
            caffeineOn = !caffeineOn
            break
        case "nightlight":
            nightLightOn = !nightLightOn
            runAction(nightLightOn ? "hyprctl dispatch exec wlsunset -t 3500" : "pkill wlsunset")
            break
        case "dnd":
            runAction("makoctl mode -t dnd", function() {
                dndProc.running = true
            })
            break
        case "perf":
            var next = perfMode === "power-saver" ? "balanced"
                     : perfMode === "balanced" ? "performance" : "power-saver"
            runAction("powerprofilesctl set " + next, function() {
                perfProc.running = true
            })
            break
        }
    }
}
