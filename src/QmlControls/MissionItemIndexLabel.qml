import QtQuick                  2.5
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2

import QGroundControl.ScreenTools 1.0
import QGroundControl.Palette     1.0


//Rectangle {
Item {
    property alias  label:          _label.text
    property bool   isCurrentItem:  false
    property bool   small:          false

    signal clicked

    width:          _width*2
    height:         _width*2
//  radius:         _width / 2
//  border.width:   small ? 1 : 2
//  border.color:   "white"
//  color:          isCurrentItem ? "green" : qgcPal.mapButtonHighlight

    property real _width: small ? ScreenTools.smallFontPixelSize * 1.2 : ScreenTools.mediumFontPixelSize * 1.2

    QGCPalette { id: qgcPal }

    MouseArea {
        anchors.fill: point//parent

        onClicked: parent.clicked()
    }

    Image {
        id:         waypoint
        source:     isCurrentItem ? "/qmlimages/Waypoint0.svg" : "/qmlimages/Waypoint.svg"
        mipmap:     true
        fillMode:   Image.PreserveAspectFit
        anchors.fill: parent
    }
    Rectangle {
        id:             point
        width:          _width
        height:         _width
        radius:         _width / 2
        color:              Qt.rgba(0,0,0,0.0)
        anchors.topMargin: _width/3
        anchors.top:     parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        QGCLabel {
            id:                     _label
            anchors.fill:           parent
            horizontalAlignment:    Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter
            color:                  "white"
            font.pixelSize:         small ? ScreenTools.smallFontPixelSize : ScreenTools.mediumFontPixelSize
        }
    }
}
