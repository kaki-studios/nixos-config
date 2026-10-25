pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Single source of truth for every color and font in this shell.
// Values come from ~/.config/quickshell/theme.json, which home-manager
// generates from the stylix palette (see home/modules/theme.nix).
// Nothing here is hardcoded, so changing the stylix scheme re-themes the shell.
Singleton {
    id: root

    // ponytail: missing keys come back magenta — loud rather than invisible.
    function color(name) {
        const hex = root.palette[name];
        return hex ? "#" + hex : "#ff00ff";
    }

    property var palette: ({})

    property color bgBase: color("base00")
    property color bgSurface: color("base01")
    property color bgOverlay: color("base02")
    property color bgHover: color("base02")
    property color bgSelected: color("base02")
    property color bgBorder: color("base0D")

    property color textPrimary: color("base05")
    property color textSecondary: color("base04")
    property color textMuted: color("base03")

    property color accentPrimary: color("base0D")
    property color accentCyan: color("base0C")
    property color accentGreen: color("base0B")
    property color accentOrange: color("base09")
    property color accentRed: color("base08")
    property color accentYellow: color("base0A")
    property color accentMagenta: color("base0E")

    property color urgencyLow: textMuted
    property color urgencyNormal: accentPrimary
    property color urgencyCritical: accentRed
    property color batteryGood: accentGreen
    property color batteryWarning: accentOrange
    property color batteryCritical: accentRed

    property string fontFamily: palette.monospace || "monospace"
    property int fontSize: palette.fontSize || 10

    FileView {
        id: paletteFile
        path: Quickshell.env("HOME") + "/.config/quickshell/theme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.palette = JSON.parse(text())
        onLoadFailed: error => console.warn("quickshell theme: cannot load theme.json:", error)
    }
}
