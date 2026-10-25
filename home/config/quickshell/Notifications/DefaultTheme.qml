import QtQuick
import qs

QtObject {
    readonly property color bgBase: Theme.bgBase
    readonly property color bgSurface: Theme.bgSurface
    readonly property color bgOverlay: Theme.bgOverlay
    readonly property color bgHover: Theme.bgHover
    readonly property color bgSelected: Theme.bgSelected
    // readonly property color bgBorder: Theme.bgBorder
    readonly property color bgBorder: Theme.accentPrimary

    readonly property color textPrimary: Theme.textPrimary
    readonly property color textSecondary: Theme.textSecondary
    readonly property color textMuted: Theme.textMuted

    readonly property color accentPrimary: Theme.accentPrimary
    readonly property color accentCyan: Theme.accentCyan
    readonly property color accentGreen: Theme.accentGreen
    readonly property color accentOrange: Theme.accentOrange
    readonly property color accentRed: Theme.accentRed

    readonly property color urgencyLow: textMuted
    readonly property color urgencyNormal: accentPrimary
    readonly property color urgencyCritical: accentRed
    readonly property color batteryGood: accentGreen
    readonly property color batteryWarning: accentOrange
    readonly property color batteryCritical: accentRed
}
