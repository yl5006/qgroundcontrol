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
    anchors.top:    parent.top
    anchors.topMargin:  ScreenTools.toolbarHeight*1.8 + ScreenTools.defaultFontPixelWidth
    anchors.right:  parent.right
    anchors.rightMargin: ScreenTools.defaultFontPixelHeight+_rightPanelWidth
    width:          ScreenTools.defaultFontPixelHeight*18
    height:         ScreenTools.defaultFontPixelHeight*14
    visible:        false
    radius:         2
    color:          qgcPal.windowShade
    z:              QGroundControl.zOrderTopMost+100
    MouseArea {
        anchors.fill: parent
        onClicked: {
            forceActiveFocus()
        }
    }
    Rectangle {
        id:                         title
        anchors.top:                parent.top
        anchors.topMargin:          ScreenTools.defaultFontPixelHeight*1
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
            width:                  height
            sourceSize.width: width
            source:     "/qmlimages/circlepoint.svg"
            fillMode:   Image.PreserveAspectFit
            color:      qgcPal.text
            anchors.horizontalCenter:circle.horizontalCenter
            anchors.verticalCenter: circle.verticalCenter
        }
        QGCLabel {
            id:             idset
            anchors.left:   img.left
            anchors.leftMargin: ScreenTools.defaultFontPixelHeight*3
            text:           qsTr("圆形航线")//"safe"
            color:          qgcPal.text
            anchors.verticalCenter: img.verticalCenter
        }
        Image {
            source:    "/qmlimages/title.svg"
            width:      idset.width+ScreenTools.defaultFontPixelHeight*3.5
            height:     ScreenTools.defaultFontPixelHeight*1.5
            anchors.verticalCenter: circle.verticalCenter
            anchors.left:           circle.right
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
                    anchors.baseline:   radius.baseline
                    text:               qsTr("半径:")
                    width:              ScreenTools.defaultFontPixelHeight*4
                }
                QGCTextField {
                    id:                 radius
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
                    anchors.baseline:   number.baseline
                    text:               qsTr("航点个数:")
                    width:              ScreenTools.defaultFontPixelHeight*4
                }
                QGCTextField {
                    id:                 number
                    width:              ScreenTools.defaultFontPixelHeight*4
                    inputMethodHints:   Qt.ImhDigitsOnly
                    text:               "12"
                }
            }
            Row {
                spacing:    ScreenTools.defaultFontPixelHeight
                QGCLabel {
                    anchors.baseline:   startangle.baseline
                    text:               qsTr("起始点角度:")
                    width:              ScreenTools.defaultFontPixelHeight*4
                }
                QGCTextField {
                    id:                 startangle
                    width:              ScreenTools.defaultFontPixelHeight*4
                    inputMethodHints:   Qt.ImhDigitsOnly
                    text:               "0"
                }
                QGCLabel {
                    text:               qsTr("度")
                }
            }
            Row {
                spacing: ScreenTools.defaultFontPixelHeight*2
                anchors.horizontalCenter: parent.horizontalCenter
                ExclusiveGroup { id: modeGroup }

                QGCRadioButton {
                    id:             start
                    exclusiveGroup: modeGroup
                    text:           qsTr("顺时针")//"Mode 1"
                    checked:        true
                }

                QGCRadioButton {
                    exclusiveGroup: modeGroup
                    text:           qsTr("逆时针")//"Mode 2"
                }
            }
        }
        Column {
            spacing: ScreenTools.defaultFontPixelHeight/2
            anchors.verticalCenter: setitem.verticalCenter
            QGCButton {
                text:               qsTr("生成")
                onClicked: {
                    var coordinate =_currentMissionItem.coordinate
                    var sequenceNumber
                    for (var i=0; i<= Number(number.text); i++) {
                        if(start.checked)
                        {
                            sequenceNumber=missionController.insertSimpleMissionItem(coordinate.atDistanceAndAzimuth(Number(radius.text),(Number(startangle.text)+360/Number(number.text)*i)), _currentMissionItem.sequenceNumber+1+i)
                        }
                        else
                        {
                            sequenceNumber=missionController.insertSimpleMissionItem(coordinate.atDistanceAndAzimuth(Number(radius.text),(Number(startangle.text)-360/Number(number.text)*i)), _currentMissionItem.sequenceNumber+1+i)
                        }
                    }
                    setCurrentItem(sequenceNumber)
                    _root.visible=false
                }
            }
            QGCButton {
                text:               qsTr("一键8字")
                onClicked: {
                    var coordinate =_currentMissionItem.coordinate
                    var sequenceNumber
                    for (var i=0; i<= Number(number.text); i++) {
                        if(start.checked)
                        {
                            sequenceNumber=missionController.insertSimpleMissionItem(coordinate.atDistanceAndAzimuth(Number(radius.text),(Number(startangle.text)+360/Number(number.text)*i)), _currentMissionItem.sequenceNumber+1+i)
                        }
                        else
                        {
                            sequenceNumber=missionController.insertSimpleMissionItem(coordinate.atDistanceAndAzimuth(Number(radius.text),(Number(startangle.text)-360/Number(number.text)*i)), _currentMissionItem.sequenceNumber+1+i)
                        }
                    }
                    var nextcoordinate = coordinate.atDistanceAndAzimuth(2*Number(radius.text),(Number(startangle.text)))
                    for (var j=1; j<= Number(number.text); j++) {
                        if(start.checked)
                        {
                            sequenceNumber=missionController.insertSimpleMissionItem(nextcoordinate.atDistanceAndAzimuth(Number(radius.text),(Number(startangle.text)+180-360/Number(number.text)*j)), _currentMissionItem.sequenceNumber+i+j)
                        }
                        else
                        {
                            sequenceNumber=missionController.insertSimpleMissionItem(nextcoordinate.atDistanceAndAzimuth(Number(radius.text),(Number(startangle.text)+180+360/Number(number.text)*j)), _currentMissionItem.sequenceNumber+i+j)
                        }
                    }
                    setCurrentItem(sequenceNumber)
                    _root.visible=false
                }
            }
            QGCButton {
                text:               qsTr("取消")
                onClicked: {
                    _root.visible=false
                }
            }
        }
    }
}
