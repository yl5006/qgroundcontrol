/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/**
 * @file
 *   @brief QGC Fly View Widgets
 *   @author Gus Grubba <mavlink@grubba.com>
 */

import QtQuick 2.4

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QtGraphicalEffects 1.0
Rectangle {
    id:     instrumentPanel
    height: getPreferredInstrumentWidth()
    width:  attitudeWidget.width + mask.width+_topBottomMargin
    color:          Qt.rgba(0,0,0,0)

    property var    _qgcView:           qgcView
    property real   _maxHeight:         maxHeight

    property real   _defaultSize:   ScreenTools.defaultFontPixelHeight * (9)

    property color  _backgroundColor:   qgcPal.window
    property real   _spacing:           ScreenTools.defaultFontPixelHeight * 0.33
    property real   _topBottomMargin:   (instrumentPanel.height * 0.05) / 2
 //   property real   _availableValueHeight: _maxHeight - (attitudeWidget.height + _spacer1.height + _spacer2.height + (_spacing * 4)) - (_showCompass ? compass.height : 0)
    property real   _availableValueHeight: _maxHeight - (_spacing * 4)
    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette { id: qgcPal }

    Rectangle {
            id:                 mask
            anchors.right:      attitudeWidget.right
            anchors.bottom:     parent.bottom
            anchors.rightMargin: parent.height/2
            width:              parent.height*2
            height:             parent.height
            color:              Qt.rgba(0, 0, 0, 0)
            LinearGradient {
                   anchors.fill: parent
                   start:   Qt.point(0,0)
                   end:     Qt.point(parent.width,0)
                   gradient: Gradient {
                       GradientStop { position: 0.0;    color:  Qt.rgba(0,0,0,0) }
                       GradientStop { position: 1.0;    color:  Qt.rgba(0,0,0,0.75)}
                   }
             }
    }
    QGCLabel {
        id:                     lable
        anchors.top:            mask.top
        anchors.topMargin:      _spacing*3
        anchors.left:           mask.left
        anchors.leftMargin:     _spacing*12
        horizontalAlignment:    Text.AlignHCenter
        font.pointSize:         ScreenTools.defaultFontPixelHeight
        font.family:            ScreenTools.demiboldFontFamily
        font.bold:              true
        color:                  "White"
        text:                   qsTr("飞行数据")
    }
    QGCLabel {
        id:                     picker
        anchors.top:            mask.top
        anchors.topMargin:      _spacing*3
        anchors.left:           lable.right
        anchors.leftMargin:     _spacing*12
        horizontalAlignment:    Text.AlignHCenter
        font.pointSize:         ScreenTools.defaultFontPixelHeight
        font.family:            ScreenTools.demiboldFontFamily
        font.bold:              true
        color:                  "White"
        text:                   "..."
    }
    MouseArea {
            anchors.fill:       picker
            onClicked: _valuesWidget.showPicker()
        }
    Rectangle {
            id:                 space
            anchors.topMargin:  _spacing*3
            anchors.top:        lable.bottom
            anchors.left:       mask.left
            anchors.leftMargin: _spacing*9
            height:             2
            width:              parent.height
            color:              "White"
    }
    ValuesWidgetBottom {
        id:                 _valuesWidget
        anchors.top:        space.bottom//_spacer1.bottom
        anchors.topMargin:  _spacing*3
        anchors.left:       mask.left
        anchors.leftMargin: _spacing*12
        width:              parent.height
        qgcView:            instrumentPanel._qgcView
        textColor:          "white"//isSatellite ? "black" : "white"
        maxHeight:          parent.height

    }

    QGCAttitudeCompassWidget {
        id:             attitudeWidget
        anchors.bottom:  parent.bottom
        anchors.right:   parent.right
        y:              _topBottomMargin
        size:            parent.height
        vehicle:         _activeVehicle
        anchors.verticalCenter:  parent.verticalCenter
     }

}
