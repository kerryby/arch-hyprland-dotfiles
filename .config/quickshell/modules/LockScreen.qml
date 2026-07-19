import Quickshell
import QtQuick
import QtQuick.Effects
import ".."
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland._IdleNotify
import QtQml

PanelWindow {
    id: lockScreen
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true
    visible: false
    color: "transparent"

    property bool locked: false
    property string wallpaperPath: ""
    property bool hasWallpaper: false
    property string pendingPassword: ""

    property string currentLayout: "US"

    Rectangle {
        id: content
        anchors.fill: parent
        color: "transparent"
        clip: true

        Rectangle {
            id: slideContainer
            width: parent.width
            height: parent.height

            Rectangle {
                anchors.fill: parent
                color: "#0a0a0f"

                Image {
                    anchors.fill: parent
                    source: hasWallpaper ? "file://" + wallpaperPath : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: hasWallpaper
                    smooth: true
                    mipmap: true
                }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.55)
                }

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.6) }
                        GradientStop { position: 0.5; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.8) }
                    }
                }
            }

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            Item {
                id: contentReveal
                anchors.fill: parent
                opacity: 0

                Rectangle {
                    id: lockPanel
                    anchors.centerIn: parent
                    width: 720
                    height: 420
                    radius: 20
                    color: Qt.rgba(0, 0, 0, 0.55)
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1

                    Column {
                        anchors { fill: parent; margins: 48 }
                        spacing: 20

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDateTime(clock.date, "HH:mm")
                            color: "#fff"
                            font.pixelSize: 96
                            font.weight: Font.Light
                            font.letterSpacing: 6
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
                            color: Qt.rgba(1, 1, 1, 0.5)
                            font.pixelSize: 16
                            font.family: Theme.font
                            font.letterSpacing: 2
                        }

                        Item { height: 1; width: 1 }

                        Text {
                            id: msgText
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: 14
                            font.family: Theme.font
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 12

                            Rectangle {
                                width: 360; height: 52; radius: 10
                                color: Qt.rgba(1, 1, 1, 0.08)
                                border.color: pwInput.activeFocus ? Theme.accent : Qt.rgba(1, 1, 1, 0.12)
                                border.width: 1

                                TextInput {
                                    id: pwInput
                                    anchors { left: parent.left; leftMargin: 18; right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                                    color: "#fff"
                                    font.pixelSize: 16
                                    font.family: Theme.font
                                    echoMode: TextInput.Password
                                    focus: lockScreen.locked
                                    onTextChanged: autoSubmitTimer.restart()
                                    onAccepted: tryUnlock()
                                    Keys.onEscapePressed: {
                                        if (pam.active) pam.abort()
                                    }
                                }
                            }

                            Rectangle {
                                width: 52; height: 52; radius: 10
                                color: Qt.rgba(1, 1, 1, 0.06)
                                visible: true

                                Text {
                                    anchors.centerIn: parent
                                    text: currentLayout
                                    color: Qt.rgba(1, 1, 1, 0.7)
                                    font.pixelSize: 13
                                    font.family: Theme.font
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }
        }
    }

    function lock() {
        locked = true
        pwInput.forceActiveFocus()
        pwInput.text = ""
        msgText.text = ""
        pendingPassword = ""
        pam.user = "kerry"
        if (!pam.active) pam.start()
        visible = true
        slideContainer.y = -height
        animTimer.start()
    }

    Timer {
        id: animTimer
        interval: 16
        onTriggered: {
            slideOut.stop()
            slideContainer.y = -height
            slideIn.start()
        }
    }

    function unlock() {
        locked = false
        slideIn.stop()
        contentRevealAnim.stop()
        contentReveal.opacity = 0
        lockPanel.scale = 0.92
        slideOut.start()
    }

    SequentialAnimation {
        id: slideIn
        NumberAnimation {
            target: slideContainer; property: "y"
            from: -slideContainer.height; to: 0
            duration: 300; easing.type: Easing.OutCubic
        }
        onFinished: contentRevealAnim.start()
    }

    ParallelAnimation {
        id: contentRevealAnim
        NumberAnimation { target: contentReveal; property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
        NumberAnimation { target: lockPanel; property: "scale"; from: 0.92; to: 1; duration: 300; easing.type: Easing.OutBack }
    }

    SequentialAnimation {
        id: slideOut
        NumberAnimation {
            target: slideContainer; property: "y"
            from: 0; to: -slideContainer.height
            duration: 300; easing.type: Easing.InCubic
        }
        PropertyAction { target: lockScreen; property: "visible"; value: false }
    }

    IdleMonitor {
        id: idleMon
        enabled: true
        timeout: 300000
        respectInhibitors: true
        onIsIdleChanged: {
            if (isIdle && !lockScreen.locked) {
                lockScreen.lock()
            }
        }
    }

    Process {
        id: wallProc
        command: ["bash", "-c", "ls /home/kerry/Pictures/wallpapers/*.{jpg,png,jpeg} 2>/dev/null | shuf -n1"]
        stdout: StdioCollector { id: wallStdout }
        onExited: {
            var v = wallStdout.text.trim()
            if (v.length > 0) {
                wallpaperPath = v
                hasWallpaper = true
            }
        }
        running: true
    }

    PamContext {
        id: pam
        config: "login"
        onCompleted: function(result) {
            if (result === PamResult.Success) {
                msgText.text = ""
                unlock()
            } else {
                msgText.text = "\u041D\u0435\u0432\u0435\u0440\u043D\u044B\u0439 \u043F\u0430\u0440\u043E\u043B\u044C"
                msgText.color = Theme.red
                pwInput.text = ""
                pwInput.forceActiveFocus()
            }
        }
        onPamMessage: function(msg, isError, respReq, respVis) {
            if (respReq) {
                pwInput.echoMode = respVis ? TextInput.Normal : TextInput.Password
                if (pendingPassword.length > 0) {
                    pam.respond(pendingPassword)
                    pendingPassword = ""
                }
            }
        }
    }

    Timer {
        id: autoSubmitTimer
        interval: 350
        onTriggered: {
            if (pwInput.text.length > 0) tryUnlock()
        }
    }

    Process {
        id: layoutProc
        command: ["bash", "-c", "hyprctl devices 2>/dev/null | grep -B10 'main: yes' | grep -i 'active keymap' | awk -F': ' '{print $2}'"]
        stdout: StdioCollector { id: layoutOut }
        running: true
        onExited: {
            var v = layoutOut.text.trim()
            if (v.length > 0) {
                var code = v
                if (code.indexOf("(") >= 0) {
                    code = code.split("(")[1].replace(")", "").trim()
                }
                currentLayout = code.substring(0, 2).toUpperCase()
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            layoutProc.running = true
        }
    }

    function tryUnlock() {
        if (pwInput.text.length === 0) return
        if (pam.active) {
            pam.respond(pwInput.text)
        } else {
            pendingPassword = pwInput.text
        }
    }

    onVisibleChanged: {
        if (visible) {
            pwInput.forceActiveFocus()
            layoutProc.running = true
        }
    }
}
