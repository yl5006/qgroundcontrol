﻿/*=====================================================================

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

import QtQuick          2.5
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

QGCView {
    id:         qgcView
    viewPanel:  panel

    QGCPalette { id: qgcPal; colorGroupEnabled: panel.enabled }

    readonly property string    dialogTitle:            qsTr("遥控")//"Radio"
    readonly property real      labelToMonitorMargin:   defaultTextWidth * 3

    property bool controllerCompleted:      false
    property bool controllerAndViewReady:   false

    function updateChannelCount()
    {
/*
            FIXME: Turned off for now, since it prevents binding. Need to restructure to
            allow binding and still check channel count
            if (controller.channelCount < controller.minChannelCount) {
                showDialog(channelCountDialogComponent, dialogTitle, qgcView.showDialogDefaultWidth, 0)
            } else {
                hideDialog()
            }
*/
    }

    RadioComponentController {
        id:             controller
        factPanel:      panel
        statusText:     statusText
        cancelButton:   cancelButton
        nextButton:     nextButton
        skipButton:     skipButton

        Component.onCompleted: {
            controllerCompleted = true
            if (qgcView.completedSignalled) {
                controllerAndViewReady = true
                controller.start()
                updateChannelCount()
            }
        }

        onChannelCountChanged:              updateChannelCount()
        onFunctionMappingChangedAPMReboot:    showMessage(qsTr("Reboot required"), qsTr("Your stick mappings have changed, you must reboot the vehicle for correct operation."), StandardButton.Ok)
    }

    onCompleted: {
        if (controllerCompleted) {
            controllerAndViewReady = true
            controller.start()
            updateChannelCount()
        }
    }

    QGCViewPanel {
        id:             panel
        anchors.fill:   parent

        Component {
            id: copyTrimsDialogComponent

            QGCViewMessage {
//              message: qsTr("Center your sticks and move throttle all the way down, then press Ok to copy trims. After pressing Ok, reset the trims on your radio back to zero.")
                message: qsTr("使摇杆回到中位，油门到最低，然后按OK。复位你的遥控回零。")

                function accept() {
                    hideDialog()
                    controller.copyTrims()
                }
            }
        }

        Component {
            id: zeroTrimsDialogComponent

            QGCViewMessage {
                message: qsTr("Before calibrating you should zero all your trims and subtrims. Click Ok to start Calibration.\n\n%1").arg(
                         (QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ? "" : qsTr("Please ensure all motor power is disconnected AND all props are removed from the vehicle.")))

                function accept() {
                    hideDialog()
                    controller.nextButtonClicked()
                }
            }
        }

        Component {
            id: channelCountDialogComponent

            QGCViewMessage {
                message: controller.channelCount == 0 ? qsTr("请打开传输，至少") /*qsTr("Please turn on transmitter.")*/ : qsTr("%1 channels or more are needed to fly.").arg(controller.minChannelCount)
            }
        }

        Component {
            id: spektrumBindDialogComponent

            QGCViewDialog {

                function accept() {
                    controller.spektrumBindMode(radioGroup.current.bindMode)
                    hideDialog()
                }

                function reject() {
                    hideDialog()
                }

                Column {
                    anchors.fill:   parent
                    spacing:        5

                    QGCLabel {
                        width:      parent.width
                        wrapMode:   Text.WordWrap
                        text:       qsTr("Click Ok to place your Spektrum receiver in the bind mode. Select the specific receiver type below:")
                        text:       qsTr("点击OK使接收机在绑定模式，选择具体接收器类型")
                    }

                    ExclusiveGroup { id: radioGroup }

                    QGCRadioButton {
                        exclusiveGroup: radioGroup
                        text:           qsTr("DSM2 模式")//"DSM2 Mode"

                        property int bindMode: RadioComponentController.DSM2
                    }

                    QGCRadioButton {
                        exclusiveGroup: radioGroup
                        text:           qsTr("DSMX 至少7通道")//"DSMX (7 channels or less)"

                        property int bindMode: RadioComponentController.DSMX7
                    }

                    QGCRadioButton {
                        exclusiveGroup: radioGroup
                        checked:        true
                        text:           "DSMX (8 channels or more)"

                        property int bindMode: RadioComponentController.DSMX8
                    }
                }
            }
        } // Component - spektrumBindDialogComponent

        // Live channel monitor control component
        Component {
            id: channelMonitorDisplayComponent

            Item {
                property int    rcValue:    1500


                property int            __lastRcValue:      1500
                readonly property int   __rcValueMaxJitter: 2
                property color          __barColor:         qgcPal.windowShade

                // Bar
                Rectangle {
                    id:                     bar
                    anchors.verticalCenter: parent.verticalCenter
                    width:                  parent.width
                    height:                 parent.height / 2
                    color:                  __barColor
                }

                // Center point
                Rectangle {
                    anchors.horizontalCenter:   parent.horizontalCenter
                    width:                      defaultTextWidth / 2
                    height:                     parent.height
                    color:                      qgcPal.window
                }

                // Indicator
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width:                  parent.height * 0.75
                    height:                 width
                    x:                      ((Math.abs((rcValue - 1000) - (reversed ? 1000 : 0)) / 1000) * parent.width) - (width / 2)
                    radius:                 width / 2
                    color:                  qgcPal.text
                    visible:                mapped
                }

                QGCLabel {
                    anchors.fill:           parent
                    horizontalAlignment:    Text.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    text:                   qsTr("未配置")//"Not Mapped"
                    visible:                !mapped
                }

                ColorAnimation {
                    id:         barAnimation
                    target:     bar
                    property:   "color"
                    from:       "yellow"
                    to:         __barColor
                    duration:   1500
                }

                /*
                // FIXME: Bar animation is turned off for now to figure out better usbaility
                onRcValueChanged: {
                    if (Math.abs(rcValue - __lastRcValue) > __rcValueMaxJitter) {
                        __lastRcValue = rcValue
                        barAnimation.restart()
                    }
                }

                // rcValue debugger
                QGCLabel {
                    anchors.fill: parent
                    text: rcValue
                }
                */
            }
        } // Component - channelMonitorDisplayComponent

        // Main view Qml starts here

        QGCFlickable {
            anchors.fill:   parent
            contentHeight:  Math.max(leftColumn.height, rightColumn.height)
            clip:           true

            // Left side column
            Column {
                id:             leftColumn
                anchors.left:   parent.left
                anchors.right:  columnSpacer.left
                spacing:        10

                // Attitude Controls
                Column {
                    width:      parent.width
                    spacing:    5
       //             QGCLabel { text: "Attitude Controls" }
                    QGCLabel { text: qsTr("姿态控制")
                           anchors.horizontalCenter: parent.horizontalCenter}
                    Item {
                        width:  parent.width
                        height: defaultTextHeight * 2
                        QGCLabel {
                            id:     rollLabel
                            width:  defaultTextWidth * 10
                            text:   qsTr("横滚")//"Roll"
                        }

                        Loader {
                            id:                 rollLoader
                            anchors.left:       rollLabel.right
                            anchors.right:      parent.right
                            height:             qgcView.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: qgcView.defaultTextWidth
                            property bool mapped:           controller.rollChannelMapped
                            property bool reversed:         controller.rollChannelReversed
                        }

                        Connections {
                            target: controller

                            onRollChannelRCValueChanged: rollLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: defaultTextHeight * 2

                        QGCLabel {
                            id:     pitchLabel
                            width:  defaultTextWidth * 10
                           text:   qsTr("仰俯")//"Pitch"
                        }

                        Loader {
                            id:                 pitchLoader
                            anchors.left:       pitchLabel.right
                            anchors.right:      parent.right
                            height:             qgcView.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: qgcView.defaultTextWidth
                            property bool mapped:           controller.pitchChannelMapped
                            property bool reversed:         controller.pitchChannelReversed
                        }

                        Connections {
                            target: controller

                            onPitchChannelRCValueChanged: pitchLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: defaultTextHeight * 2

                        QGCLabel {
                            id:     yawLabel
                            width:  defaultTextWidth * 10
                            text:   qsTr("航向")//"Yaw"
                        }

                        Loader {
                            id:                 yawLoader
                            anchors.left:       yawLabel.right
                            anchors.right:      parent.right
                            height:             qgcView.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: qgcView.defaultTextWidth
                            property bool mapped:           controller.yawChannelMapped
                            property bool reversed:         controller.yawChannelReversed
                        }

                        Connections {
                            target: controller

                            onYawChannelRCValueChanged: yawLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: defaultTextHeight * 2

                        QGCLabel {
                            id:     throttleLabel
                            width:  defaultTextWidth * 10
                            text:   qsTr("油门")//"Throttle"
                        }

                        Loader {
                            id:                 throttleLoader
                            anchors.left:       throttleLabel.right
                            anchors.right:      parent.right
                            height:             qgcView.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: qgcView.defaultTextWidth
                            property bool mapped:           controller.throttleChannelMapped
                            property bool reversed:         controller.throttleChannelReversed
                        }

                        Connections {
                            target: controller

                            onThrottleChannelRCValueChanged: throttleLoader.item.rcValue = rcValue
                        }
                    }
                } // Column - Attitude Control labels

                // Command Buttons
                Row {
                    spacing: 10

                    QGCButton {
                        id:         skipButton
                        text:       qsTr("跳过")//"Skip"

                        onClicked: controller.skipButtonClicked()
                    }

                    QGCButton {
                        id:         cancelButton
                       text:       qsTr("取消")//"Cancel"

                        onClicked: controller.cancelButtonClicked()
                    }

                    QGCButton {
                        id:         nextButton
                        primary:    true
                        text:       "Calibrate"

                        onClicked: {
                        if (text == qsTr("校准")) {//qsTr("Calibrate")
                            showDialog(zeroTrimsDialogComponent, dialogTitle, qgcView.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                            } else {
                                controller.nextButtonClicked()
                            }
                        }
                    }
                } // Row - Buttons

                // Status Text
                QGCLabel {
                    id:         statusText
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                }

                Item {
                    width: 10
                    height: defaultTextHeight * 4
                }

                Rectangle {
                    width:          parent.width
                    height:         1
                    border.color:   qgcPal.text
                    border.width:   1
                }

                QGCLabel { text: "Additional Radio setup:" }
            QGCLabel { text: qsTr("更多遥控设置") }

                Row {
                    spacing: 10

                    QGCLabel {
                        anchors.baseline:   bindButton.baseline
                        text:               "Place Spektrum satellite receiver in bind mode:"
                    }

                    QGCButton {
                        id:         bindButton
                        text:       qsTr("Spektrum Bind")

                        onClicked: showDialog(spektrumBindDialogComponent, dialogTitle, qgcView.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                    }
                }

                QGCButton {
                    text:       qsTr("Copy Trims")
                    visible:    QGroundControl.multiVehicleManager.activeVehicle.px4Firmware
                    onClicked:  showDialog(copyTrimsDialogComponent, dialogTitle, qgcView.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                }

                Repeater {
                    model: QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ? [ "RC_MAP_FLAPS", "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_AUX3" ] : 0

                    Row {
                        spacing: ScreenTools.defaultFontPixelWidth
                        property Fact fact: controller.getParameterFact(-1, modelData)

                        QGCLabel {
                            anchors.baseline:   optCombo.baseline
                            text:               fact.shortDescription + ":"
                        }

                        FactComboBox {
                            id:         optCombo
                            width:      ScreenTools.defaultFontPixelWidth * 15
                            fact:       parent.fact
                            indexModel: false
                        }
                    }
                } // Repeater
            } // Column - Left Column

            Item {
                id:             columnSpacer
                anchors.right:  rightColumn.left
                width:          20
            }

            // Right side column
            Column {
                id:             rightColumn
                anchors.top:    parent.top
                anchors.right:  parent.right
                width:          defaultTextWidth * 35
                spacing:        10

                Row {
                    spacing: 10
                    ExclusiveGroup { id: modeGroup }
                    QGCRadioButton {
                        exclusiveGroup: modeGroup
                        text:           qsTr("模式 1")//"Mode 1"
                        checked:        controller.transmitterMode == 1

                        onClicked: controller.transmitterMode = 1
                    }

                    QGCRadioButton {
                        exclusiveGroup: modeGroup
                        text:           qsTr("模式 2")//"Mode 2"
                        checked:        controller.transmitterMode == 2

                        onClicked: controller.transmitterMode = 2
                    }
                }

                Image {
                    width:      parent.width
                    height:     defaultTextHeight * 15
                    fillMode:   Image.PreserveAspectFit
                    smooth:     true
                    source:     controller.imageHelp
                }

                RCChannelMonitor {
                    width:      parent.width
                }
            } // Column - Right Column
        } // QGCFlickable
    } // QGCViewPanel
}
