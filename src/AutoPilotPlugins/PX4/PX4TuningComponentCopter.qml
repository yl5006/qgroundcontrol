/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick              2.5
import QtQuick.Controls     1.4

import QGroundControl.Controls  1.0

SetupPage {
    id:             tuningPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        FactSliderPanel {
            width:          availableWidth
            qgcViewPanel:   tuningPage.viewPanel

            sliderModel: ListModel {
                ListElement {
                    title:          qsTr("Hover Throttle")
                    description:    qsTr("Adjust throttle so hover is at mid-throttle. Slide to the left if hover is lower than throttle center. Slide to the right if hover is higher than throttle center.")
                    param:          "MPC_THR_HOVER"
                    min:            20
                    max:            80
                    step:           1
                }

                ListElement {
                    title:          qsTr("Manual minimum throttle")
                    description:    qsTr("Slide to the left to start the motors with less idle power. Slide to the right if descending in manual flight becomes unstable.")
                    param:          "MPC_MANTHR_MIN"
                    min:            0
                    max:            15
                    step:           1
                }

                ListElement {
            title:          qsTr("横滚控制感度")//"Roll sensitivity"
            description:    qsTr("向左滑动，控制更快，更准确。滑动到右侧，如果振荡或太颠簸")//"Slide to the left to make roll control faster and more accurate. Slide to the right if roll oscillates or is too twitchy."
                    param:          "MC_ROLL_TC"
                    min:            0.15
                    max:            0.25
                    step:           0.01
                }

                ListElement {
            title:          qsTr("仰俯控制感度")//"Pitch sensitivity"
            description:    qsTr("向左滑动，控制更快，更准确。滑动到右侧，如果振荡或太颠簸")//"Slide to the left to make pitch control faster and more accurate. Slide to the right if pitch oscillates or is too twitchy."
                    param:          "MC_PITCH_TC"
                    min:            0.15
                    max:            0.25
                    step:           0.01
                }

                ListElement {
            title:          qsTr("高度控制感度")//"Altitude control sensitivity"
            description:    qsTr("向左滑动，以使高度控制更顺畅，减少颠簸。向右滑动，以使高度控制更准确，更灵敏")//"Slide to the left to make altitude control smoother and less twitchy. Slide to the right to make altitude control more accurate and more aggressive."
                    param:          "MPC_Z_FF"
                    min:            0
                    max:            1.0
                    step:           0.1
                }

                ListElement {
            title:          qsTr("位移控制感度")//"Position control sensitivity"
            description:    qsTr("向左滑动，以使在位置控制模式顺畅，减少颠簸的飞行。向右滑动，使位置控制更准确，更灵敏")//"Slide to the left to make flight in position control mode smoother and less twitchy. Slide to the right to make position control more accurate and more aggressive."
                    param:          "MPC_XY_FF"
                    min:            0
                    max:            1.0
                    step:           0.1
                }
            }
        }
    } // Component
} // SetupPage
