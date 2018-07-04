/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick              2.3
import QtQuick.Controls     1.2

import QGroundControl.Controls  1.0
import QGroundControl.ScreenTools   1.0

SetupPage {
    id:             tuningPage
    pageComponent:  pageComponent
    Component {
        id: pageComponent

        Item {
            width:  availableWidth
            height: sliderpanel.height+ScreenTools.defaultFontPixelHeight*8
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
                    source:     "/qmlimages/TuningComponentIcon.svg"
                    fillMode:   Image.PreserveAspectFit
                    color:      qgcPal.text
                    anchors.horizontalCenter:circle.horizontalCenter
                    anchors.verticalCenter: circle.verticalCenter
                }
                QGCLabel {
                    id:             idset
                    anchors.left:   img.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("感度")//"safe"
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
            FactSliderPanel {
                id:                         sliderpanel
                anchors.top:                title.bottom
                anchors.topMargin:          ScreenTools.defaultFontPixelHeight
                anchors.horizontalCenter:   parent.horizontalCenter
                width:                      availableWidth*0.8
                qgcViewPanel:   tuningPage.viewPanel

                sliderModel: ListModel {

                    ListElement {
                        title:          qsTr("固定翼仰俯控制感度")//qsTr("Plane Pitch sensitivity")
//                        description:    qsTr("Slide to the left to make pitch control faster and more accurate. Slide to the right if pitch oscillates or is too twitchy.")
                        descriptionleft:    qsTr("向左滑动: 控制更快，更准确")
                        descriptionright:   qsTr("向右滑动: 如果振荡或太颠簸")
                        param:          "FW_P_TC"
                        min:            0.2
                        max:            0.8
                        step:           0.01
                    }

                    ListElement {
                        title:          qsTr("固定翼巡航油门")//qsTr("Plane Cruise throttle")
//                        description:    qsTr("This is the throttle setting required to achieve the desired cruise speed. Most planes need 50-60%.")
                        descriptionleft:    qsTr("达到所需的巡航速度所需的油门")
                        descriptionright:   qsTr("大多数飞机需要50％-60％")
                        param:          "FW_THR_CRUISE"
                        min:            20
                        max:            80
                        step:           1
                    }

//                    ListElement {
//                        title:          qsTr("Hover Throttle")
//                        description:    qsTr("Adjust throttle so hover is at mid-throttle. Slide to the left if hover is lower than throttle center. Slide to the right if hover is higher than throttle center.")
//                        param:          "MPC_THR_HOVER"
//                        min:            20
//                        max:            80
//                        step:           1
//                    }

//                    ListElement {
//                    title:          qsTr("Hoever manual minimum throttle")
//                        description:    qsTr("Slide to the left to start the motors with less idle power. Slide to the right if descending in manual flight becomes unstable.")
//                        param:          "MPC_MANTHR_MIN"
//                        min:            0
//                        max:            15
//                        step:           1
//                    }

                    ListElement {
                        title:          qsTr("固定翼任务模式感度")//qsTr("Plane Mission mode sensitivity")
//                      description:    qsTr("Slide to the left to make position control more accurate and more aggressive. Slide to the right to make flight in mission mode smoother and less twitchy.")
                        descriptionleft:    qsTr("向左滑动: 使位置控制更准确，更灵敏")
                        descriptionright:   qsTr("向右滑动: 使任务模式更平滑，减少颠簸")
                        param:          "FW_L1_PERIOD"
                        min:            12
                        max:            50
                        step:           0.5
                    }
                }
            }
        }
    }
}
