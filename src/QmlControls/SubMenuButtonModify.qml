import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Button {
    property bool   setupComplete:  true                                    ///< true: setup complete indicator shows as completed
    property bool   bigimg: false                                    ///< true: show setup complete indicator
    property string imageResource:  "/qmlimages/subMenuButtonImage.png"     ///< Button image
    property color  imgcolor: "white"
    text: ""  ///< Pass in your own button text

    checkable:      true
  //  implicitHeight: ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3.5 : ScreenTools.defaultFontPixelHeight * 2.5

    style: ButtonStyle {
        id: buttonStyle
        QGCPalette {
            id:                 qgcPal
            colorGroupEnabled:  control.enabled
        }
        property bool showHighlight: control.pressed

        background: Rectangle {
            id:     innerRect
            color:  qgcPal.buttonHighlight
            radius: 3
            implicitWidth: titleBar.x + titleBar.contentWidth + ScreenTools.defaultFontPixelWidth

            QGCColoredImage {
                id:                     image
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width:                  bigimg ? parent.width / 3*2 : parent.width/3
                height:                 width
                fillMode:               Image.PreserveAspectFit
                smooth:                 true
                color:                  imgcolor
                source:                 control.imageResource
            }

            QGCLabel {
                id:                         titleBar
                anchors.top:                image.bottom
                anchors.topMargin:          ScreenTools.defaultFontPixelHeight*0.5
                anchors.horizontalCenter:   image.horizontalCenter
                verticalAlignment:          TextEdit.AlignVCenter
                color:                      qgcPal.buttonText
                text:                       control.text
            }
        }

        label: Item {}
    }
}
