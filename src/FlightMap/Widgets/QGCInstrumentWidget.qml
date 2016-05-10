/*=====================================================================

QGroundControl Open Source Ground Control Station

(c) 2009, 2015 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>

This file is part of the QGROUNDCONTROL project

    QGROUNDCONTROL is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    QGROUNDCONTROL is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with QGROUNDCONTROL. If not, see <http://www.gnu.org/licenses/>.

======================================================================*/

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

Rectangle {
    id:     instrumentPanel
    height: attitudeWidget.y + attitudeWidget.height + _topBottomMargin
    width:  size
 //   color:  _backgroundColor
    color:          Qt.rgba(0,0,0,0)
    property alias  heading:        compass.heading
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
    property real   _availableValueHeight: maxHeight - (_spacer1.height + _spacer2.height + (_spacing * 4))
    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    readonly property bool _showCompass:    true // !ScreenTools.isShortScreen

    QGCPalette { id: qgcPal }

//    Rectangle {
//        anchors.left:   parent.left
//        anchors.right:  parent.right
//        height:         (_showCompass ? instrumentColumn.height : attitudeWidget.height) + (_topBottomMargin * 2)
//        radius:         size / 2
//        color:          _backgroundColor
//        border.width:   1
//        border.color:   lightBorders ? qgcPal.mapWidgetBorderLight : qgcPal.mapWidgetBorderDark
//    }

    MouseArea {
        anchors.fill:       valuesspacer
        onClicked: _valuesWidget.showPicker()
    }
    Rectangle {
        id:                 valuesspacer
//      anchors.topMargin:  _spacing//
        anchors.top:        parent.top
        anchors.bottom:     attitudeWidget.top
        anchors.bottomMargin:  _spacing
        width:              parent.width * 0.9
        radius:             _spacing*2
        color:              Qt.rgba(0,0,0,0.65)
        anchors.horizontalCenter: parent.horizontalCenter
    }
    ValuesWidget {
        id:                 _valuesWidget
        anchors.topMargin:  _spacing//
        anchors.top:        parent.top//_spacer1.bottom
        width:              parent.width
        qgcView:            instrumentPanel.qgcView
        textColor:          "white"//isSatellite ? "black" : "white"
        maxHeight:          _availableValueHeight
        visible:            _showCompass
    }
    QGCAttitudeWidget {
        id:             attitudeWidget
        anchors.top:    _valuesWidget.bottom
        anchors.topMargin:  _spacing//
        y:              _topBottomMargin
        size:           parent.width * 0.95
        active:         instrumentPanel.active
        visible:        !QGroundControl.virtualTabletJoystick
        anchors.horizontalCenter: parent.horizontalCenter
     }

    Image {
        id:                 gearThingy
        anchors.bottom:     attitudeWidget.bottom
        anchors.top:        attitudeWidget.top
        anchors.right:      attitudeWidget.right
        source:             qgcPal.globalTheme == QGCPalette.Light ? "/res/gear-black.svg" : "/res/gear-white.svg"
        mipmap:             true
        opacity:            0.5
        width:              attitudeWidget.width * 0.15
                sourceSize.width:   width
        fillMode:           Image.PreserveAspectFit
//      visible:            _activeVehicle
        visible:            false                //do not use yaoling
                MouseArea {
                    anchors.fill:   parent
                    hoverEnabled:   true
                    onEntered:      gearThingy.opacity = 0.85
                    onExited:       gearThingy.opacity = 0.5
                    onClicked:      _valuesWidget.showPicker()
                }
         }

    Rectangle {
        id:                 _spacer1
        anchors.topMargin:  _spacing
        anchors.top:        attitudeWidget.bottom
        height:             2
        width:              parent.width * 0.9
 //       color:              qgcPal.text
        color:              Qt.rgba(0,0,0,0.0)
        anchors.horizontalCenter: parent.horizontalCenter
    }
//do not use
//        Item {
//            width:  parent.width
//            height: _valuesWidget.height

//            Rectangle {
//                anchors.fill:   _valuesWidget
//                color:          _backgroundColor
//                visible:        !_showCompass
//                radius:         _spacing
//            }

//    InstrumentSwipeView {
//        id:                 _valuesWidget1
//        width:              parent.width
//        qgcView:            instrumentPanel.qgcView
//        textColor:          qgcPal.text
//        backgroundColor:    _backgroundColor
//        maxHeight:          _availableValueHeight
//    }
//       }

     Rectangle {
         id:                 _spacer2
         anchors.topMargin:  _spacing
         anchors.top:        _spacer1.bottom
         height:             1
         width:              parent.width * 0.9
//       color:              isSatellite ? Qt.rgba(0,0,0,0.25) : Qt.rgba(1,1,1,0.25)
         color:              Qt.rgba(0,0,0,0.0)
         anchors.horizontalCenter: parent.horizontalCenter
     }


     QGCCompassWidget {
            id:                 compass
            anchors.topMargin:  _spacing
            anchors.top:        _spacer2.bottom
            size:               parent.width * 0.95
            active:             instrumentPanel.active
            visible:            _showCompass
            anchors.horizontalCenter: parent.horizontalCenter
        }

}
