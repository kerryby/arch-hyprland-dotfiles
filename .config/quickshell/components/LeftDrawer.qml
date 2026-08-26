import Quickshell.Services.Mpris
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import "../styles" as Styles

// Выдвижная панель слева: вкладки «Музыка» и «Дата».
Item {
    id: root

    property bool open: false
    property bool shown: false
    property int tabIndex: 0

    // --- media ---
    readonly property var players: {
        const m = Mpris.players
        return m.values !== undefined ? m.values : m
    }
    property int playerIndex: 0
    readonly property var player: players.length === 0
        ? null
        : players[Math.min(playerIndex, players.length - 1)]
    readonly property bool isPlaying: player?.isPlaying ?? false

    readonly property bool pointerInside: bodyTrack.hovered

    // --- календарь ---
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()

    function openUp() {
        shown = true
        open = true
    }

    function closeDown() {
        open = false
    }

    function fmtTime(sec) {
        const s = Math.max(0, Math.floor(sec))
        const h = Math.floor(s / 3600)
        const m = Math.floor((s % 3600) / 60)
        const r = s % 60
        return (h > 0 ? h + ":" : "") + (h > 0 && m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
    }

    // ================= МУЗЫКА: визуализатор =================
    property real vizT: 0
    property var vizLevels: {
        const arr = []
        for (let i = 0; i < 52; i++)
            arr.push(0.05)
        return arr
    }

    Timer {
        interval: 36
        repeat: true
        running: root.open && root.visible
        onTriggered: {
            const n = root.vizLevels.length
            root.vizT += 0.085
            for (let i = 0; i < n; i++) {
                let target
                if (root.isPlaying) {
                    const beat = Math.pow(Math.abs(Math.sin(root.vizT * 1.35 + i * 0.31)), 2)
                    const wave = Math.abs(Math.sin(root.vizT * 0.6 + i * 0.11))
                    target = 0.12 + 0.88 * beat * (0.45 + 0.55 * wave)
                } else {
                    target = 0.05
                }
                root.vizLevels[i] += (target - root.vizLevels[i]) * 0.32
            }
            vizCanvas.requestPaint()
        }
    }

    // ================= КОНТЕНТ =================
    Item {
        id: body

        width: 340
        height: parent.height
        x: root.open ? 0 : -(width + 40)

        Behavior on x {
            NumberAnimation {
                duration: 620
                easing.type: Easing.OutElastic
                easing.period: 0.48
                easing.amplitude: 0.85
            }
        }

        // пассивный трекер курсора: держит панель открытой,
        // не конфликтует с MouseArea кнопок и не перехватывает клики
        HoverHandler {
            id: bodyTrack
        }

        // фон со скруглением справа
        Shape {
            id: drawerShape

            anchors.fill: parent
            antialiasing: true
            asynchronous: false
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#000000"
                shadowBlur: 0.65
                shadowOpacity: 0.55
                shadowHorizontalOffset: 6
            }

            ShapePath {
                strokeWidth: 1.6
                strokeColor: Styles.WallColor.line
                fillGradient: LinearGradient {
                    x1: 0
                    y1: 0
                    x2: 0
                    y2: drawerShape.height

                    GradientStop {
                        position: 0
                        color: Styles.Theme.bgTop
                    }
                    GradientStop {
                        position: 1
                        color: Styles.Theme.bgBottom
                    }
                }

                startX: 0
                startY: 0
                PathLine {
                    x: drawerShape.width - 24
                    y: 0
                }
                PathArc {
                    x: drawerShape.width
                    y: 24
                    radiusX: 24
                    radiusY: 24
                }
                PathLine {
                    x: drawerShape.width
                    y: drawerShape.height - 24
                }
                PathArc {
                    x: drawerShape.width - 24
                    y: drawerShape.height
                    radiusX: 24
                    radiusY: 24
                }
                PathLine {
                    x: 0
                    y: drawerShape.height
                }
                PathLine {
                    x: 0
                    y: 0
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // ---------- переключатель вкладок ----------
            Rectangle {
                Layout.fillWidth: true
                height: 42
                radius: 14
                color: Styles.Theme.surface

                Rectangle {
                    id: tabIndicator

                    x: root.tabIndex === 0 ? 3 : parent.width / 2
                    width: parent.width / 2 - 3
                    anchors.margins: 3
                    y: 3
                    height: parent.height - 6
                    radius: 11
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
                    opacity: 0.9

                    Behavior on x {
                        NumberAnimation {
                            duration: 420
                            easing.type: Easing.OutElastic
                            easing.period: 0.45
                            easing.amplitude: 0.8
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            IconImage {
                                source: Styles.Theme.icHeadphones
                                width: 15
                                height: 15
                                opacity: 0.95
                            }

                            Text {
                                text: "Музыка"
                                color: root.tabIndex === 0 ? Styles.Theme.bgBottom : Styles.Theme.textDim
                                font.family: Styles.Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: root.tabIndex === 0
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.tabIndex = 0
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            IconImage {
                                source: Styles.Theme.icCalendar
                                width: 15
                                height: 15
                            }

                            Text {
                                text: "Дата"
                                color: root.tabIndex === 1 ? Styles.Theme.bgBottom : Styles.Theme.textDim
                                font.family: Styles.Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: root.tabIndex === 1
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.tabIndex = 1
                        }
                    }
                }
            }

            // ================= МУЗЫКА =================
            ColumnLayout {
                id: musicView

                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                visible: root.tabIndex === 0
                opacity: root.tabIndex === 0 ? 1 : 0
                scale: root.tabIndex === 0 ? 1 : 0.96

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 320
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }
                }

                Item {
                    id: avatarWrap

                    width: 178
                    height: 178
                    Layout.alignment: Qt.AlignHCenter

                    Canvas {
                        id: vizCanvas

                        readonly property color c1: Styles.Theme.accent
                        readonly property color c2: Styles.Theme.accent2

                        anchors.centerIn: parent
                        width: 178
                        height: 178
                        antialiasing: true
                        visible: root.tabIndex === 0

                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()
                            ctx.lineWidth = 3
                            ctx.lineCap = "round"
                            const n = root.vizLevels.length
                            const cx = width / 2
                            const cy = height / 2
                            const inner = 74
                            for (let i = 0; i < n; i++) {
                                const a = i / n * Math.PI * 2 - Math.PI / 2
                                const len = 4 + root.vizLevels[i] * 24
                                const k = i / n
                                ctx.strokeStyle = Qt.rgba(c1.r + (c2.r - c1.r) * k, c1.g + (c2.g - c1.g) * k, c1.b + (c2.b - c1.b) * k, 0.85)
                                ctx.beginPath()
                                ctx.moveTo(cx + Math.cos(a) * inner, cy + Math.sin(a) * inner)
                                ctx.lineTo(cx + Math.cos(a) * (inner + len), cy + Math.sin(a) * (inner + len))
                                ctx.stroke()
                            }
                        }
                    }

                    Rectangle {
                        id: avatar

                        anchors.centerIn: parent
                        width: 132
                        height: 132
                        radius: 66
                        clip: true
                        color: Styles.Theme.surfaceHover
                        border.color: Qt.rgba(1, 1, 1, 0.1)
                        border.width: 1

                        Image {
                            id: artImg

                            anchors.fill: parent
                            source: root.player?.trackArtUrl ?? ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: status === Image.Ready
                        }

                        IconImage {
                            anchors.centerIn: parent
                            visible: artImg.status !== Image.Ready
                            source: Styles.Theme.icMusic
                            width: 44
                            height: 44
                            opacity: 0.65
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: root.player?.trackTitle || "Ничего не играет"
                        color: Styles.Theme.text
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 16
                        font.bold: true
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.player ? (root.player.trackArtist || "Неизвестный исполнитель") : ""
                        color: Styles.Theme.textDim
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.player !== null && (root.player?.trackAlbum ?? "") !== ""
                        text: root.player?.trackAlbum ?? ""
                        color: Styles.Theme.textDim
                        opacity: 0.7
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 10
                        font.italic: true
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // прогресс
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: root.fmtTime(root.player?.position ?? 0)
                        color: Styles.Theme.textDim
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 10
                    }

                    Item {
                        id: seekTrack

                        Layout.fillWidth: true
                        Layout.preferredHeight: 16

                        readonly property real ratio: root.player && root.player.length > 0 ? Math.min(1, (root.player?.position ?? 0) / root.player.length) : 0

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
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

                            Behavior on width {
                                NumberAnimation {
                                    duration: 90
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor

                            function seek(mouse) {
                                const p = root.player
                                if (!p || !p.canSeek || !p.positionSupported || p.length <= 0)
                                    return
                                p.position = Math.max(0, Math.min(1, mouse.x / seekTrack.width)) * p.length
                            }

                            onClicked: mouse => seek(mouse)
                            onPositionChanged: mouse => {
                                if (pressed)
                                    seek(mouse)
                            }
                        }
                    }

                    Text {
                        text: root.fmtTime(root.player?.length ?? 0)
                        color: Styles.Theme.textDim
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 10
                    }
                }

                // управление
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: shufMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                        scale: shufMa.pressed ? 0.86 : 1
                        visible: root.player?.shuffleSupported ?? false

                        IconImage {
                            anchors.centerIn: parent
                            source: Styles.Theme.icShuffle
                            width: 15
                            height: 15
                            opacity: root.player?.shuffle ? 1 : 0.45
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 6
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 4
                            height: 4
                            radius: 2
                            color: Styles.Theme.green
                            visible: root.player?.shuffle ?? false
                        }

                        MouseArea {
                            id: shufMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.player && root.player.shuffleSupported)
                                    root.player.shuffle = !root.player.shuffle
                            }
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: prevMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                        scale: prevMa.pressed ? 0.88 : prevMa.containsMouse ? 1.07 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Styles.Theme.popDur
                                easing.type: Easing.OutBack
                                easing.overshoot: Styles.Theme.popOvershoot
                            }
                        }

                        IconImage {
                            anchors.centerIn: parent
                            source: Styles.Theme.icPrev
                            width: 17
                            height: 17
                            opacity: root.player?.canGoPrevious === false ? 0.3 : 1
                        }

                        MouseArea {
                            id: prevMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (root.player?.canGoPrevious)
                                root.player.previous()
                        }
                    }

                    Rectangle {
                        width: 54
                        height: 54
                        radius: 27
                        scale: playMa.pressed ? 0.9 : playMa.containsMouse ? 1.06 : 1
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
                            shadowOpacity: root.isPlaying ? 0.8 : 0.15
                            shadowVerticalOffset: 0

                            Behavior on shadowOpacity {
                                NumberAnimation {
                                    duration: 260
                                }
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: Styles.Theme.popDur
                                easing.type: Easing.OutBack
                                easing.overshoot: Styles.Theme.popOvershoot
                            }
                        }

                        IconImage {
                            anchors.centerIn: parent
                            source: root.isPlaying ? Styles.Theme.icPause : Styles.Theme.icPlay
                            width: 22
                            height: 22
                        }

                        MouseArea {
                            id: playMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (root.player?.canTogglePlaying)
                                root.player.togglePlaying()
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: nextMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                        scale: nextMa.pressed ? 0.88 : nextMa.containsMouse ? 1.07 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Styles.Theme.popDur
                                easing.type: Easing.OutBack
                                easing.overshoot: Styles.Theme.popOvershoot
                            }
                        }

                        IconImage {
                            anchors.centerIn: parent
                            source: Styles.Theme.icNext
                            width: 17
                            height: 17
                            opacity: root.player?.canGoNext === false ? 0.3 : 1
                        }

                        MouseArea {
                            id: nextMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (root.player?.canGoNext)
                                root.player.next()
                        }
                    }

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: repMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                        scale: repMa.pressed ? 0.86 : 1
                        visible: root.player?.loopSupported ?? false

                        IconImage {
                            anchors.centerIn: parent
                            source: root.player?.loopState === 1 ? Styles.Theme.icRepeatOne : Styles.Theme.icRepeat
                            width: 15
                            height: 15
                            opacity: root.player?.loopState === 0 ? 0.45 : 1
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 6
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 4
                            height: 4
                            radius: 2
                            color: Styles.Theme.green
                            visible: root.player?.loopState !== 0
                        }

                        MouseArea {
                            id: repMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!root.player || !root.player.loopSupported)
                                    return
                                root.player.loopState = (root.player.loopState + 1) % 3
                            }
                        }
                    }
                }

                // выбор плеера
                RowLayout {
                    Layout.fillWidth: true
                    visible: root.players.length > 1
                    spacing: 6

                    Repeater {
                        model: root.players

                        Rectangle {
                            id: chip

                            required property var modelData
                            required property int index

                            readonly property bool active: index === root.playerIndex

                            Layout.fillWidth: true
                            Layout.preferredHeight: 26
                            radius: 13
                            color: active ? Styles.Theme.accent : chipMa.containsMouse ? Styles.Theme.outline : Styles.Theme.groove

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: chip.modelData?.identity || "Плеер"
                                color: chip.active ? Styles.Theme.bgBottom : Styles.Theme.textDim
                                font.family: Styles.Theme.fontFamily
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }

                            MouseArea {
                                id: chipMa

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.playerIndex = chip.index
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }

            // ================= ДАТА =================
            ColumnLayout {
                id: dateView

                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10
                visible: root.tabIndex === 1
                opacity: root.tabIndex === 1 ? 1 : 0
                scale: root.tabIndex === 1 ? 1 : 0.96

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 320
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }
                }

                // часы
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 0

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4

                        Text {
                            id: bigClock

                            text: Qt.formatDateTime(clockTimer.now, "HH:mm")
                            color: Styles.Theme.text
                            font.family: Styles.Theme.fontFamily
                            font.pixelSize: 46
                            font.bold: true
                        }

                        Text {
                            text: Qt.formatDateTime(clockTimer.now, "ss")
                            color: Styles.Theme.accent2
                            font.family: Styles.Theme.fontFamily
                            font.pixelSize: 18
                            font.bold: true

                            Layout.alignment: Qt.AlignBottom
                            Layout.bottomMargin: 9
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(clockTimer.now, Qt.locale("ru_RU"), "dddd, d MMMM yyyy")
                        color: Styles.Theme.textDim
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 12
                        font.capitalization: Font.Capitalize
                        font.letterSpacing: 0.4
                    }
                }

                Timer {
                    id: clockTimer

                    property date now: new Date()

                    interval: 1000
                    repeat: true
                    running: root.open && root.tabIndex === 1
                    triggeredOnStart: true
                    onTriggered: now = new Date()
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.07)
                }

                // навигация месяца
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 9
                        color: navPrevMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                        scale: navPrevMa.pressed ? 0.86 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Styles.Theme.popDur
                                easing.type: Easing.OutBack
                                easing.overshoot: Styles.Theme.popOvershoot
                            }
                        }

                        IconImage {
                            anchors.centerIn: parent
                            source: Styles.Theme.icChevronL
                            width: 13
                            height: 13
                        }

                        MouseArea {
                            id: navPrevMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.shiftMonth(-1)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), Qt.locale("ru_RU"), "MMMM yyyy")
                        color: Styles.Theme.text
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                        font.capitalization: Font.Capitalize
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 9
                        color: navNextMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                        scale: navNextMa.pressed ? 0.86 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Styles.Theme.popDur
                                easing.type: Easing.OutBack
                                easing.overshoot: Styles.Theme.popOvershoot
                            }
                        }

                        IconImage {
                            anchors.centerIn: parent
                            source: Styles.Theme.icChevron
                            width: 13
                            height: 13
                        }

                        MouseArea {
                            id: navNextMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.shiftMonth(1)
                        }
                    }
                }

                // дни недели
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: ["пн", "вт", "ср", "чт", "пт", "сб", "вс"]

                        Text {
                            required property string modelData
                            required property int index

                            text: modelData
                            color: index >= 5 ? Qt.alpha(Styles.Theme.red, 0.7) : Styles.Theme.textDim
                            font.family: Styles.Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                // сетка дней
                GridLayout {
                    id: dayGrid

                    columns: 7
                    columnSpacing: 0
                    rowSpacing: 3
                    Layout.fillWidth: true

                    Repeater {
                        model: root.dayCells

                        Item {
                            id: dayCell

                            required property var modelData
                            required property int index

                            readonly property bool today: modelData.day === clockTimer.now.getDate() && modelData.month === clockTimer.now.getMonth() && modelData.year === clockTimer.now.getFullYear()

                            Layout.preferredWidth: (dayGrid.width - 6 * dayGrid.columnSpacing) / 7
                            Layout.preferredHeight: 36
                            Layout.columnSpan: 1

                            Rectangle {
                                anchors.centerIn: parent
                                width: 30
                                height: 30
                                radius: 15
                                color: dayCell.today ? Styles.Theme.accent : dayCellMa.containsMouse ? Styles.Theme.surfaceHover : "transparent"

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 110
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: dayCell.modelData.day > 0 ? dayCell.modelData.day : ""
                                color: dayCell.today ? Styles.Theme.bgBottom : (dayCell.index % 7) >= 5 ? Qt.alpha(Styles.Theme.red, 0.8) : Styles.Theme.text
                                font.family: Styles.Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: dayCell.today
                            }

                            MouseArea {
                                id: dayCellMa

                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: dayCell.modelData.day > 0
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    function shiftMonth(delta) {
        let m = viewMonth + delta
        let y = viewYear
        if (m < 0) {
            m = 11
            y--
        } else if (m > 11) {
            m = 0
            y++
        }
        viewMonth = m
        viewYear = y
    }

    readonly property var dayCells: {
        const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate()
        const firstJsDay = new Date(viewYear, viewMonth, 1).getDay()
        const offset = (firstJsDay + 6) % 7
        const total = Math.ceil((offset + daysInMonth) / 7) * 7
        const cells = []
        for (let i = 0; i < total; i++) {
            const dnum = i - offset + 1
            cells.push({
                day: dnum >= 1 && dnum <= daysInMonth ? dnum : 0,
                month: viewMonth,
                year: viewYear
            })
        }
        return cells
    }
}
