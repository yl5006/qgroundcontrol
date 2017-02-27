/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.5
import QtQuick.Controls         1.2
import QtGraphicalEffects       1.0
import QtQuick.Controls.Styles  1.2
import QtQuick.Dialogs          1.1

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controllers   1.0



Row {   
    spacing:  tbSpacing * 6
    AirframeComponentController { id: controllerair; factPanel: qgcView }
    FactPanelController { id: controller; factPanel: qgcView }
    property Fact battNumCells:         controller.getParameterFact(-1, "BAT_N_CELLS",false)
    QGCPalette { id: qgcPal }
    //-------------------------------------------------------------------------
    function getBatteryVoltageText() {
        if (activeVehicle.battery.voltage.value >= 0) {
            return activeVehicle.battery.voltage.valueString + activeVehicle.battery.voltage.units
        }
        return 'N/A';
    }

    //-------------------------------------------------------------------------
    function getBatteryPercentageText() {
        if(activeVehicle) {
            if(activeVehicle.battery.percentRemaining.value > 98.9) {
                return "100%"
            }
            if(activeVehicle.battery.percentRemaining.value > 0.1) {
                return activeVehicle.battery.percentRemaining.valueString + activeVehicle.battery.percentRemaining.units
            }
            if(activeVehicle.battery.voltage.value >= 0) {
                return activeVehicle.battery.voltage.valueString + activeVehicle.battery.voltage.units
            }
        }
        return "N/A"
    }

    //-------------------------------------------------------------------------
    //-- Battery Indicator
    Item {
        id:         batteryStatus
        width:      mainWindow.tbHeight * 3
        height:     parent.height
        QGCCircleProgress{
            id:             batterycircle
            anchors.left:   parent.left
            width:          mainWindow.tbHeight*1.5
            value:          (activeVehicle && activeVehicle.battery.percentRemaining.value > 0 )? activeVehicle.battery.percentRemaining.value/100:0
            valuecolor:     getBatteryColor()
            anchors.verticalCenter: parent.verticalCenter
        }
        QGCColoredImage {
            id:         batteryimg
            height:     mainWindow.tbCellHeight
            width:      height
            sourceSize.width: width
            source:     "/qmlimages/Battery.svg"
            fillMode:   Image.PreserveAspectFit
            color:      qgcPal.text
            anchors.horizontalCenter:batterycircle.horizontalCenter
            anchors.verticalCenter: batterycircle.verticalCenter
        }
        Column{
               id:                  batvolt
               anchors.left:        batteryimg.left
               anchors.leftMargin:  ScreenTools.defaultFontPixelHeight*5
               anchors.verticalCenter: parent.verticalCenter
               spacing:             ScreenTools.defaultFontPixelWidth
        QGCLabel {
                text:           (activeVehicle && activeVehicle.battery.voltage.value != -1) ? (activeVehicle.battery.voltage.valueString + " " + activeVehicle.battery.voltage.units) : "N/A" //getBatteryPercentageText()
                font.pointSize: ScreenTools.mediumFontPointSize
                color:          getBatteryColor()            
            }
        QGCLabel {
                text:           " " +battNumCells.value+battNumCells.units
                font.pointSize: ScreenTools.mediumFontPointSize
                color:          getBatteryColor()
            }
        }

        MouseArea {
            anchors.fill:   parent
            onClicked: {
                if (activeVehicle) {
                    var centerX = mapToItem(toolBar, x, y).x + (width / 2)
                    mainWindow.showPopUp(batteryInfo, centerX)
                }
            }
        }
    }
    //-------------------------------------------------------------------------
    //-- RC RSSI
    Item {
        id:         rcRssi
        width:      mainWindow.tbHeight * 3
        height:     parent.height
        visible:    activeVehicle ? activeVehicle.supportsRadio : false
        QGCCircleProgress{
            id:          rccircle
            anchors.left:  parent.left
            width:       mainWindow.tbHeight*1.5
            value:       activeVehicle ? ((activeVehicle.rcRSSI > 100) ? 0 : activeVehicle.rcRSSI/100) : 0
            valuecolor:  getRSSIColor(activeVehicle.rcRSSI)
            anchors.verticalCenter: parent.verticalCenter
        }
        QGCColoredImage {
            id:         rcimg
            height:     mainWindow.tbCellHeight
            width:      height
            sourceSize.width: width
            source:     "/qmlimages/RC.svg"
            fillMode:   Image.PreserveAspectFit
            color:      qgcPal.text
            anchors.horizontalCenter:   rccircle.horizontalCenter
            anchors.verticalCenter:     rccircle.verticalCenter
        }
        MouseArea {
            anchors.fill:   parent
            onClicked: {
                var centerX = mapToItem(toolBar, x, y).x + (width / 2)
                mainWindow.showPopUp(rcRSSIInfo, centerX)
            }
        }
    }

    //-------------------------------------------------------------------------
    //-- GPS Indicator
    Item {
        id:         satelitte
        width:      mainWindow.tbHeight * 3
        height:     parent.height
        QGCCircleProgress{
            id:       gpsycircle
            anchors.left:  parent.left
            width:    mainWindow.tbHeight*1.5
            value:    activeVehicle.gps.count>15?0.99:activeVehicle.gps.count/15
            valuecolor:     colorGrey
            anchors.verticalCenter: parent.verticalCenter
        }
        QGCColoredImage {
            id:             gpsIcon
            source:         "/qmlimages/Gps.svg"
            height:     mainWindow.tbCellHeight
            width:      height
            sourceSize.height: height
            color:          qgcPal.text
            fillMode:       Image.PreserveAspectFit
            anchors.horizontalCenter:gpsycircle.horizontalCenter
            anchors.verticalCenter: gpsycircle.verticalCenter
        }

        QGCLabel {
                anchors.top:    gpsIcon.top
                anchors.right:  gpsIcon.right
                visible:    activeVehicle && !isNaN(activeVehicle.gps.hdop.value)
                color:     (activeVehicle && activeVehicle.gps.fix > 2 )? colorGreen :qgcPal.buttonText
                text:       activeVehicle ? activeVehicle.gps.count.valueString : ""
        }

         QGCLabel {
                id:         hdopValue
                anchors.left:   gpsIcon.left
                anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                anchors.verticalCenter: parent.verticalCenter
                visible:    activeVehicle && !isNaN(activeVehicle.gps.hdop.value)
                color:      qgcPal.buttonText
                text:       activeVehicle ? activeVehicle.gps.hdop.value.toFixed(1) : ""
          }

        MouseArea {
            anchors.fill:   parent
            onClicked: {
                var centerX = mapToItem(toolBar, x, y).x + (width / 2)
                mainWindow.showPopUp(gpsInfo, centerX)
            }
        }
    }

    //-------------------------------------------------------------------------
    //-- telem RSSI
    Item {
        id:         telemRs
        width:      mainWindow.tbHeight * 3
        height:     parent.height
        visible:    activeVehicle ? activeVehicle.supportsRadio : false
        QGCCircleProgress{
            id:          telemcircle
            anchors.left:  parent.left
            width:       mainWindow.tbHeight*1.5
            value:       activeVehicle ? (100-_controller.telemetrylossPercent)/100:0
            valuecolor:  getRSSIColor(100-_controller.telemetrylossPercent)
            anchors.verticalCenter: parent.verticalCenter
        }
        QGCColoredImage {
            id:         telemimg
            height:     mainWindow.tbCellHeight
            width:      height
            sourceSize.width: width
            source:     "/qmlimages/TelemRSSI.svg"
            fillMode:   Image.PreserveAspectFit
            color:      qgcPal.text
            anchors.horizontalCenter:   telemcircle.horizontalCenter
            anchors.verticalCenter:     telemcircle.verticalCenter
        }
        QGCLabel {
            anchors.left:   telemimg.left
            anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
            anchors.verticalCenter: parent.verticalCenter
            color:          qgcPal.buttonText
            text:           (100-_controller.telemetrylossPercent).toFixed(1)+" %"
        }
    }


    //-------------------------------------------------------------------------
    //-- Telemetry RSSI
    Item {
        id:         telemRssi
        width:      telemIcon.width
        height:     mainWindow.tbCellHeight
        visible:    _controller.telemetryLRSSI < 0
        QGCColoredImage {
            id:         telemIcon
            height:     parent.height * 0.5
            sourceSize.height: height
            width:      height * 1.5
            source:     "/qmlimages/TelemRSSI.svg"
            fillMode:   Image.PreserveAspectFit
            color:      qgcPal.buttonText
            anchors.verticalCenter: parent.verticalCenter
        }
        MouseArea {
            anchors.fill:   parent
            onClicked: {
                var centerX = mapToItem(toolBar, x, y).x + (width / 2)
                mainWindow.showPopUp(telemRSSIInfo, centerX)
            }
        }
    }



    //-------------------------------------------------------------------------
    //-- Vehicle Selector
    QGCButton {
        id:                     vehicleSelectorButton
        width:                  ScreenTools.defaultFontPixelHeight * 8
        text:                   "Vehicle " + (activeVehicle ? activeVehicle.id : "None")
        visible:                QGroundControl.multiVehicleManager.vehicles.count > 1
        anchors.verticalCenter: parent.verticalCenter

        menu: vehicleMenu

        Menu {
            id: vehicleMenu
        }

        Component {
            id: vehicleMenuItemComponent

            MenuItem {
                checkable:      true
                onTriggered:    QGroundControl.multiVehicleManager.activeVehicle = vehicle

                property int vehicleId: Number(text.split(" ")[1])
                property var vehicle:   QGroundControl.multiVehicleManager.getVehicleById(vehicleId)
            }
        }

        property var vehicleMenuItems: []

        function updateVehicleMenu() {
            // Remove old menu items
            for (var i = 0; i < vehicleMenuItems.length; i++) {
                vehicleMenu.removeItem(vehicleMenuItems[i])
            }
            vehicleMenuItems.length = 0

            // Add new items
            for (var i=0; i<QGroundControl.multiVehicleManager.vehicles.count; i++) {
                var vehicle = QGroundControl.multiVehicleManager.vehicles.get(i)
                var menuItem = vehicleMenuItemComponent.createObject(null, { "text": "Vehicle " + vehicle.id })
                vehicleMenuItems.push(menuItem)
                vehicleMenu.insertItem(i, menuItem)
            }
        }

        Component.onCompleted: updateVehicleMenu()

        Connections {
            target:         QGroundControl.multiVehicleManager.vehicles
            onCountChanged: vehicleSelectorButton.updateVehicleMenu()
        }
    }

    //-------------------------------------------------------------------------
       //-- Mode Selector

    Item {
        id:     flightModeSelector
        width:  mainWindow.tbHeight * 3
        height: mainWindow.tbCellHeight
        anchors.verticalCenter: parent.verticalCenter
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
                    source:         controllerair.currentAirframeImgSouce//"/qmlimages/Quad.svg"
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
                    text:               activeVehicle ? activeVehicle.flightMode : qsTr("N/A", "No data to display")
                    font.pointSize:     ScreenTools.mediumFontPointSize
                    color:              qgcPal.buttonText
                    anchors.verticalCenter: parent.verticalCenter
                }
//        Row {
//            id:                 selectorRow
//            spacing:            tbSpacing
//            anchors.verticalCenter:   parent.verticalCenter
//            anchors.horizontalCenter: parent.horizontalCenter

//            QGCLabel {
//                text:           activeVehicle ? activeVehicle.flightMode : qsTr("N/A", "No data to display")
//                font.pointSize: ScreenTools.mediumFontPointSize
//                color:          qgcPal.buttonText
//                anchors.verticalCenter: parent.verticalCenter
//            }
//        }

           Menu {
               id: flightModesMenu
           }

           Component {
               id: flightModeMenuItemComponent

               MenuItem {
                   onTriggered: {
                       if(activeVehicle) {
                           activeVehicle.flightMode = text
                       }
                   }
               }
           }

           property var flightModesMenuItems: []

           function updateFlightModesMenu() {
               if (activeVehicle.flightModeSetAvailable) {
                   // Remove old menu items
                   for (var i = 0; i < flightModesMenuItems.length; i++) {
                       flightModesMenu.removeItem(flightModesMenuItems[i])
                   }
                   flightModesMenuItems.length = 0
                   // Add new items
                   for (var i = 0; i < activeVehicle.flightModes.length; i++) {
                       var menuItem = flightModeMenuItemComponent.createObject(null, { "text": activeVehicle.flightModes[i] })
                       flightModesMenuItems.push(menuItem)
                       flightModesMenu.insertItem(i, menuItem)
                   }
               }
           }

           Component.onCompleted: updateFlightModesMenu()

           Connections {
               target:                 QGroundControl.multiVehicleManager
               onActiveVehicleChanged: flightModeSelector.updateFlightModesMenu
           }

           MouseArea {
               visible: activeVehicle ? activeVehicle.flightModeSetAvailable : false
               anchors.fill:   mod
               onClicked: {
                   flightModesMenu.popup()
                   text:           activeVehicle ? (activeVehicle.armed ? "Armed" : "Disarmed") : ""
               title:      activeVehicle ? (activeVehicle.armed ? "Disarming Vehicle" : "Arming Vehicle") : ""
               text:       activeVehicle ? (activeVehicle.armed ? "Do you want to disarm? This will cut power to all motors." : "Do you want to arm? This will enable all motors.") : ""
               }
           }
       }
    QGCView {
        id:         qgcView
        width:  1
        height: 1
    }

    //-------------------------------------------------------------------------
    //-- Mode Selector

