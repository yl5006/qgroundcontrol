﻿/*=====================================================================

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

import QtQuick                  2.4
import QtQuick.Controls         1.3
import QtQuick.Controls.Styles  1.2
import QtQuick.Dialogs          1.2
import QtLocation               5.3
import QtPositioning            5.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.FlightMap     1.0

Item {
    id: _root

    property var    _activeVehicle: multiVehicleManager.activeVehicle
    property real   _sizeRatio:     ScreenTools.isTinyScreen ? (size / _defaultSize) * 0.5 : size / _defaultSize
    property real   _bigFontSize:   ScreenTools.defaultFontPixelSize * 2.5  * _sizeRatio
    property real   _normalFontSize:ScreenTools.defaultFontPixelSize * 1.5  * _sizeRatio
    property real   _labelFontSize: ScreenTools.defaultFontPixelSize * 0.75 * _sizeRatio
    property bool   _isSatellite:   _mainIsMap ? _flightMap ? _flightMap.isSatelliteMap : true : true

    QGCMapPalette { id: mapPal; lightColors: !isBackgroundDark }

    function getGadgetWidth() {
        if(ScreenTools.isMobile) {
            if(ScreenTools.isTinyScreen)
                return mainWindow.width * 0.18// 0.2
            return mainWindow.width * 0.15//0.15
        }
        var w = mainWindow.width * 0.15//0.15
        return Math.min(w, 200)
    }

    ExclusiveGroup {
        id: _dropButtonsExclusiveGroup
    }

    //-- Vehicle GPS lock display
    Column {
        id:     gpsLockColumn
        y:      (parent.height - height) / 2
        width:  parent.width

        Repeater {
            model: multiVehicleManager.vehicles

            delegate:
            QGCLabel {
                width:                  gpsLockColumn.width
                horizontalAlignment:    Text.AlignHCenter
                visible:                !object.coordinateValid
                text:                   "No GPS Lock for Vehicle #" + object.id
                z:                      QGroundControl.zOrderMapItems - 2
                color:                  mapPal.text
            }
        }
    }

    //-- Dismiss Drop Down (if any)
    MouseArea {
        anchors.fill:   parent
        enabled:        _dropButtonsExclusiveGroup.current != null
        onClicked: {
            if(_dropButtonsExclusiveGroup.current)
                _dropButtonsExclusiveGroup.current.checked = false
            _dropButtonsExclusiveGroup.current = null
        }
    }
    //-- Alternate Instrument Panel
//    Rectangle {
//        id:                 info
//        anchors.leftMargin: ScreenTools.defaultFontPixelHeight
////      anchors.right:      parent.right
//        anchors.left:       parent.left
//        anchors.top:        parent.top
//        width:              getGadgetWidth()
//       // contentHeight:      layout.height
//        height:             getGadgetWidth()* (9/16)
//            //layout.height//getGadgetWidth() * (9/16)
//        color:              Qt.rgba(0,0,0,0.75)
//        radius:             getGadgetWidth()/16
//        Column {
//            id:                 instruments
//            anchors.margins:    ScreenTools.defaultFontPixelHeight
//            anchors.fill: parent
//            spacing:            ScreenTools.defaultFontPixelHeight*0.5
//            Row{
//                spacing:        ScreenTools.defaultFontPixelHeight//   ScreenTools.defaultFontPixelSize
//                Image {
//                    id:         attitude
//                    source:     "/qmlimages/Altitude.svg"
//                    width:      ScreenTools.defaultFontPixelSize*1.5
//                    height:     ScreenTools.defaultFontPixelSize*1.5
//                    mipmap:     true
//                    fillMode:   Image.PreserveAspectFit
//                }
//                QGCLabel {
//     //             text:           _altitudeWGS84 < 10000 ? _altitudeWGS84.toFixed(1) : _altitudeWGS84.toFixed(0)
//                    text:           "123"//_altitudeRelative.toFixed(2)+" m"
//                    font.pixelSize: ScreenTools.defaultFontPixelSize* 1.5
//                    font.weight:    Font.DemiBold
//                    color:          "white"
//                    horizontalAlignment: TextEdit.AlignHCenter
//                }
//            }
//            Row{
//                spacing:        ScreenTools.defaultFontPixelSize
//                Image {
//                    id:         groundSpeed
//                    source:     "/qmlimages/GroundSpeed.svg"
//                    width:      ScreenTools.defaultFontPixelSize* 1.5
//                    height:     ScreenTools.defaultFontPixelSize* 1.5
//                    mipmap:     true
//                    fillMode:   Image.PreserveAspectFit
//                }
//                QGCLabel {
//                    text:           (_groundSpeed).toFixed(2)+" m/s"
//                    font.pixelSize: ScreenTools.defaultFontPixelSize* 1.5
//                    font.weight:    Font.DemiBold
//                    color:          "white"
//                    horizontalAlignment: TextEdit.AlignHCenter
//                }
//            }
//            Row{
//                spacing:        ScreenTools.defaultFontPixelSize
//                Image {
//                    id:         throttle
//                    source:     "/qmlimages/Throttle.svg"
//                    width:      ScreenTools.defaultFontPixelSize* 1.5
//                    height:     ScreenTools.defaultFontPixelSize* 1.5
//                    mipmap:     true
//                    fillMode:   Image.PreserveAspectFit
//                }
//                QGCLabel {
//                    text:           (_groundSpeed).toFixed(1)+"  %"
//                    font.pixelSize: ScreenTools.defaultFontPixelSize* 1.5
//                    font.weight:    Font.DemiBold
//                    color:          "white"
//                    horizontalAlignment: TextEdit.AlignHCenter
//                }
//            }

////            QGCLabel {
////                text:           qsTr("高度 (m)")   //altitude//"Altitude (m)"
////                font.pixelSize: ScreenTools.defaultFontPixelSize * 0.75
////                width:          parent.width
////                height:         ScreenTools.defaultFontPixelSize * 0.75
////                color:          "white"
////                horizontalAlignment: TextEdit.AlignHCenter
////            }
////            QGCLabel {
//// //             text:           _altitudeWGS84 < 10000 ? _altitudeWGS84.toFixed(1) : _altitudeWGS84.toFixed(0)
////                text:           _altitudeRelative.toFixed(2)
////                font.pixelSize: ScreenTools.defaultFontPixelSize// * 1.5
////                font.weight:    Font.DemiBold
////                width:          parent.width
////                color:          "white"
////                horizontalAlignment: TextEdit.AlignHCenter
////            }
////            QGCLabel {
//////              text:           "Ground Speed (km/h)"
////                text:           qsTr("地速 m/s")//"Ground Speed (m/s)"
////                font.pixelSize: ScreenTools.defaultFontPixelSize * 0.75
////                width:          parent.width
////                height:         ScreenTools.defaultFontPixelSize * 0.75
////                color:          "white"
////                horizontalAlignment: TextEdit.AlignHCenter
////            }
////            QGCLabel {
//////              text:           (_groundSpeed * 3.6).toFixed(1)
////                text:           (_groundSpeed).toFixed(2)
////                font.pixelSize: ScreenTools.defaultFontPixelSize
////                font.weight:    Font.DemiBold
////                width:          parent.width
////                color:          "white"
////                horizontalAlignment: TextEdit.AlignHCenter
////            }
//        }
//    }
    //-- Instrument Panel
    QGCInstrumentWidget {
        id:                     instrumentGadget
        anchors.margins:        ScreenTools.defaultFontPixelHeight
//      anchors.right:          parent.right
        anchors.left:           parent.left
//      anchors.top:            parent.top
        anchors.top:            parent.top
//      anchors.verticalCenter: parent.verticalCenter
//      visible:                !QGroundControl.virtualTabletJoystick
        size:                   getGadgetWidth()
//      active:                 _activeVehicle!= null
        heading:                _heading
        rollAngle:              _roll
        pitchAngle:             _pitch
//      altitudeFact:           _altitudeAMSLFact
        altitudeFact:           _altitudeRelativeFact
        groundSpeedFact:        _groundSpeedFact
        airSpeedFact:           _airSpeedFact
        isSatellite:            _isSatellite
        z:                      QGroundControl.zOrderWidgets
        qgcView:                parent.parent.qgcView
        maxHeight:              parent.height - (ScreenTools.defaultFontPixelHeight * 2)
    }

    QGCInstrumentWidgetAlternate {
        id:                     instrumentGadgetAlternate
        anchors.margins:        ScreenTools.defaultFontPixelHeight
        anchors.top:            parent.top
        anchors.right:          parent.right
        visible:                QGroundControl.virtualTabletJoystick
        width:                  getGadgetWidth()
        active:                 _activeVehicle!= null
        heading:                _heading
        rollAngle:              _roll
        pitchAngle:             _pitch
        altitudeFact:           _altitudeAMSLFact
        groundSpeedFact:        _groundSpeedFact
        airSpeedFact:           _airSpeedFact
        isSatellite:            _isSatellite
        z:                      QGroundControl.zOrderWidgets
    }
/*     不显示
    ValuesWidget {
        anchors.topMargin:  ScreenTools.defaultFontPixelHeight
        anchors.top:        instrumentGadgetAlternate.bottom
        anchors.left:       instrumentGadgetAlternate.left
        width:              getGadgetWidth()
        qgcView:            parent.parent.qgcView
        textColor:          _isSatellite ? "white" : "black"
        visible:            QGroundControl.virtualTabletJoystick
        maxHeight:          multiTouchItem.y - y

        Component.onCompleted: console.log(y)
        onHeightChanged: console.log(y, height, multiTouchItem.y)
    }
*/
    //-- Vertical Tool Buttons
    Column {
        id:                         toolColumn
        visible:                    _mainIsMap
        anchors.margins:            ScreenTools.defaultFontPixelHeight
//      anchors.left:               parent.left
        anchors.right:               parent.right
        anchors.top:                parent.top
        spacing:                    ScreenTools.defaultFontPixelHeight

        //-- Map Center Control
        DropButton {
            id:                     centerMapDropButton
 //         dropDirection:          dropRight
            dropDirection:          dropLeft
            buttonImage:            "/qmlimages/MapCenter.svg"
            viewportMargins:        ScreenTools.defaultFontPixelWidth / 2
            exclusiveGroup:         _dropButtonsExclusiveGroup
            z:                      QGroundControl.zOrderWidgets

            dropDownComponent: Component {
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCCheckBox {
                        id:                 followVehicleCheckBox
                        text:               qsTr("跟随地图")//"Follow Vehicle"
                        checked:            _flightMap ? _flightMap._followVehicle : false
                        anchors.baseline:   centerMapButton.baseline

                        onClicked: {
                            _dropButtonsExclusiveGroup.current = null
                            _flightMap._followVehicle = !_flightMap._followVehicle
                        }
                    }

                    QGCButton {
                        id:         centerMapButton
                        text:       qsTr("回到中心")//"Center map on Vehicle"
                        enabled:    _activeVehicle&& !followVehicleCheckBox.checked

                        property var activeVehicle: multiVehicleManager.activeVehicle

                        onClicked: {
                            _dropButtonsExclusiveGroup.current = null
                            _flightMap.center = activeVehicle.coordinate
                        }
                    }
                }
            }
        }

        //-- Map Type Control
        DropButton {
            id:                     mapTypeButton
//          dropDirection:          dropRight
            dropDirection:          dropLeft
            buttonImage:            "/qmlimages/MapType.svg"
            viewportMargins:        ScreenTools.defaultFontPixelWidth / 2
            exclusiveGroup:         _dropButtonsExclusiveGroup
            z:                      QGroundControl.zOrderWidgets

            dropDownComponent: Component {
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    Repeater {
                        model: QGroundControl.flightMapSettings.mapTypes

                        QGCButton {
                            checkable:  true
                            checked:    _flightMap ? _flightMap.mapType == text : false
                            text:       modelData

                            onClicked: {
                                _flightMap.mapType = text
                                _dropButtonsExclusiveGroup.current = null
                            }
                        }
                    }
                }
            }
        }

        //-- Zoom Map In
        RoundButton {
            id:                 mapZoomPlus
            visible:            _mainIsMap && !ScreenTools.isTinyScreen
            buttonImage:        "/qmlimages/ZoomPlus.svg"
            exclusiveGroup:     _dropButtonsExclusiveGroup
            z:                  QGroundControl.zOrderWidgets
            onClicked: {
                if(_flightMap)
                    _flightMap.zoomLevel += 0.5
                checked = false
            }
        }

        //-- Zoom Map Out
        RoundButton {
            id:                 mapZoomMinus
            visible:            _mainIsMap && !ScreenTools.isTinyScreen
            buttonImage:        "/qmlimages/ZoomMinus.svg"
            exclusiveGroup:     _dropButtonsExclusiveGroup
            z:                  QGroundControl.zOrderWidgets
            onClicked: {
                if(_flightMap)
                    _flightMap.zoomLevel -= 0.5
                checked = false
            }
        }

    }

}
