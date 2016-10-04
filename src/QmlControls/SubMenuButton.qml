import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Button {
    property string imageResource:  "/qmlimages/subMenuButtonImage.png"     ///< Button image

    text: "Button"  ///< Pass in your own button text
    property bool   showcolor: true
    property color  imgcolor: qgcPal.text
    checkable:      false
    implicitHeight: ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight * 2

    style: ButtonStyle {
        id: buttonStyle

        QGCPalette {
            id:                 qgcPal
            colorGroupEnabled:  control.enabled
        }
        property bool showHighlight: control.pressed || control.hovered

        background: Rectangle {
            id:     innerRect
            color:  showHighlight ? qgcPal.buttonHighlight : (showcolor ? qgcPal.button:"transparent")

            implicitWidth: titleBar.x + titleBar.contentWidth + ScreenTools.defaultFontPixelWidth

            QGCColoredImage {
                id:                     image
                anchors.leftMargin:     ScreenTools.defaultFontPixelWidth
                anchors.left:           parent.left
                anchors.verticalCenter: parent.verticalCenter
                width:                  ScreenTools.defaultFontPixelHeight *1.5
                height:                 ScreenTools.defaultFontPixelHeight *1.5
                fillMode:               Image.PreserveAspectFit
                smooth:                 true
                color:                  imgcolor
                source:                 control.imageResource
            }

            QGCLabel {
                id:                     titleBar
                anchors.leftMargin:     ScreenTools.defaultFontPixelWidth
                anchors.left:           image.right
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment:      TextEdit.AlignVCenter
                color:                  showHighlight ? qgcPal.buttonHighlightText : imgcolor
                text:                   control.text
            }
        }

        label: Item {}
    }
}