//    Item {
//        id:         flightModeSelector
//        width:      mainWindow.tbHeight * 4
//        height:     parent.height
//        QGCCircleProgress{
//            id:                     modeircle
//            anchors.left:           parent.left
//            width:                  mainWindow.tbHeight*1.5
//            value:                  0
//            ciclectcolor:           colorGrey
//            valuecolor:             colorGrey
//            anchors.verticalCenter: parent.verticalCenter
//        }
//        QGCColoredImage {
//            id:             modeIcon
//            source:         "/qmlimages/Quad.svg"
//            height:         mainWindow.tbCellHeight
//            width:          height
//            sourceSize.height: height
//            color:          qgcPal.text
//            fillMode:       Image.PreserveAspectFit
//            anchors.horizontalCenter:   modeircle.horizontalCenter
//            anchors.verticalCenter:     modeircle.verticalCenter
//        }
//        QGCLabel {
//            id:                 mod
//            anchors.left:       modeIcon.left
//            anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
//            text:               activeVehicle ? activeVehicle.flightMode : qsTr("N/A", "No data to display")
//            font.pointSize:     ScreenTools.mediumFontPointSize
//            color:              qgcPal.buttonText
//            anchors.verticalCenter: parent.verticalCenter
//        }
//        Menu {
//            id: flightModesMenu
//        }

