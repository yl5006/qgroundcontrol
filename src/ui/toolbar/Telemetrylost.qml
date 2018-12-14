/****************************************************************************
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

    QGCCircleProgress{
        id:          telemcircle
        anchors.left:  parent.left
        width:       mainWindow.tbHeight * 1.4
        value:       activeVehicle ? (100 - activeVehicle.mavlinkLossPercent ) /100 : 0
        valuecolor:  activeVehicle ? getRSSIColor(100-activeVehicle.mavlinkLossPercent):qgcPal.text
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
        text:            activeVehicle ?(100- activeVehicle.mavlinkLossPercent ).toFixed(1)+" %":"0"
    }
}
