/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.3
import QtQuick.Controls 1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controllers           1.0
import QGroundControl.AutoPilotPlugin       1.0
//-------------------------------------------------------------------------
//-- Mode Indicator
Item {
    id:             flightModeSelector
    width:          mainWindow.tbHeight * 3//(gpsValuesColumn.x + gpsValuesColumn.width) * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    function getVehicleimg(_activeVehicle)
    {
        if(_activeVehicle.multiRotor)
        {
            return "/qmlimages/Quad.svg"
        }
        else if(_activeVehicle.fixedWing)
        {
            return "/qmlimages/AirframeStandardPlane.svg"
        }
        else
            return "/qmlimages/Quad.svg"
    }

    QGCCircleProgress{
        id:                     modeircle
        anchors.left:           parent.left
        width:                  mainWindow.tbHeight*1.5
        value:                  0
        valuecolor:             colorGrey
        anchors.verticalCenter: parent.verticalCenter
    }
    QGCColoredImage {
        id:             modeIcon
        source:         _activeVehicle ? getVehicleimg(_activeVehicle):"/qmlimages/Quad.svg"
        height:         mainWindow.tbCellHeight
        width:          height
        sourceSize.height: height
        color:          qgcPal.text
        fillMode:       Image.PreserveAspectFit
        anchors.horizontalCenter:   modeircle.horizontalCenter
        anchors.verticalCenter:     modeircle.verticalCenter
    }
    QGCLabel {
        id:                 mod
        anchors.left:       modeIcon.left
        anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
        text:               _activeVehicle ? _activeVehicle.flightMode : qsTr("N/A", "No data to display")
        font.pointSize:     ScreenTools.mediumFontPointSize
        color:              qgcPal.buttonText
        anchors.verticalCenter: parent.verticalCenter
    }
    Menu {
        id: flightModesMenu
    }
    Component {
        id: flightModeMenuItemComponent
        MenuItem {
            onTriggered: _activeVehicle.flightMode = text
        }
    }
    property var flightModesMenuItems: []
    function updateFlightModesMenu() {
        if (_activeVehicle && _activeVehicle.flightModeSetAvailable) {
            // Remove old menu items
            for (var i = 0; i < flightModesMenuItems.length; i++) {
                flightModesMenu.removeItem(flightModesMenuItems[i])
            }
            flightModesMenuItems.length = 0
            // Add new items
            for (var i = 0; i < activeVehicle.flightModes.length; i++) {
                var menuItem = flightModeMenuItemComponent.createObject(null, { "text": _activeVehicle.flightModes[i] })
                flightModesMenuItems.push(menuItem)
                flightModesMenu.insertItem(i, menuItem)
            }
        }
    }
    Component.onCompleted: flightModeSelector.updateFlightModesMenu()
    Connections {
        target:                 QGroundControl.multiVehicleManager
        onActiveVehicleChanged: flightModeSelector.updateFlightModesMenu()
    }
    MouseArea {
        visible:        _activeVehicle && _activeVehicle.flightModeSetAvailable
        anchors.fill:   mod//parent
        onClicked:      flightModesMenu.popup()
    }
}
