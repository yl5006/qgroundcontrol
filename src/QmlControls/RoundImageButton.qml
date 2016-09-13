import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Button {
    property bool   showborder:     false
    property bool   showLable:      false  ///< true: setup complete indicator shows as completed                                ///< true: show setup complete indicator
    property string imageResource:  "/qmlimages/subMenuButtonImage.png"     ///< Button image
    property color  bordercolor:     "White"
    text: "Button"  ///< Pass in your own button text
    property bool   showcheckcolor:      false
    checkable:      true
    implicitHeight: ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3.5 : ScreenTools.defaultFontPixelHeight * 2.5

    style: ButtonStyle {
        id: buttonStyle

        QGCPalette {
            id:                 qgcPal
            colorGroupEnabled:  control.enabled
        }

        property bool showHighlight: control.pressed | control.checked

        background: Rectangle {
            id:     innerRect
            anchors.fill:   parent
            color:          (showcheckcolor && control.checked)?qgcPal.buttonHighlight:qgcPal.windowShade
            radius:         width / 2
            border.width:   showborder? width / 20 :0
            border.color:   bordercolor
                QGCColoredImage {
                id:                     image
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width:                  parent.width/2
                height:                 width
                fillMode:               Image.PreserveAspectFit
                smooth:                 true
                color:                  showborder ? bordercolor  : "White"
                source:                 control.imageResource
            }

            QGCLabel {
                id:                     titleBar
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment:      TextEdit.AlignVCenter
                color:                  showHighlight ? qgcPal.buttonHighlightText : qgcPal.buttonText
                visible:                showLable
                text:                   control.text
            }
        }

        label: Item {}
    }
}
