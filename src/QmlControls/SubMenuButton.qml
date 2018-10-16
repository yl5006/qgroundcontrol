import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Button {
    id:             _rootButton
    property bool   setupComplete:  true                                    ///< true: setup complete indicator shows as completed
    property bool   setupIndicator: true                                    ///< true: show setup complete indicator
    property string imageResource:  "/qmlimages/subMenuButtonImage.png"     ///< Button image
    property size   sourceSize:     Qt.size(ScreenTools.defaultFontPixelHeight * 2, ScreenTools.defaultFontPixelHeight * 2)

    text: "Button"  ///< Pass in your own button text
    property bool   showcolor: true
    property color  imgcolor: qgcPal.text
    checkable:      false
    implicitHeight: ScreenTools.defaultFontPixelHeight * 2
    implicitWidth:  __panel.implicitWidth

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
                mipmap:                 true
                color:                  imgcolor
                source:                 control.imageResource
                sourceSize:             _rootButton.sourceSize
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
