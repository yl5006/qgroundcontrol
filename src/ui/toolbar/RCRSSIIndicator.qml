﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.5
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- GPS Indicator
Item {
    width:          mainWindow.tbHeight * 3//rssiRow.width * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    visible:        activeVehicle ? activeVehicle.supportsRadio : true

    function getRSSIColor(value) {
        if(value >= 90)
            return colorGreen;
        if(value > 80)
            return colorOrange;
        return colorRed;
    }

    Component {
        id: rcRSSIInfo

        Rectangle {
            width:  rcrssiCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: rcrssiCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

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
    QGCCircleProgress{
        id:          rccircle
        anchors.left:  parent.left
        width:       mainWindow.tbHeight*1.5
        value:       activeVehicle ? ((activeVehicle.rcRSSI > 100) ? 0 : activeVehicle.rcRSSI/100) : 0
        valuecolor:  getRSSIColor(activeVehicle ?activeVehicle.rcRSSI:0)
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