//        Component {
//            id: flightModeMenuItemComponent

//            MenuItem {
//                onTriggered: {
//                    if(activeVehicle) {
//                        activeVehicle.flightMode = text
//                    }
//                }
//            }
//        }

//        property var flightModesMenuItems: []

//        function updateFlightModesMenu() {
//            if (activeVehicle.flightModeSetAvailable) {
//                // Remove old menu items
//                for (var i = 0; i < flightModesMenuItems.length; i++) {
//                    flightModesMenu.removeItem(flightModesMenuItems[i])
//                }
//                flightModesMenuItems.length = 0
//                // Add new items
//                for (var i = 0; i < activeVehicle.flightModes.length; i++) {
//                    var menuItem = flightModeMenuItemComponent.createObject(null, { "text": activeVehicle.flightModes[i] })
//                    flightModesMenuItems.push(menuItem)
//                    flightModesMenu.insertItem(i, menuItem)
//                }
//            }
//        }

//        Component.onCompleted: updateFlightModesMenu()

//        Connections {
//            target:                 QGroundControl.multiVehicleManager
//            onActiveVehicleChanged: flightModeSelector.updateFlightModesMenu
//        }

//        MouseArea {
//            visible: activeVehicle ? activeVehicle.flightModeSetAvailable : false
//            anchors.fill:   mod
//            onClicked: {
//                flightModesMenu.popup()
//                text:           activeVehicle ? (activeVehicle.armed ? "Armed" : "Disarmed") : ""
//            title:      activeVehicle ? (activeVehicle.armed ? "Disarming Vehicle" : "Arming Vehicle") : ""
//            text:       activeVehicle ? (activeVehicle.armed ? "Do you want to disarm? This will cut power to all motors." : "Do you want to arm? This will enable all motors.") : ""
//            }
//        }
//    }
}

