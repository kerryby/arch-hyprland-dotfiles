pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property color bg: "#101012"
    property color bgAlt: "#1a1a1e"
    property color bgCard: "#141418"
    property color fg: "#ffffff"
    property color fgDim: Qt.rgba(1, 1, 1, 0.45)
    property color fgMuted: Qt.rgba(1, 1, 1, 0.25)
    property color accent: "#7c3aed"
    property color accentGlow: Qt.rgba(0.49, 0.23, 0.93, 0.4)
    property color accentDim: Qt.rgba(0.49, 0.23, 0.93, 0.2)
    property color red: "#ef4444"
    property color green: "#22c55e"
    property color blue: "#3b82f6"
    property color yellow: "#eab308"
    property color surface: Qt.rgba(1, 1, 1, 0.04)
    property color borderDim: Qt.rgba(1, 1, 1, 0.06)
    property int radius: 10
    property int radiusSm: 8
    property int radiusLg: 14
    property int barH: 28
    property string font: "BigBlueTermPlus Nerd Font"
    property int fontSize: 11
    property int popupW: 200
    property int subW: 450

    function hex2rgb(hex) {
        if (!hex || hex.length < 6) return Qt.rgba(0, 0, 0, 1)
        return Qt.rgba(
            parseInt(hex.substring(1, 3), 16) / 255,
            parseInt(hex.substring(3, 5), 16) / 255,
            parseInt(hex.substring(5, 7), 16) / 255,
            1
        )
    }

    function lerp(a, b, t) { return a + (b - a) * t }

    function applyColors(text) {
        if (!text) return
        try {
            var wal = JSON.parse(text)
            if (!wal || !wal.special || !wal.colors) return

            var b = hex2rgb(wal.special.background)
            var f = hex2rgb(wal.special.foreground)
            var c = []
            for (var i = 0; i < 16; i++) {
                var key = "color" + i
                if (wal.colors[key]) c.push(hex2rgb(wal.colors[key]))
            }
            if (c.length < 8) return

            bg = Qt.rgba(b.r, b.g, b.b, 0.88)
            bgAlt = Qt.rgba(lerp(b.r, f.r, 0.06), lerp(b.g, f.g, 0.06), lerp(b.b, f.b, 0.06), 0.93)
            bgCard = Qt.rgba(lerp(b.r, f.r, 0.12), lerp(b.g, f.g, 0.12), lerp(b.b, f.b, 0.12), 0.6)

            fg = Qt.rgba(f.r, f.g, f.b, 0.92)
            fgDim = Qt.rgba(f.r, f.g, f.b, 0.45)
            fgMuted = Qt.rgba(f.r, f.g, f.b, 0.25)

            accent = c[4]
            var aR = c[4].r, aG = c[4].g, aB = c[4].b
            accentGlow = Qt.rgba(aR, aG, aB, 0.4)
            accentDim = Qt.rgba(aR, aG, aB, 0.2)

            red = c[1]
            green = c[2]
            yellow = c[3]
            blue = c[4]

            surface = Qt.rgba(f.r, f.g, f.b, 0.04)
            borderDim = Qt.rgba(f.r, f.g, f.b, 0.06)
        } catch(e) {}
    }
}