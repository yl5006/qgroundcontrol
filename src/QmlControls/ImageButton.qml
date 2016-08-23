import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Button {
    property string imageResource:  "/qmlimages/subMenuButtonImage.png"     ///< Button image

    checkable:      true
    implicitHeight: ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3.5 : ScreenTools.defaultFontPixelHeight * 2.5

    style: ButtonStyle {
        id: buttonStyle

        QGCPalette {
            id:                 qgcPal
        }

        property bool showHighlight: control.pressed

        background: Rectangle {
            id:     innerRect
    //        color:  showHighlight ? qgcPal.buttonHighlight : qgcPal.windowShade
            color:  "transparent"
    //        implicitWidth: titleBar.x + titleBar.contentWidth + ScreenTools.defaultFontPixelWidth

            QGCColoredImage {
                id:                     image
                anchors.fill:           parent
                fillMode:               Image.PreserveAspectFit
                smooth:                 true
                color:                  "white"//showHighlight ? qgcPal.buttonText : qgcPal.buttonHighlightText
                source:                 control.imageResource
            }
        }

        label: Item {}
    }
}
