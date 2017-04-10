import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools   1.0
RowLayout {
    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    property string labelText: "Label"
    property string valueText: "value"
    property color  labelcolor: qgcPal.buttonHighlight
    width: parent.width

    QGCLabel {
        id:     label
        text:   labelText
        color:  labelcolor
        font.family:        ScreenTools.demiboldFontFamily
        font.bold:      true
    }
    QGCLabel {
        text:                   valueText
        elide:                  Text.ElideRight
        horizontalAlignment:    Text.AlignRight
        font.family:        ScreenTools.demiboldFontFamily
        font.bold:      true
    }
}
