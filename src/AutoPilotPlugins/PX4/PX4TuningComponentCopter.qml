/*=====================================================================

 QGroundControl Open Source Ground Control Station

 (c) 2009 - 2015 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>

 This file is part of the QGROUNDCONTROL project

 QGROUNDCONTROL is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 QGROUNDCONTROL is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with QGROUNDCONTROL. If not, see <http://www.gnu.org/licenses/>.

 ======================================================================*/

import QtQuick              2.5
import QtQuick.Controls     1.4

import QGroundControl.Controls  1.0

FactSliderPanel {
    anchors.fill:   parent
    panelTitle:     "Tuning"

    sliderModel: ListModel {
        ListElement {
            title:          qsTr("Throttle Hover")
            description:    qsTr("Adjust throttle so hover is at mid-throttle. Slide to the left if hover is lower than throttle center. Slide to the right if hover is higher than throttle center.")
            param:          "MPC_THR_HOVER"
            min:            0.2
            max:            0.8
            step:           0.01
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

        ListElement {
            title:          qsTr("手动最小油门")//"Manual minimum throttle"
            description:    qsTr("滑到左边开始用更少的闲置功耗电机。滑动到右侧，如果在手动飞行不稳定")//"Slide to the left to start the motors with less idle power. Slide to the right if descending in manual flight becomes unstable."
            param:          "MPC_MANTHR_MIN"
            min:            0
            max:            0.15
            step:           0.01
        }
    }
}
