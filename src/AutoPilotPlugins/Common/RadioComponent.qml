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
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Palette       1.0

SetupPage {
    id:             radioPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  availableWidth
            height: Math.max(leftColumn.height, rightColumn.height)+ScreenTools.defaultFontPixelHeight*8

            readonly property string    dialogTitle:            qsTr("遥控")//"Radio"
            readonly property real      labelToMonitorMargin:   defaultTextWidth * 3

            property bool controllerCompleted:      false
            property bool controllerAndViewReady:   false

            Component.onCompleted: {
                if (controllerCompleted) {
                    controllerAndViewReady = true
                    controller.start()
                    updateChannelCount()
                }
            }

            function updateChannelCount()
            {
            }

            QGCPalette { id: qgcPal; colorGroupEnabled: radioPage.enabled }

            RadioComponentController {
                id:             controller
                factPanel:      radioPage.viewPanel
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
                onFunctionMappingChangedAPMReboot:  showMessage(qsTr("Reboot required"), qsTr("Your stick mappings have changed, you must reboot the vehicle for correct operation."), StandardButton.Ok)
                onThrottleReversedCalFailure:       showMessage(qsTr("Throttle channel reversed"), qsTr("Calibration failed. The throttle channel on your transmitter is reversed. You must correct this on your transmitter in order to complete calibration."), StandardButton.Ok)
            }

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
                    message: qsTr("校准前回中所有控制杆\n\n%1").arg(
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
                            //                        text:       qsTr("Click Ok to place your Spektrum receiver in the bind mode. Select the specific receiver type below:")
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
                    property color          __barColor:         qgcPal.button

                    readonly property int _pwmMin:      800
                    readonly property int _pwmMax:      2200
                    readonly property int _pwmRange:    _pwmMax - _pwmMin

                    // Bar
                    Rectangle {
                        id:                     bar
                        //       anchors.horizontalCenter: parent.horizontalCenter
                        anchors.fill:           parent
                        color:                  __barColor
                    }
                    // Indicator
                    Rectangle {
                        anchors.bottom:         parent.bottom
                        anchors.horizontalCenter:  parent.horizontalCenter
                        width:                  parent.width
                        height:                 (((reversed ? _pwmMax - rcValue : rcValue - _pwmMin) / _pwmRange) * parent.height) //- (height / 2)
                        //         radius:                 width / 2
                        color:                  qgcPal.primaryButton
                        visible:                mapped
                        //                   (((reversed ? _pwmMax - rcValue : rcValue - _pwmMin) / _pwmRange) * parent.height) - (height / 2)
                    }

                    QGCLabel {
                        anchors.fill:           parent
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        text:                   qsTr("未配置")//"Not Mapped"
                        visible:                !mapped
                    }

                    //                    ColorAnimation {
                    //                        id:         barAnimation
                    //                        target:     bar
                    //                        property:   "color"
                    //                        from:       "yellow"
                    //                        to:         __barColor
                    //                        duration:   1500
                    //                    }
                }
            } // Component - channelMonitorDisplayComponent
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
                    source:     "/qmlimages/RC.svg"
                    fillMode:   Image.PreserveAspectFit
                    color:      qgcPal.text
                    anchors.horizontalCenter:circle.horizontalCenter
                    anchors.verticalCenter: circle.verticalCenter
                }
                Image {
                    source:    "/qmlimages/title.svg"
                    width:      idset.width+ScreenTools.defaultFontPixelHeight*4
                    height:     ScreenTools.defaultFontPixelHeight*3
                    anchors.verticalCenter: circle.verticalCenter
                    anchors.left:          circle.right
                    //                fillMode: Image.PreserveAspectFit
                }
                QGCLabel {
                    id:             idset
                    anchors.left:   img.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("遥控")//"sensors"
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold:              true
                    color:          qgcPal.text
                    anchors.verticalCenter: img.verticalCenter
                }

            }
            //            // Left side column
            //            Column {
            //                id:             leftColumn
            //                anchors.top:    title.bottom
            //                anchors.left:   parent.left
            //                anchors.right:  columnSpacer.left
            //                spacing:        10

            //                // Attitude Controls
            //                Column {
            //                    width:      parent.width
            //                    spacing:    5
            //       //             QGCLabel { text: "Attitude Controls" }
            //                    QGCLabel { text: qsTr("姿态控制")
            //                           anchors.horizontalCenter: parent.horizontalCenter}
            //                    Item {
            //                        width:  parent.width
            //                        height: defaultTextHeight * 2
            //                        QGCLabel {
            //                            id:     rollLabel
            //                            width:  defaultTextWidth * 10
            //                            text:   qsTr("横滚")//"Roll"
            //                        }

            //                        Loader {
            //                            id:                 rollLoader
            //                            anchors.left:       rollLabel.right
            //                            anchors.right:      parent.right
            //                            height:             radioPage.defaultTextHeight
            //                            width:              100
            //                            sourceComponent:    channelMonitorDisplayComponent

            //                            property real defaultTextWidth: radioPage.defaultTextWidth
            //                            property bool mapped:           controller.rollChannelMapped
            //                            property bool reversed:         controller.rollChannelReversed
            //                        }

            //                        Connections {
            //                            target: controller

            //                            onRollChannelRCValueChanged: rollLoader.item.rcValue = rcValue
            //                        }
            //                    }

            //                    Item {
            //                        width:  parent.width
            //                        height: defaultTextHeight * 2

            //                        QGCLabel {
            //                            id:     pitchLabel
            //                            width:  defaultTextWidth * 10
            //                           text:   qsTr("仰俯")//"Pitch"
            //                        }

            //                        Loader {
            //                            id:                 pitchLoader
            //                            anchors.left:       pitchLabel.right
            //                            anchors.right:      parent.right
            //                            height:             radioPage.defaultTextHeight
            //                            width:              100
            //                            sourceComponent:    channelMonitorDisplayComponent

            //                            property real defaultTextWidth: radioPage.defaultTextWidth
            //                            property bool mapped:           controller.pitchChannelMapped
            //                            property bool reversed:         controller.pitchChannelReversed
            //                        }

            //                        Connections {
            //                            target: controller

            //                            onPitchChannelRCValueChanged: pitchLoader.item.rcValue = rcValue
            //                        }
            //                    }

            //                    Item {
            //                        width:  parent.width
            //                        height: defaultTextHeight * 2

            //                        QGCLabel {
            //                            id:     yawLabel
            //                            width:  defaultTextWidth * 10
            //                            text:   qsTr("航向")//"Yaw"
            //                        }

            //                        Loader {
            //                            id:                 yawLoader
            //                            anchors.left:       yawLabel.right
            //                            anchors.right:      parent.right
            //                            height:             radioPage.defaultTextHeight
            //                            width:              100
            //                            sourceComponent:    channelMonitorDisplayComponent

            //                            property real defaultTextWidth: radioPage.defaultTextWidth
            //                            property bool mapped:           controller.yawChannelMapped
            //                            property bool reversed:         controller.yawChannelReversed
            //                        }

            //                        Connections {
            //                            target: controller

            //                            onYawChannelRCValueChanged: yawLoader.item.rcValue = rcValue
            //                        }
            //                    }

            //                    Item {
            //                        width:  parent.width
            //                        height: defaultTextHeight * 2

            //                        QGCLabel {
            //                            id:     throttleLabel
            //                            width:  defaultTextWidth * 10
            //                            text:   qsTr("油门")//"Throttle"
            //                        }

            //                        Loader {
            //                            id:                 throttleLoader
            //                            anchors.left:       throttleLabel.right
            //                            anchors.right:      parent.right
            //                            height:             radioPage.defaultTextHeight
            //                            width:              100
            //                            sourceComponent:    channelMonitorDisplayComponent

            //                            property real defaultTextWidth: radioPage.defaultTextWidth
            //                            property bool mapped:           controller.throttleChannelMapped
            //                            property bool reversed:         controller.throttleChannelReversed
            //                        }

            //                        Connections {
            //                            target: controller

            //                            onThrottleChannelRCValueChanged: throttleLoader.item.rcValue = rcValue
            //                        }
            //                    }
            //                } // Column - Attitude Control labels

            // Left side column
            Column {
                id:                 leftColumn
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                anchors.top:        title.bottom
                anchors.left:       parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                anchors.right:      columnSpacer.left
                spacing:            ScreenTools.defaultFontPixelHeight
                QGCLabel {
                    text: qsTr("姿态控制")
                    font.pointSize:     ScreenTools.defaultFontPixelHeight*1.1
                    font.family:        ScreenTools.demiboldFontFamily
                    font.bold:          true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                // Attitude Controls
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    Column {
                        width:  ScreenTools.defaultFontPixelWidth * 20
                        spacing:      ScreenTools.defaultFontPixelHeight
                        QGCLabel {
                            id:     rollLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:   qsTr("横滚")//"Roll"
                        }

                        Loader {
                            id:                 rollLoader
                            height:             ScreenTools.defaultFontPixelHeight*16
                            width:              radioPage.defaultTextHeight*1.5
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: radioPage.defaultTextWidth
                            property bool mapped:           controller.rollChannelMapped
                            property bool reversed:         controller.rollChannelReversed
                        }

                        FactComboBox {
                            width:      ScreenTools.defaultFontPixelWidth * 15
                            anchors.horizontalCenter: parent.horizontalCenter
                            fact:       controller.getParameterFact(-1, "RC_MAP_ROLL")
                            indexModel: false
                        }

                        Connections {
                            target: controller

                            onRollChannelRCValueChanged: rollLoader.item.rcValue = rcValue
                        }
                    }

                    Column {
                        width:  ScreenTools.defaultFontPixelWidth * 20
                        height: parent.height
                        spacing:      ScreenTools.defaultFontPixelHeight
                        QGCLabel {
                            id:     pitchLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:   qsTr("仰俯")//"Pitch"
                        }

                        Loader {
                            id:                 pitchLoader
                            height:             ScreenTools.defaultFontPixelHeight*16
                            width:              radioPage.defaultTextHeight*1.5
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: radioPage.defaultTextWidth
                            property bool mapped:           controller.pitchChannelMapped
                            property bool reversed:         controller.pitchChannelReversed
                        }

                        FactComboBox {
                            width:      ScreenTools.defaultFontPixelWidth * 15
                            anchors.horizontalCenter: parent.horizontalCenter
                            fact:       controller.getParameterFact(-1, "RC_MAP_PITCH")
                            indexModel: false
                        }

                        Connections {
                            target: controller

                            onPitchChannelRCValueChanged: pitchLoader.item.rcValue = rcValue
                        }
                    }

                    Column {
                        width:  ScreenTools.defaultFontPixelWidth * 20
                        height: parent.height
                        spacing:      ScreenTools.defaultFontPixelHeight
                        QGCLabel {
                            id:     yawLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:   qsTr("航向")//"Yaw"
                        }

                        Loader {
                            id:                 yawLoader
                            anchors.horizontalCenter: parent.horizontalCenter
                            height:             ScreenTools.defaultFontPixelHeight*16
                            width:              radioPage.defaultTextHeight*1.5
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: radioPage.defaultTextWidth
                            property bool mapped:           controller.yawChannelMapped
                            property bool reversed:         controller.yawChannelReversed
                        }

                        FactComboBox {
                            width:      ScreenTools.defaultFontPixelWidth * 15
                            anchors.horizontalCenter: parent.horizontalCenter
                            fact:       controller.getParameterFact(-1, "RC_MAP_YAW")
                            indexModel: false
                        }

                        Connections {
                            target: controller

                            onYawChannelRCValueChanged: yawLoader.item.rcValue = rcValue
                        }
                    }

                    Column {
                        width:  ScreenTools.defaultFontPixelWidth * 20
                        height: parent.height
                        spacing:      ScreenTools.defaultFontPixelHeight
                        QGCLabel {
                            id:     throttleLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:   qsTr("油门")//"Throttle"
                        }

                        Loader {
                            id:                 throttleLoader
                            anchors.horizontalCenter: parent.horizontalCenter
                            height:             ScreenTools.defaultFontPixelHeight*16
                            width:              radioPage.defaultTextHeight*1.5
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: radioPage.defaultTextWidth
                            property bool mapped:           controller.throttleChannelMapped
                            property bool reversed:         controller.throttleChannelReversed
                        }

                        FactComboBox {
                            width:      ScreenTools.defaultFontPixelWidth * 15
                            anchors.horizontalCenter: parent.horizontalCenter
                            fact:       controller.getParameterFact(-1, "RC_MAP_THROTTLE")
                            indexModel: false
                        }

                        Connections {
                            target: controller

                            onThrottleChannelRCValueChanged: throttleLoader.item.rcValue = rcValue
                        }
                    }
                    // Command Buttons
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: ScreenTools.defaultFontPixelHeight*2
                        SubMenuButton {
                            id:         nextButton
                            //primary:    true
                            imageResource:"/res/radiocalibration.svg"
                            text:       qsTr("校准")//"Calibrate"
                            width:      ScreenTools.defaultFontPixelHeight*6
                            onClicked: {
                                if (text == qsTr("校准")) {//qsTr("Calibrate")
                                    showDialog(zeroTrimsDialogComponent, dialogTitle, radioPage.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                                } else {
                                    controller.nextButtonClicked()
                                }
                            }
                        }
                        SubMenuButton {
                            id:         skipButton
                            imageResource:"/res/radioskip.svg"
                            text:       qsTr("跳过")//"Skip"
                            width:      ScreenTools.defaultFontPixelHeight*6
                            onClicked: controller.skipButtonClicked()
                        }

                        SubMenuButton {
                            id:         cancelButton
                            imageResource:"/qmlimages/cal_cancel.svg"
                            text:       qsTr("取消")//"Cancel"
                            width:      ScreenTools.defaultFontPixelHeight*6
                            onClicked: controller.cancelButtonClicked()
                        }


                    } // Column - Buttons
                } // Column - Attitude Control labels
                //                // Command Buttons
                //                Column {
                //                    spacing: 10

                //                    QGCButton {
                //                        id:         skipButton
                //                        text:       qsTr("跳过")//"Skip"

                //                        onClicked: controller.skipButtonClicked()
                //                    }

                //                    QGCButton {
                //                        id:         cancelButton
                //                        text:       qsTr("取消")//"Cancel"

                //                        onClicked: controller.cancelButtonClicked()
                //                    }

                //                    QGCButton {
                //                        id:         nextButton
                //                        primary:    true
                //                        text:       "Calibrate"

                //                        onClicked: {
                //                            if (text == qsTr("校准")) {//qsTr("Calibrate")
                //                                showDialog(zeroTrimsDialogComponent, dialogTitle, radioPage.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                //                            } else {
                //                                controller.nextButtonClicked()
                //                            }
                //                        }
                //                    }
                //                } // Column - Buttons

                // Status Text
                QGCLabel {
                    id:         statusText
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                }
                Rectangle {
                    width:          parent.width
                    height:         1
                    border.color:   qgcPal.text
                    border.width:   1
                }
                //  QGCLabel { text: qsTr("更多遥控设置 working") }

                //               QGCLabel { text: "Additional Radio setup:" }
                Row{
                    spacing: ScreenTools.defaultFontPixelHeight*2
                    visible:  true
                    QGCButton {
                        id:         bindButton
                        text:       qsTr("Spektrum Bind")
                        visible:   false
                        onClicked: showDialog(spektrumBindDialogComponent, dialogTitle, radioPage.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                    }

                    QGCButton {
                        text:       qsTr("拷贝中立点")//qsTr("Copy Trims")
                        visible:    QGroundControl.multiVehicleManager.activeVehicle.px4Firmware
                        onClicked:  showDialog(copyTrimsDialogComponent, dialogTitle, radioPage.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                    }
                }
                Row{
                    spacing: ScreenTools.defaultFontPixelHeight*0.3
                    visible: QGroundControl.multiVehicleManager.activeVehicle.px4Firmware
                    Repeater {
                        model: QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ? [ "TRIM_PITCH", "TRIM_ROLL", "TRIM_YAW"] : 0

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth
                            property Fact fact: controller.getParameterFact(-1, modelData)

                            QGCLabel {
                                anchors.baseline:   optCombo.baseline
                                text:               fact.shortDescription + ":"
                            }
                            FactTextField {
                                id:                 optCombo
                                showUnits:          true
                                fact:               parent.fact
                                width:              ScreenTools.defaultFontPixelWidth * 15
                                //      textColor:          parent.fact.defaultValueAvailable ? (parent.fact.valueEqualsDefault ? qgcPal.text : qgcPal.buttonHighlight) : qgcPal.text
                            }
                        }
                    } // Repeater
                }
                Column{
                    spacing: ScreenTools.defaultFontPixelHeight*0.3
                    Repeater {
                        model: QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ?
                                   (QGroundControl.multiVehicleManager.activeVehicle.multiRotor ?
                                        [ "RC_MAP_GEAR_SW","RC_MAP_AUX1", "RC_MAP_AUX2"/*, "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3"*/] :
                                        [ "RC_MAP_FLAPS", "RC_MAP_AUX1", "RC_MAP_AUX2","RC_MAP_AUX3"/*, "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3"*/]) :
                                   0

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth
                            property Fact fact: controller.getParameterFact(-1, modelData)

                            QGCLabel {
                                anchors.baseline:   optCombo1.baseline
                                text:               fact.shortDescription + ":"
                            }

                            FactComboBox {
                                id:         optCombo1
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       parent.fact
                                indexModel: false
                            }
                        }
                    } // Repeater
                }
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
                anchors.rightMargin: radioPage.defaultTextWidth * 5
                anchors.topMargin: radioPage.defaultTextWidth * 10
                width:          Math.min(radioPage.defaultTextWidth * 80, availableWidth * 0.5)
                spacing:        ScreenTools.defaultFontPixelHeight / 2

                Image {
                    width:      parent.width
                    fillMode:   Image.PreserveAspectFit
                    smooth:     true
                    source:     controller.imageHelp

                    Column {
                        spacing: ScreenTools.defaultFontPixelWidth*2
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
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
                }


                RCChannelMonitor {
                    width: parent.width
                }
            } // Column - Right Column
        } // Item
    } // Component - pageComponent
} // SetupPage
