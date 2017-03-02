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
    id:             satelitte
    width:          mainWindow.tbHeight * 3//(gpsValuesColumn.x + gpsValuesColumn.width) * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    Component {
        id: gpsInfo

        Rectangle {
            width:  gpsCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: gpsCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

            Column {
                id:                 gpsCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(gpsGrid.width, gpsLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             gpsLabel
                    text:           (activeVehicle && activeVehicle.gps.count.value >= 0) ? qsTr("GPS 状态") /*qsTr("GPS Status")*/ : qsTr("GPS 信息不可用") /*qsTr("GPS Data Unavailable")*/
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

    QGCCircleProgress{
        id:       gpsycircle
        anchors.left:  parent.left
        width:    mainWindow.tbHeight*1.5
        value:    activeVehicle ? activeVehicle.gps.count>15?0.99:activeVehicle.gps.count/15:0
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
