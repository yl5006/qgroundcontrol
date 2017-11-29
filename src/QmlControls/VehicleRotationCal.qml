/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

Rectangle {
    id:     pro
    // Indicates whether calibration is valid for this control
    property bool calValid: false

    property real rotate: 1
    // Indicates whether the control is currently being calibrated
    property bool calInProgress: false

    // Text to show while calibration is in progress
    property string calInProgressText: qsTr("保持静止")/*qsTr("Hold Still")*/

    // Image source
    property var imageSource: ""

    property var __qgcPal: QGCPalette { colorGroupEnabled: enabled }
    color:  "transparent"
    Image {
        anchors.fill: parent
        source:     calValid ? "qrc:///qmlimages/calValid.svg": "qrc:///qmlimages/uncal.svg"
    //  fillMode:   Image.PreserveAspectFit
        smooth: true
    }
    Image {
        anchors.fill: parent
        anchors.margins:   parent.width*0.05
        source:     imageSource
    //  fillMode:   Image.PreserveAspectFit
        smooth: true
    }
    Rectangle {
         property real value : 0
         anchors.bottom:                parent.bottom
         anchors.bottomMargin:          parent.height*0.05
         anchors.left:                  parent.left
         anchors.leftMargin:            parent.width*0.05
         height: parent.height/6
         width:  calInProgress ? value : 0
         color:  Qt.rgba(0.102,0.887,0.609,0.8)
         NumberAnimation on value
                {
                    id: myAn1
                    from: 0
                    to:  pro.width*0.9
                    duration: rotate*3000
                    running: calInProgress
         }
     }
    QGCLabel {
        anchors.fill: parent
        anchors.margins:   parent.height*0.1
        horizontalAlignment:    Text.AlignHCenter
        verticalAlignment:      Text.AlignBottom
        font.pointSize:         ScreenTools.mediumFontPointSize
        text:                   calInProgress ? calInProgressText : (calValid ? qsTr("完成")/*qsTr("Completed")*/ : qsTr("未完成")/*qsTr("Incomplete")*/)
    }

//    Rectangle {
//        readonly property int inset: 5

//        x:      inset
//        y:      inset
//        width:  parent.width - (inset * 2)
//        height: parent.height - (inset * 2)
//        color: qgcPal.windowShade

//        Image {
//            width:      parent.width
//            height:     parent.height
//            source:     imageSource
//            fillMode:   Image.PreserveAspectFit
//            smooth: true
//        }

//        QGCLabel {
//            width:                  parent.width
//            height:                 parent.height
//            horizontalAlignment:    Text.AlignHCenter
//            verticalAlignment:      Text.AlignBottom
//            font.pointSize:         ScreenTools.mediumFontPointSize
//            text:                   calInProgress ? calInProgressText : (calValid ? qsTr("Completed") : qsTr("Incomplete"))
//        }
//    }
}
