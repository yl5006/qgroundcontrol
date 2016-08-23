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
    height: size//attitudeWidget.y + attitudeWidget.height + _topBottomMargin
    width:  attitudeWidget.width + mask.width_+_topBottomMargin
    color:          Qt.rgba(0,0,0,0)
    property alias  heading:        attitudeWidget.heading//compass.heading
    property alias  rollAngle:      attitudeWidget.rollAngle
    property alias  pitchAngle:     attitudeWidget.pitchAngle
    property real   size:           _defaultSize
    property bool   lightBorders:   true
    property bool   active:         false
    property var    qgcView
    property real   maxHeight

    property Fact   _emptyFact:         Fact { }
    property Fact   groundSpeedFact:    _emptyFact
    property Fact   airSpeedFact:       _emptyFact

    property real   _defaultSize:   ScreenTools.defaultFontPixelHeight * (9)

    property color  _backgroundColor:   qgcPal.window
    property real   _spacing:           ScreenTools.defaultFontPixelHeight * 0.33
    property real   _topBottomMargin:   (size * 0.05) / 2
 //   property real   _availableValueHeight: maxHeight - (attitudeWidget.height + _spacer1.height + _spacer2.height + (_spacing * 4)) - (_showCompass ? compass.height : 0)
    property real   _availableValueHeight: maxHeight - (_spacing * 4)
    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    readonly property bool _showCompass:    true // !ScreenTools.isShortScreen

    QGCPalette { id: qgcPal }

//    MouseArea {
//        anchors.fill:       valuesspacer
//        onClicked: _valuesWidget.showPicker()
//    }
//    Rectangle {
//        id:                 valuesspacer
////      anchors.topMargin:  _spacing//
//        anchors.top:        parent.top
//        anchors.bottom:     attitudeWidget.top
//        anchors.bottomMargin:  _spacing
//        width:              parent.width * 0.9
//        radius:             _spacing*2
//        color:              Qt.rgba(0,0,0,0.65)
//        anchors.horizontalCenter: parent.horizontalCenter
//    }
//    ValuesWidget {
//        id:                 _valuesWidget
//        anchors.topMargin:  _spacing//
//        anchors.top:        parent.top//_spacer1.bottom
//        width:              parent.width
//        qgcView:            instrumentPanel.qgcView
//        textColor:          "white"//isSatellite ? "black" : "white"
//        maxHeight:          _availableValueHeight
//        visible:            _showCompass
//    }
    Rectangle {
            id:                 souce
            anchors.right:      parent.right
            anchors.rightMargin: _topBottomMargin*4
            anchors.bottom:     parent.bottom
            width:              parent.height
            height:             width
            radius:             width/2
            color:              Qt.rgba(255,255,255,1)
            visible: false
        }
    Rectangle {
            id:                 mask
            anchors.right:      souce.right
            anchors.bottom:     parent.bottom
            anchors.rightMargin: parent.height/2
            width:              parent.height*2
            height:             parent.height
            color:              Qt.rgba(0,0,0,0.65)
            visible: false
        }
    OpacityMask {
        anchors.fill: mask
        source: souce
        maskSource: mask
    }
    QGCAttitudeCompassWidget {
        id:             attitudeWidget
        anchors.bottom:  parent.bottom
        anchors.right:   parent.right
        y:              _topBottomMargin
        size:            parent.height
        active:         instrumentPanel.active
        visible:        false//!QGroundControl.virtualTabletJoystick
        anchors.verticalCenter:  parent.verticalCenter
     }

}
