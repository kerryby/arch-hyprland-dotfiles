import QtQml
import Quickshell
import Quickshell.Io

pragma Singleton

QtObject {
  id: theme

  property string primaryColor: "#eebe8a"
  property string secondaryColor: "#dcc2a9"
  property string surfaceColor: "#16130f"
  property string surfaceVariant: "#231f1b"
  property string surfaceContainer: "#2e2925"
  property string errorColor: "#ffb4ab"
  property string onSurface: "#eae1db"
  property string onSurfaceDim: "#9c8e82"
  property string outline: "#9c8e82"
  property string accent: "#eebe8a"
  property string textColor: "#eae1db"
  property string textDim: "#918f9a"
  property string backgroundColor: "#131317"
  property string successColor: "#44def5"

  property string fontFamily: "JetBrainsMono Nerd Font"
  property bool darkMode: true

  function generateFromImage(imagePath) {
    var proc = Process.createObject(theme, {
      command: ["noctalia", "theme", imagePath, "--scheme", "m3-tonal-spot"],
      running: true,
      stdout: StdioCollector {
        onStreamFinished: function(data) {
          try {
            var colors = JSON.parse(data)
            if (colors.dark) {
              applyPalette(colors.dark)
            }
          } catch (e) {
            print("Failed to parse theme JSON:", e)
          }
        }
      }
    })
  }

  function applyPalette(palette) {
    if (!palette) return
    if (palette.primary) primaryColor = palette.primary
    if (palette.secondary) secondaryColor = palette.secondary
    if (palette.surface) surfaceColor = palette.surface
    if (palette.surfaceVariant) surfaceVariant = palette.surfaceVariant
    if (palette.error) errorColor = palette.error
    if (palette.onSurface) onSurface = palette.onSurface
    if (palette.outline) outline = palette.outline
    accent = primaryColor
    textColor = onSurface
    print("Theme applied:", primaryColor, secondaryColor)
  }

  function reload() {
    var proc = Process.createObject(theme, {
      command: ["noctalia", "msg", "color-scheme-get"],
      running: true,
      stdout: StdioCollector {
        onStreamFinished: function(data) {
          print("Current scheme:", data.trim())
        }
      }
    })
  }
}