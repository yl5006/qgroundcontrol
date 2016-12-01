import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Item {
    id: progressbar
    property real   value: 0.2
    property string test: qsTr("Firmware")
    property int    _progressCount: 25                   // Number of bar on vehicle
    property  color    _posColor:           Qt.rgba(0.1894,0.7333,0.8510,1)          //     "#15ce15"   // Green
    property  color    _dotColor:           Qt.rgba(0.1894,0.7333,0.8510,0.5)        //  "#1283e0"   // Blue
    property  color    _unposColor:         Qt.rgba(0.2078,0.2549,0.3020,1)

        Repeater {
            id:     progressRepeater
            model: _progressCount

            Rectangle {
                id:     rotor
                x:      progressRepeater.width  / 2 + _armXCenter
                y:      progressRepeater.height / 2 + _armYCenter
                width:  ScreenTools.defaultFontPixelHeight *  0.8
                height: ScreenTools.defaultFontPixelHeight *    4
                property real _armOffsetRadians:        ((2 * Math.PI) / _progressCount)
                property real _armOffsetIndexRadians:   (_armOffsetRadians  * index-Math.PI/2)
                property real _armLength:               ScreenTools.defaultFontPixelHeight * 7
                property real _armXCenter:              Math.cos(_armOffsetIndexRadians) * _armLength // adjacent = cos * hypotenuse
                property real _armYCenter:              Math.sin(_armOffsetIndexRadians) * _armLength // opposite = sin * hypotenuse
                color :Qt.rgba(0,0,0,0)
                Rectangle {
                    id:              cicle
                    anchors.top :   parent.top
                    width:          ScreenTools.defaultFontPixelHeight * 0.8// 2.5
                    height:         ScreenTools.defaultFontPixelHeight * 2.5//0.8
                    radius:         ScreenTools.defaultFontPixelHeight /  2
                    color:           index * 4 /100 < value ? _posColor:_unposColor
                }
                RectangularGlow {
                    id: effect
                    anchors.fill: cicle
                    glowRadius: ScreenTools.defaultFontPixelHeight/2
                    spread: 0.2
                    color: cicle.color
                    cornerRadius: cicle.radius+glowRadius
                    visible:        index * 4 /100  <  value
                }
                Rectangle {
                    id:             dot
                    anchors.topMargin:  ScreenTools.defaultFontPixelHeight/2
                    anchors.top :   cicle.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width:          ScreenTools.defaultFontPixelHeight/2
                    height:         ScreenTools.defaultFontPixelHeight/2
                    radius:         ScreenTools.defaultFontPixelHeight/4
                    color:           _dotColor
                    visible:        index * 4 /100 <  value
                }
               transform: [
                    Rotation {
                        origin.x:           rotor.width  / 2
                        origin.y:           rotor.height / 2
                        angle:              360/25*index
                    }]

            } // Item

        } // Repeater

    QGCLabel {
        id:     label
        anchors.horizontalCenter: progressRepeater.horizontalCenter
        anchors.top : progressRepeater.top
        anchors.topMargin:  ScreenTools.defaultFontPixelHeight * 1
        font.pointSize: ScreenTools.defaultFontPointSize*1.5
        text:   test
    }
    QGCLabel {
        id:     percent
        anchors.top : label.bottom
        anchors.topMargin: ScreenTools.defaultFontPointSize*0.5
        anchors.horizontalCenter: label.horizontalCenter
        font.pointSize: ScreenTools.defaultFontPointSize
        text:   (value*100).toFixed(0)+" %"
    }
}
