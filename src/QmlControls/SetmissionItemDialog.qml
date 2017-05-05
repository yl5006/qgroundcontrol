import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2

import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl               1.0

/// Mission item Set control
Rectangle {
    id:             _root
    width:          ScreenTools.defaultFontPixelHeight*18
    height:         ScreenTools.defaultFontPixelHeight*12
    visible:        false
    radius:         2
    color:          qgcPal.windowShade

    MouseArea {
        anchors.fill: parent
        onClicked: {
            forceActiveFocus()
        }
    }
    Rectangle {
        id:                         title
        anchors.top:                parent.top
        anchors.topMargin:          ScreenTools.defaultFontPixelHeight
        anchors.horizontalCenter:   parent.horizontalCenter
        width:                      parent.width
        height:                     ScreenTools.defaultFontPixelHeight*4
        color:                      "transparent"
        QGCCircleProgress{
            id:                     circle
            anchors.left:           parent.left
            anchors.top:            parent.top
            anchors.leftMargin:     ScreenTools.defaultFontPixelHeight*2
            width:                  ScreenTools.defaultFontPixelHeight*3
            value:                  0
        }
        QGCColoredImage {
            id:                     img
            height:                 ScreenTools.defaultFontPixelHeight*1.5
            width:                  ScreenTools.defaultFontPixelHeight*1.5
            sourceSize.width:       width
            source:     "/qmlimages/nextwaypoint.svg"
            fillMode:   Image.PreserveAspectFit
            color:      qgcPal.text
            anchors.horizontalCenter:circle.horizontalCenter
            anchors.verticalCenter: circle.verticalCenter
        }
        QGCLabel {
            id:             idset
            anchors.left:   img.left
            anchors.leftMargin: ScreenTools.defaultFontPixelHeight*3
            text:           qsTr("相对航点生成")//"safe"
            color:          qgcPal.text
            anchors.verticalCenter: img.verticalCenter
        }
        Image {
            source:    "/qmlimages/title.svg"
            width:      idset.width+ScreenTools.defaultFontPixelHeight*3.5
            height:     ScreenTools.defaultFontPixelHeight*1.5
            anchors.verticalCenter: circle.verticalCenter
            anchors.left:          circle.right
            //                fillMode: Image.PreserveAspectFit
        }
    }
    Row{
        anchors.top:                title.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        spacing:        ScreenTools.defaultFontPixelHeight*2
        Column {
            id:             setitem
            spacing:        ScreenTools.defaultFontPixelHeight/2
            Row {
                spacing:    ScreenTools.defaultFontPixelHeight
                QGCLabel {
                    anchors.baseline:   distance.baseline
                    text:               qsTr("距离:")
                    width:              ScreenTools.defaultFontPixelHeight*4
                }
                QGCTextField {
                    id:                 distance
                    width:              ScreenTools.defaultFontPixelHeight*4
                    inputMethodHints:   Qt.ImhDigitsOnly
                    text:               "100"
                }
                QGCLabel {
                    text:               qsTr("m")
                }
            }
            Row {
                spacing:    ScreenTools.defaultFontPixelHeight
                QGCLabel {
                    anchors.baseline:   angle.baseline
                    text:               qsTr("偏移角度:")
                    width:              ScreenTools.defaultFontPixelHeight*4
                }
                QGCTextField {
                    id:                 angle
                    width:              ScreenTools.defaultFontPixelHeight*4
                    inputMethodHints:   Qt.ImhDigitsOnly
                    text:               "90"
                }
                QGCLabel {
                    text:               qsTr("度")
                }
            }
            Row {
                spacing:    ScreenTools.defaultFontPixelHeight
                visible:    false
                QGCLabel {
                    anchors.baseline:   height.baseline
                    text:               qsTr("高度差:")
                    width:              ScreenTools.defaultFontPixelHeight*5
                }
                QGCTextField {
                    id:                 height
                    width:              ScreenTools.defaultFontPixelHeight*5
                    inputMethodHints:   Qt.ImhDigitsOnly
                    text:               "0"
                }
                QGCLabel {
                    text:               qsTr("m")
                }
            }
        }
        Column {
            spacing: ScreenTools.defaultFontPixelHeight*2
            anchors.verticalCenter: setitem.verticalCenter
        QGCButton {
            text:               qsTr("添加")
//            Layout.fillWidth:   true
            onClicked: {
                var coordinate =_currentMissionItem.coordinate
                var sequenceNumber = _missionController.insertSimpleMissionItem(coordinate.atDistanceAndAzimuth(Number(distance.text),Number(angle.text)), _currentMissionItem.sequenceNumber+1,false)
                setCurrentItem(sequenceNumber)
            }
        }
        QGCButton {
            text:               qsTr("取消")
//            Layout.fillWidth:   true

            onClicked: {
                _root.visible=false
                }
            }
        }

    }
}
