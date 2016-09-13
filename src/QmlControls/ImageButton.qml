import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Button {
    id:     _root
    property string imageResource:  "/qmlimages/subMenuButtonImage.png"     ///< Button image
    property string imageResource2: "/qmlimages/subMenuButtonImage.png"     ///< Button image
    property bool   img2visible:      false
    property string checkimage:    imageResource
    style: ButtonStyle {
        id: buttonStyle

        background: Rectangle {
            id:     innerRect
            color:  "transparent"
            Image {
                id:                     image
                anchors.fill:           parent
                fillMode:               Image.PreserveAspectFit
                smooth:                 true
                source:                 control.checked?control.checkimage:control.imageResource
                opacity:                control.enabled ? 1 : 0.5
            }
            Image {
                id:                     img
                anchors.centerIn:       image
                fillMode:               Image.PreserveAspectFit
                height:                 parent.width/2
                width:                  height
                smooth:                 true
                source:                 control.imageResource2
                visible:                control.checked&&img2visible
            }
            QGCLabel {
                id:                     titleBar
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize:         ScreenTools.mediumFontPointSize
                font.bold:              true
                color:                  qgcPal.buttonText
                text:                   control.text
            }
        }
         label: Item {}
    }
}
