pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Точный акцентный цвет из пикселей текущих обоев (ImageMagick histogram).
// Используется рамкой экрана и обводками острова/панелей/лаунчера.
Singleton {
    id: root

    property color line: Theme.accent2
    property string wallPath: ""

    onLineChanged: root.updated()

    signal updated()

    FileView {
        id: lastWall

        path: Quickshell.env("HOME") + "/.cache/hypr-theme-last"
        watchChanges: true

        onLoaded: {
            const p = text().trim()
            if (p !== "" && p !== root.wallPath) {
                root.wallPath = p
                root.extract(p)
            }
        }
        onFileChanged: reload()
    }

    Process {
        id: extractor

        stdout: StdioCollector {
            onStreamFinished: root.applyHistogram(text)
        }
    }

    function extract(path) {
        extractor.command = ["bash", "-c", "magick \"$1\" -resize 256x256^ -gravity center -extent 256x256 -colors 6 -depth 8 -format %c histogram:info:", "bash", path]
        extractor.running = true
    }

    function applyHistogram(out) {
        const re = /(\d+)\s*:\s*\((\d+),\s*(\d+),\s*(\d+)\)/g
        let m
        let bestScore = -1
        let bestRgb = null
        while ((m = re.exec(out)) !== null) {
            const cnt = parseInt(m[1])
            const r = parseInt(m[2]) / 255
            const g = parseInt(m[3]) / 255
            const b = parseInt(m[4]) / 255
            const mx = Math.max(r, g, b)
            const mn = Math.min(r, g, b)
            const satv = mx === 0 ? 0 : (mx - mn) / mx
            const lumv = (mx + mn) / 2
            const sc = Math.sqrt(cnt) * Math.pow(satv, 1.4) * (1 - Math.abs(lumv - 0.55) * 1.2)
            if (sc > bestScore) {
                bestScore = sc
                bestRgb = [r, g, b]
            }
        }
        if (bestRgb !== null)
            line = Qt.rgba(bestRgb[0], bestRgb[1], bestRgb[2], 1)
    }
}
