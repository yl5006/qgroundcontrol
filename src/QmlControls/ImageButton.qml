import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Button {
    property bool   select:  true                                    ///< true: setup complete indicator shows as completed
    property color  selectcolor:       "#000000"                             ///< true: show setup complete indicator
    property color  unselectcolor:  "#000000"
    property string imageResource:  "/qmlimages/subMenuButtonImage.png"     ///< Button image

    text: "Button"  ///< Pass in your own button text

    checkable:      true
    implicitHeight: ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3.5 : ScreenTools.defaultFontPixelHeight * 2.5

    style: ButtonStyle {
        id: buttonStyle

        QGCPalette {
            id:                 qgcPal
        }

        property bool showHighlight: control.pressed | control.checked

        background: Rectangle {
            id:     innerRect
    //        color:  showHighlight ? qgcPal.buttonHighlight : qgcPal.windowShade

    //        implicitWidth: titleBar.x + titleBar.contentWidth + ScreenTools.defaultFontPixelWidth

            QGCColoredImage {
                id:                     image
                anchors.fill:           parent
                fillMode:               Image.PreserveAspectFit
                smooth:                 true
                color:                  select ?
                source:                 control.imageResource
            }

            QGCLabel {
                id:                     title
                anchors.horizontalCenter: image.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment:      TextEdit.AlignVCenter
                color:                  showHighlight ? qgcPal.buttonHighlightText : qgcPal.buttonText
                text:                   control.text
            }
        }

        label: Item {}
    }
}
