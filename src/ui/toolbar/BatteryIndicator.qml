﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0

//-------------------------------------------------------------------------
//-- Battery Indicator
Item {
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          mainWindow.tbHeight * 3//batteryIndicatorRow.width
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    function getBatteryColor() {
        if(_activeVehicle) {
            if(_activeVehicle.battery.percentRemaining.value > 75) {
                return qgcPal.colorGreen
            }
            if(_activeVehicle.battery.percentRemaining.value > 50) {
                return qgcPal.colorOrange
            }
            if(_activeVehicle.battery.percentRemaining.value > 0.1) {
                return qgcPal.colorRed
            }
        }
        return qgcPal.colorGrey
    }

    function getBatteryPercentageText() {
        if(_activeVehicle) {
            if(_activeVehicle.battery.percentRemaining.value > 98.9) {
                return "100%"
            }
            if(_activeVehicle.battery.percentRemaining.value > 0.1) {
                return _activeVehicle.battery.percentRemaining.valueString + _activeVehicle.battery.percentRemaining.units
            }
            if(_activeVehicle.battery.voltage.value >= 0) {
                return _activeVehicle.battery.voltage.valueString + _activeVehicle.battery.voltage.units
            }
        }
        return "N/A"
    }

    Component {
        id: batteryInfo

        Rectangle {
            width:  battCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: battCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

            Column {
                id:                 battCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(battGrid.width, battLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             battLabel
                    text:           qsTr("电池状态")//qsTr("Battery Status")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 battGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                    QGCLabel { text: qsTr("电压:") /*qsTr("Voltage:")*/ }
                    QGCLabel { text: (_activeVehicle && _activeVehicle.battery.voltage.value != -1) ? (_activeVehicle.battery.voltage.valueString + " " + _activeVehicle.battery.voltage.units) : "N/A" }
                    QGCLabel { text: qsTr("消耗:")/*qsTr("Accumulated Consumption:")*/ }
                    QGCLabel { text: (_activeVehicle && _activeVehicle.battery.mahConsumed.value != -1) ? (_activeVehicle.battery.mahConsumed.valueString + " " + _activeVehicle.battery.mahConsumed.units) : "N/A" }
                }
            }

            Component.onCompleted: {
                var pos = mapFromItem(toolBar, centerX - (width / 2), toolBar.height)
                x = pos.x
                y = pos.y + ScreenTools.defaultFontPixelHeight
            }
        }
    }

    QGCCircleProgress{
        id:             batterycircle
        anchors.left:   parent.left
        width:          mainWindow.tbHeight*1.5
        value:          (_activeVehicle && _activeVehicle.battery.percentRemaining.value > 0 )? _activeVehicle.battery.percentRemaining.value/100:0
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
            text:           _activeVehicle ?_activeVehicle.battery.cellCount.valueString+" "+"S":" "
            font.pointSize: ScreenTools.mediumFontPointSize
            color:          getBatteryColor()
        }
    }
    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showPopUp(batteryInfo, mapToItem(toolBar, x, y).x + (width / 2))
    }
}
