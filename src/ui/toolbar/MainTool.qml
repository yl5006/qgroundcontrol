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
 *   @brief QGC Main Tool Bar
 *   @author Gus Grubba <mavlink@grubba.com>
 */

import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0
import QtGraphicalEffects                   1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0

Rectangle {
    id:         toolBar
    color:      Qt.rgba(0,0,0,0.75)
    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    property var  _activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property var  mainWindow:           null
    property bool isMessageImportant:   _activeVehicle ? !_activeVehicle.messageTypeNormal && !_activeVehicle.messageTypeNone : false

    property bool vehicleConnectionLost: _activeVehicle ? _activeVehicle.connectionLost : false

    readonly property color   colorGreen:     "#05f068"
    readonly property color   colorOrange:    "#f0ab06"
    readonly property color   colorRed:       "#fc4638"
    readonly property color   colorGrey:      "#7f7f7f"
    readonly property color   colorBlue:      "#636efe"
    readonly property color   colorWhite:     "#ffffff"



    RowLayout {
        anchors.bottomMargin:   1
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth / 2
        anchors.fill:           parent
        spacing:                ScreenTools.defaultFontPixelWidth * 2
        //-------------------------------------------------------------------------
        //-- Vehicle Selector
        QGCButton {
            id:                     vehicleSelectorButton
            width:                  ScreenTools.defaultFontPixelHeight * 8
            text:                   "Vehicle " + (_activeVehicle ? _activeVehicle.id : "None")
            visible:                QGroundControl.multiVehicleManager.vehicles.count > 1
            anchors.verticalCenter: parent.verticalCenter

            menu: vehicleMenu

            Menu {
                id: vehicleMenu
            }

            Component {
                id: vehicleMenuItemComponent

                MenuItem {
                    onTriggered: QGroundControl.multiVehicleManager.activeVehicle = vehicle

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

        MainToolBarIndicators {
            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.66
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            Layout.fillWidth:   true
            visible:            QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable&&_activeVehicle
        }

        QGCLabel {
            id:                     waitForVehicle
            anchors.verticalCenter: parent.verticalCenter
            text:                   qsTr("Waiting For Vehicle Connection")
            font.pointSize:         ScreenTools.mediumFontPointSize
            font.family:            ScreenTools.demiboldFontFamily
            color:                  colorRed
            visible:                !_activeVehicle
        }
    }

//    Item {
//        id:                     vehicleIndicators
//        height:                 parent.height
//        anchors.left:           parent.left
//        anchors.right:          parent.right
//        visible:                false
//        property bool vehicleConnectionLost: activeVehicle ? activeVehicle.connectionLost : false

//        Loader {
//            source:                   (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable&&activeVehicle ) ? "MainToolBarIndicatorsRight.qml" : ""
//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.verticalCenter:   parent.verticalCenter
//        }
//    }

    // Progress bar
    Rectangle {
        id:             progressBar
        anchors.top:    parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        height:         toolBar.height * 0.02
        radius:         1
        width:          activeVehicle ? activeVehicle.parameterManager.loadProgress * parent.width : 0//parent.width * _controller.progressBarValue
        color:          colorGreen
    }
    RectangularGlow {
        id: effect
        anchors.fill: progressBar
        glowRadius: ScreenTools.defaultFontPixelHeight/4
        spread: 0.1
        color: progressBar.color
        cornerRadius:   glowRadius
        visible:        progressBar.width > 0
    }
}
