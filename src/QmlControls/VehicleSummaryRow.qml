import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools   1.0
Row {
    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    property string labelText:  "Label"
    property string valueText:  "value"
    property color  labelcolor: qgcPal.buttonHighlight
    width: parent.width

    QGCLabel {
        id:     label
        text:   labelText
        color:  labelcolor
    //    font.pointSize:     ScreenTools.defaultFontPixelHeight
        font.family:        ScreenTools.demiboldFontFamily
        font.bold:      true
    }
    QGCLabel {
        width:  parent.width - label.contentWidth
        text:   valueText
        horizontalAlignment: Text.AlignRight;
    //    font.pointSize:     ScreenTools.defaultFontPixelHeight
        font.family:        ScreenTools.demiboldFontFamily
        font.bold:      true
    }
}
