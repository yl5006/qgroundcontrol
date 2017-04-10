/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.ScreenTools   1.0
import QtGraphicalEffects 1.0
SetupPage {
    id:             motorPage
    pageComponent:  pageComponent

    readonly property int _barHeight:       10
    readonly property int _barWidth:        5
    readonly property int _sliderHeight:    25

    FactPanelController {
        id:             controller
        factPanel:      motorPage.viewPanel
    }

    Component {
        id: pageComponent

        Item{
            width:  availableWidth
            height: column.height+ScreenTools.defaultFontPixelHeight*6
            Rectangle {
                id:                         title
                anchors.top:                parent.top
                anchors.horizontalCenter:   parent.horizontalCenter
                width:                      parent.width
                height:                     ScreenTools.defaultFontPixelHeight*6
                color:                      "transparent"
                QGCCircleProgress{
                    id:                     circle
                    anchors.left:           parent.left
                    anchors.top:            parent.top
                    anchors.leftMargin:     ScreenTools.defaultFontPixelHeight*5
                    anchors.topMargin:      ScreenTools.defaultFontPixelHeight
                    width:                  ScreenTools.defaultFontPixelHeight*5
                    value:                  0
                }
                QGCColoredImage {
                    id:                     img
                    height:                 ScreenTools.defaultFontPixelHeight*2.5
                    width:                  height
                    sourceSize.width: width
                    source:     "/qmlimages/MotorComponentIcon.svg"
                    fillMode:   Image.PreserveAspectFit
                    color:      qgcPal.text
                    anchors.horizontalCenter:circle.horizontalCenter
                    anchors.verticalCenter: circle.verticalCenter
                }
                QGCLabel {
                    id:             idset
                    anchors.left:   img.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("电机测试")//"sensors"
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold:              true
                    color:          qgcPal.text
                    anchors.verticalCenter: img.verticalCenter
                }
                Image {
                    source:    "/qmlimages/title.svg"
                    width:      idset.width+ScreenTools.defaultFontPixelHeight*4
                    height:     ScreenTools.defaultFontPixelHeight*3
                    anchors.verticalCenter: circle.verticalCenter
                    anchors.left:          circle.right
                    //                fillMode: Image.PreserveAspectFit
                }
            }

            Column {
                id:column
                spacing: 10
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.top:             title.bottom

                QGCLabel {
                    color:  qgcPal.warningText
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold:     true
                    text:   qsTr("注意！请出除螺旋桨，然后按下安全开关口，拖动滚动条，点击电机测试")
                }

                Row {
                    id:         motorSliders
                    spacing:    ScreenTools.defaultFontPixelWidth * 10
                    height:     ScreenTools.defaultFontPixelHeight * _sliderHeight
                    Item{
                        height:                     width
                        width:                      parent.height
                        visible:                    false
                        Rectangle {
                            id:                souce
                            anchors.fill:      parent
                            color:             "red"
                            visible:           false
                        }

                        Image {
                            id:                         mask
                            anchors.fill:      parent
                            mipmap:                     true
                            fillMode:                   Image.PreserveAspectFit
                            source:                     "/qmlimages/motortestbg.svg"
                            visible:           false
                        }
                        OpacityMask {
                            anchors.fill: souce
                            source: souce
                            maskSource: mask
                        }
                    }



                    Column {
                        property alias motorSlider: slider
                        visible:                    false

                        GSSlider {
                            id:                         slider
                            orientation:                Qt.Vertical
                            height:                     ScreenTools.defaultFontPixelHeight * _sliderHeight
                            width:                      ScreenTools.defaultFontPixelHeight
                            maximumValue:               100
                            value:                      0

                        }

                    } // Column


                    MultiRotorMotorDisplay {
                        id:             disp
                      //  enabled:        slider.value!=0
                        anchors.top:    parent.top
                        anchors.bottom: parent.bottom
                        width:          height*0.8
                        motorCount:     controller.vehicle.motorCount
                        xConfig:        controller.vehicle.xConfigMotors
                        coaxial:        controller.vehicle.coaxialMotors
                        property int _motor: 0
                        onChecked: {
                            controller.vehicle.motorTest( i, 30, 1)
                            _motor=i
                            trig.running=true
                            disp.enabled=    false
                        }
                        Timer {
                            id:             trig
                            interval:       2000
                            running:        false
                            repeat:         false

                            onTriggered: {
                                controller.vehicle.motorTest(parent._motor, 0, 1)
                                disp.enabled=true
                            }
                        }

                    }
                } // Row
            } // Column
        } // Component
    } // SetupPahe
}
