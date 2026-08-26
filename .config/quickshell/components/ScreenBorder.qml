import QtQuick
import "../styles" as Styles

// Рамка по периметру экрана: линия + затемнённая подложка за ней.
// Цвет — точный акцент текущих обоев (Styles.WallColor).
Item {
    id: root

    property bool started: false
    readonly property color lc: Styles.WallColor.line

    // вырез в рамке: зона пилюли в экранных координатах (-1 = без выреза)
    property real notchLeft: -1
    property real notchRight: -1

    opacity: started ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 900
            easing.type: Easing.OutCubic
        }
    }

    onLcChanged: cv.requestPaint()
    onNotchLeftChanged: cv.requestPaint()
    onNotchRightChanged: cv.requestPaint()

    Component.onCompleted: {
        Qt.callLater(() => root.started = true)
        cv.requestPaint()
    }

    function _css(c, a) {
        return "rgba(" + Math.round(c.r * 255) + "," + Math.round(c.g * 255) + "," + Math.round(c.b * 255) + "," + a + ")"
    }

    Canvas {
        id: cv

        anchors.fill: parent
        antialiasing: true

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            const m = 7
            const r = 24
            const x = m, y = m
            const w = width - m * 2
            const h = height - m * 2

            // добавляет путь скруглённого прямоугольника (без beginPath)
            function addRr(px, py, pw, ph, pr) {
                ctx.moveTo(px + pr, py)
                ctx.lineTo(px + pw - pr, py)
                ctx.arcTo(px + pw, py, px + pw, py + pr, pr)
                ctx.lineTo(px + pw, py + ph - pr)
                ctx.arcTo(px + pw, py + ph, px + pw - pr, py + ph, pr)
                ctx.lineTo(px + pr, py + ph)
                ctx.arcTo(px, py + ph, px, py + ph - pr, pr)
                ctx.lineTo(px, py + pr)
                ctx.arcTo(px, py, px + pr, py, pr)
                ctx.closePath()
            }

            // цвет линии — точный цвет из обоев; подложка — он же, но темнее
            const lc = root.lc
            const dark = Qt.rgba(lc.r * 0.42, lc.g * 0.42, lc.b * 0.42, 1)

            // ---------- подложка ----------
            ctx.globalAlpha = 0.92
            ctx.fillStyle = root._css(dark, 1)
            ctx.fillRect(0, 0, width, height)

            ctx.globalCompositeOperation = "destination-out"
            ctx.beginPath()
            addRr(x, y, w, h, r)
            ctx.fillStyle = "#ffffff"
            ctx.fill()
            ctx.globalCompositeOperation = "source-over"

            // ---------- линия ----------
            ctx.beginPath()
            addRr(x, y, w, h, r)

            // мягкое свечение
            ctx.lineWidth = 6
            ctx.strokeStyle = root._css(lc, 0.22)
            ctx.stroke()

            // яркая сердцевина
            ctx.lineWidth = 1.8
            ctx.globalAlpha = 0.95
            ctx.strokeStyle = root._css(lc, 1)
            ctx.stroke()

            ctx.globalAlpha = 1

            // ---------- вырез под пилюлю: обводка и подложка не доходят до неё ----------
            if (root.notchLeft >= 0 && root.notchRight > root.notchLeft) {
                ctx.globalCompositeOperation = "destination-out"
                ctx.fillStyle = "#ffffff"
                ctx.fillRect(Math.round(root.notchLeft), 0, Math.round(root.notchRight - root.notchLeft), height)
                ctx.globalCompositeOperation = "source-over"
            }
        }
    }
}
