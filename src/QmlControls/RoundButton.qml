import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4

import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

Item {
    id: _root

    signal          clicked()
    property alias  buttonImage:    button.source
    property real   radius:         ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 2.5 : ScreenTools.defaultFontPixelWidth * 2.5
    property bool   rotateImage:    false
    property bool   animateImage:   false
    property bool   lightBorders:   true
    property color  imgcolor:      "White"
    width:  radius * 2
    height: radius * 2

    property bool checked: false
    property ExclusiveGroup exclusiveGroup: null

    QGCPalette { id: qgcPal }

    onExclusiveGroupChanged: {
        if (exclusiveGroup) {
            exclusiveGroup.bindCheckable(_root)
        }
    }

    onRotateImageChanged: {
        if (rotateImage) {
            imageRotation.running = true
        } else {
            imageRotation.running = false
            button.rotation = 0
        }
    }
    onAnimateImageChanged: {
        if (animateImage) {
            opacityAnimation.running = true
        } else {
            opacityAnimation.running = false
            button.opacity = 1
        }
    }
    Rectangle {
        anchors.fill:   parent
 //       radius:         width / 2
//        border.width:   ScreenTools.defaultFontPixelHeight * 0.0625
//        border.color:   lightBorders ? qgcPal.mapWidgetBorderLight : qgcPal.mapWidgetBorderDark
        color:          qgcPal.windowShade
        QGCColoredImage {
            id:                 button
       //     anchors.fill:       parent
            anchors.centerIn:   parent
            height:             parent.height*0.6
            width:              height
            sourceSize.height:  parent.height*0.6
            fillMode:           Image.PreserveAspectFit
            mipmap:             true
            smooth:             true
            color:              checked ? qgcPal.buttonHighlight : imgcolor
            RotationAnimation on rotation {
                id:             imageRotation
                loops:          Animation.Infinite
                from:           0
                to:             360
                duration:       500
                running:        false
            }
            NumberAnimation on opacity {
                id:         opacityAnimation
                running:    false
                from:       0.2
                to:         1.0
                loops:      Animation.Infinite
                duration:   2000
            }
        }
        MouseArea {
            anchors.fill:   parent
            onClicked: {
                checked = !checked
                _root.clicked()
                forceActiveFocus()
            }
        }
    }
}
