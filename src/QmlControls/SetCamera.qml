﻿import QtQuick          2.5
import QtQuick.Controls 1.3
import QtQuick.Layouts  1.2

import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0

/// Mission item Set control
Rectangle {
    id:      _root
    height:  ScreenTools.defaultFontPixelHeight*28
    color:   qgcPal.windowShade
    width:   ScreenTools.defaultFontPixelHeight*20
    readonly property var       _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle

    readonly property real  _editFieldWidth:    Math.min(width - _margin * 2, ScreenTools.defaultFontPixelWidth * 16)
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius:            ScreenTools.defaultFontPixelWidth / 2
    MouseArea {
        anchors.fill: parent
        onClicked: {
            forceActiveFocus()
        }
    }
    Timer {
        interval:   40  // 25Hz, same as real joystick rate
        running:    _activeVehicle
        repeat:     true
        onTriggered: {
            if (_activeVehicle && _root.visible) {
                _activeVehicle.virtualTabletRCValue(rightStick.xAxis, rightStick.yAxis,takepic.checked)
            }
        }
    }
    Column {
        spacing:    ScreenTools.defaultFontPixelHeight/2
        anchors.top:  parent.top
        anchors.topMargin: ScreenTools.defaultFontPixelHeight/2
        anchors.horizontalCenter: parent.horizontalCenter
     QGCLabel {
                text:               qsTr("RTMP URL:")
                width:              ScreenTools.defaultFontPixelHeight*5
            }
            QGCTextField {
                id:                 rtspField
                width:              ScreenTools.defaultFontPixelHeight*15
                text:               ""//QGroundControl.videoManager.rtspURL
                onEditingFinished: {
                  //  QGroundControl.videoManager.rtspURL = text
                }
            }

        Row{
            spacing:    ScreenTools.defaultFontPixelHeight/2
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("回中")
                checkable:     true
                primary:       true
            }
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("跟头")
                checkable:     true
                primary:       true
            }
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("锁头")
                checkable:     true
                primary:       true
            }
        }
        Row{
            spacing:    ScreenTools.defaultFontPixelHeight/2
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("变大")
                checkable:     true
                primary:       true
            }
            QGCButton {
                id:            takepic
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("变小")
                checkable:     true
                primary:       true
            }
        }
        Row{
            spacing:    ScreenTools.defaultFontPixelHeight/2
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("远焦")
                checkable:     true
                primary:       true
            }
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("近焦")
                checkable:     true
                primary:       true
            }
        }
        Row{
            spacing:    ScreenTools.defaultFontPixelHeight/2
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("自动对焦")
                checkable:     true
                primary:       true
            }
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("暂停对焦")
                checkable:     true
                primary:       true
            }
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("记忆对焦")
                checkable:     true
                primary:       true
            }
        }
        Row{
            spacing:    ScreenTools.defaultFontPixelHeight/2
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("录像")
                checkable:     true
                primary:       true
            }
            QGCButton {
                width:         ScreenTools.defaultFontPixelHeight*5
                height:        ScreenTools.defaultFontPixelHeight*2
                text:          qsTr("结束录像")
                checkable:     true
                primary:       true
            }
            SubMenuButton {
                imageResource:      "/qmlimages/camera.svg"
                text:               qsTr("拍照")//"Send to vehicle"
                checkable:          true
                onClicked:          _activeVehicle.triggerCamera()
                enabled:            _activeVehicle
            }
        }

        Row{
            spacing:    ScreenTools.defaultFontPixelHeight/2
            SubMenuButton {
                imageResource:      "/qmlimages/camera.svg"
                text:               qsTr("定时拍照")//"Send to vehicle"
                onClicked:           _activeVehicle.triggerCameraTime(Number(intertime.text))
                enabled:            _activeVehicle
            }
            QGCTextField {
                id:                 intertime
                width:              ScreenTools.defaultFontPixelHeight*5
                text:               "5"//QGroundControl.videoManager.rtspURL
            }
        }
        Row{
            spacing:    ScreenTools.defaultFontPixelHeight/2
            SubMenuButton {
                imageResource:      "/qmlimages/camera.svg"
                text:               qsTr("定距拍照")//"Send to vehicle"
                onClicked:           _activeVehicle.triggerCameraDist(Number(distance.text))
                enabled:            _activeVehicle
            }
            QGCTextField {
                id:                 distance
                width:              ScreenTools.defaultFontPixelHeight*5
                text:               "25"//QGroundControl.videoManager.rtspURL
            }
        }
        JoystickThumbPad {
            id:                     rightStick
            anchors.horizontalCenter: parent.horizontalCenter
            width:                  ScreenTools.defaultFontPixelHeight*12
            height:                 width
        }

    }
}// Rectangle
