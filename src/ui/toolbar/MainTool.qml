﻿/****************************************************************************
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

    property var  activeVehicle:        QGroundControl.multiVehicleManager.activeVehicle
    property var  mainWindow:           null
    property bool isMessageImportant:   activeVehicle ? !activeVehicle.messageTypeNormal && !activeVehicle.messageTypeNone : false

    property bool vehicleConnectionLost: activeVehicle ? activeVehicle.connectionLost : false

    readonly property var   colorGreen:     "#05f068"
    readonly property var   colorOrange:    "#f0ab06"
    readonly property var   colorRed:       "#fc4638"
    readonly property var   colorGrey:      "#7f7f7f"
    readonly property var   colorBlue:      "#636efe"
    readonly property var   colorWhite:     "#ffffff"

    MainToolBarController { id: _controller }

    function getBatteryColor() {
        if(activeVehicle) {
            if(activeVehicle.battery.percentRemaining.value > 75) {
                return colorGreen
            }
            if(activeVehicle.battery.percentRemaining.value > 30) {
                return colorOrange
            }
            if(activeVehicle.battery.percentRemaining.value > 0.1) {
                return colorRed
            }
        }
        return colorGrey
    }

    function getRSSIColor(value) {
        if(value >= 0)
            return colorGrey;
        if(value > -60)
            return colorGreen;
        if(value > -90)
            return colorOrange;
        return colorRed;
    }
    //---------------------------------------------
    // GPS Info
    Component {
        id: gpsInfo

        Rectangle {
            width:  gpsCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: gpsCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window

            Column {
                id:                 gpsCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(gpsGrid.width, gpsLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             gpsLabel
                    text:           (activeVehicle && activeVehicle.gps.count.value >= 0) ?  qsTr("GPS 状态") /*qsTr("GPS Status")*/ : qsTr("GPS 信息不可用") /*qsTr("GPS Data Unavailable")*/
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 gpsGrid
                    visible:            (activeVehicle && activeVehicle.gps.count.value >= 0)
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 2

                    QGCLabel { text: qsTr("卫星颗数:")/*qsTr("GPS Count:")*/ }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.count.valueString : qsTr("N/A", "No data to display") }
                    QGCLabel { text: qsTr("锁定模式:")/*qsTr("GPS Lock:")*/ }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.lock.enumStringValue : qsTr("N/A", "No data to display") }
                    QGCLabel { text: qsTr("水平精度:")/*qsTr("HDOP:")*/ }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.hdop.valueString : qsTr("--.--", "No data to display") }
                    QGCLabel { text: qsTr("垂直精度:")/*qsTr("VDOP:")*/ }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.vdop.valueString : qsTr("--.--", "No data to display") }
                    QGCLabel { text: qsTr("地面速度:") /*qsTr("Course Over Ground:")*/ }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.courseOverGround.valueString : qsTr("--.--", "No data to display") }
                }
            }

            Component.onCompleted: {
                var pos = mapFromItem(toolBar, centerX - (width / 2), toolBar.height)
                x = pos.x
                y = pos.y + ScreenTools.defaultFontPixelHeight
            }
        }
    }

    //---------------------------------------------
    // Battery Info
    Component {
        id: batteryInfo

        Rectangle {
            width:  battCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: battCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window

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
                    QGCLabel { text: (activeVehicle && activeVehicle.battery.voltage.value != -1) ? (activeVehicle.battery.voltage.valueString + " " + activeVehicle.battery.voltage.units) : "N/A" }
                    QGCLabel { text: qsTr("消耗:")/*qsTr("Accumulated Consumption:")*/ }
                    QGCLabel { text: (activeVehicle && activeVehicle.battery.mahConsumed.value != -1) ? (activeVehicle.battery.mahConsumed.valueString + " " + activeVehicle.battery.mahConsumed.units) : "N/A" }
                }
            }

            Component.onCompleted: {
                var pos = mapFromItem(toolBar, centerX - (width / 2), toolBar.height)
                x = pos.x
                y = pos.y + ScreenTools.defaultFontPixelHeight
            }
        }
    }

    //---------------------------------------------
    // RC RSSI Info
    Component {
        id: rcRSSIInfo

        Rectangle {
            width:  rcrssiCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: rcrssiCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window

            Column {
                id:                 rcrssiCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(rcrssiGrid.width, rssiLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             rssiLabel
                    text:           activeVehicle ? (activeVehicle.rcRSSI != 255 ? qsTr("遥控信号状态")/*qsTr("RC RSSI Status")*/ : qsTr("遥控信号强度不可用")/*qsTr("RC RSSI Data Unavailable")*/) : qsTr("N/A", qsTr("无数据")/*"No data avaliable"*/)
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 rcrssiGrid
                    visible:            activeVehicle && activeVehicle.rcRSSI != 255
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                    QGCLabel { text: qsTr("RSSI:") }
                    QGCLabel { text: activeVehicle ? (activeVehicle.rcRSSI + "%") : 0 }
                }
            }

            Component.onCompleted: {
                var pos = mapFromItem(toolBar, centerX - (width / 2), toolBar.height)
                x = pos.x
                y = pos.y + ScreenTools.defaultFontPixelHeight
            }
        }
    }

    //---------------------------------------------
    // Telemetry RSSI Info
    Component {
        id: telemRSSIInfo

        Rectangle {
            width:  telemCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: telemCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window

            Column {
                id:                 telemCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(telemGrid.width, telemLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             telemLabel
                    text:           qsTr("Telemetry RSSI Status")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 telemGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                    QGCLabel { text: qsTr("Local RSSI:") }
                    QGCLabel { text: _controller.telemetryLRSSI + " dBm" }
                    QGCLabel { text: qsTr("Remote RSSI:") }
                    QGCLabel { text: _controller.telemetryRRSSI + " dBm" }
                    QGCLabel { text: qsTr("RX Errors:") }
                    QGCLabel { text: _controller.telemetryRXErrors }
                    QGCLabel { text: qsTr("Errors Fixed:") }
                    QGCLabel { text: _controller.telemetryFixed }
                    QGCLabel { text: qsTr("TX Buffer:") }
                    QGCLabel { text: _controller.telemetryTXBuffer }
                    QGCLabel { text: qsTr("Local Noise:") }
                    QGCLabel { text: _controller.telemetryLNoise }
                    QGCLabel { text: qsTr("Remote Noise:") }
                    QGCLabel { text: _controller.telemetryRNoise }
                }
            }

            Component.onCompleted: {
                var pos = mapFromItem(toolBar, centerX - (width / 2), toolBar.height)
                x = pos.x
                y = pos.y + ScreenTools.defaultFontPixelHeight
            }
        }
    }
    Item {
        id:                     vehicleIndicators
        height:                 parent.height
        anchors.left:           parent.left
        anchors.right:          parent.right
        property bool vehicleConnectionLost: activeVehicle ? activeVehicle.connectionLost : false

        Loader {            
            source:                   (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable&&activeVehicle ) ? "MainToolBarIndicatorsRight.qml" : ""
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter
        }
    }

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
