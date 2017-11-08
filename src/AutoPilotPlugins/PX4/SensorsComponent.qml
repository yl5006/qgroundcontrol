/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick 2.3

import QGroundControl.Controls  1.0
import QGroundControl.PX4       1.0

SetupPage {
    id:             sensorsPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  availableWidth
            height: availableHeight

            // Help text which is shown both in the status text area prior to pressing a cal button and in the
            // pre-calibration dialog.

            readonly property string boardRotationText: qsTr("飞控安装方向如何和机头一直，则选择NONE.")//qsTr("If the orientation is in the direction of flight, select ROTATION_NONE.")
            readonly property string compassRotationText: qsTr("磁罗盘安装方向如何和机头一直，则选择NONE.")//qsTr("If the orientation is in the direction of flight, select ROTATION_NONE.")

            readonly property string compassHelp:   qsTr("For Compass calibration you will need to rotate your vehicle through a number of positions.")
            readonly property string gyroHelp:      qsTr("For Gyroscope calibration you will need to place your vehicle on a surface and leave it still.")
            readonly property string accelHelp:     qsTr("For Accelerometer calibration you will need to place your vehicle on all six sides on a perfectly level surface and hold it still in each orientation for a few seconds.")
            readonly property string levelHelp:     qsTr("水平校准校准机体飞行平面.")//qsTr("To level the horizon you need to place the vehicle in its level flight position and press OK.")
            readonly property string airspeedHelp:  qsTr("空速校准先在无风下校准.然后对传感器吹气或风")//qsTr("For Airspeed calibration you will need to keep your airspeed sensor out of any wind and then blow across the sensor.")

            readonly property string statusTextAreaDefaultText: qsTr("选择传感器开始校准")/*qsTr("Start the individual calibration steps by clicking one of the buttons to the left.")*/

            // Used to pass what type of calibration is being performed to the preCalibrationDialog
            property string preCalibrationDialogType

            // Used to pass help text to the preCalibrationDialog dialog
            property string preCalibrationDialogHelp

            readonly property int rotationColumnWidth: ScreenTools.defaultFontPixelWidth * 30

            property var calmagsides: [
                "34",
                "63",
                "38",
        ]


            readonly property var rotations: [
                qsTr("旋转_NONE"),
                qsTr("旋转_YAW_45"),
                qsTr("旋转_YAW_90"),
                qsTr("旋转_YAW_135"),
                qsTr("旋转_YAW_180"),
                qsTr("旋转_YAW_225"),
                qsTr("旋转_YAW_270"),
                qsTr("旋转_YAW_315"),
                qsTr("旋转_ROLL_180"),
                qsTr("旋转_ROLL_180_YAW_45"),
                qsTr("旋转_ROLL_180_YAW_90"),
                qsTr("旋转_ROLL_180_YAW_135"),
                qsTr("旋转_PITCH_180"),
                qsTr("旋转_ROLL_180_YAW_225"),
                qsTr("旋转_ROLL_180_YAW_270"),
                qsTr("旋转_ROLL_180_YAW_315"),
                qsTr("旋转_ROLL_90"),
                qsTr("旋转_ROLL_90_YAW_45"),
                qsTr("旋转_ROLL_90_YAW_90"),
                qsTr("旋转_ROLL_90_YAW_135"),
                qsTr("旋转_ROLL_270"),
                qsTr("旋转_ROLL_270_YAW_45"),
                qsTr("旋转_ROLL_270_YAW_90"),
                qsTr("旋转_ROLL_270_YAW_135"),
                qsTr("旋转_PITCH_90"),
                qsTr("旋转_PITCH_270"),
                qsTr("旋转_ROLL_270_YAW_270"),
                qsTr("旋转_ROLL_180_PITCH_270"),
                qsTr("旋转_PITCH_90_YAW_180"),
                qsTr("旋转_ROLL_90_PITCH_90")
            ]

            property Fact cal_mag0_id:      controller.getParameterFact(-1, "CAL_MAG0_ID")
            property Fact cal_mag1_id:      controller.getParameterFact(-1, "CAL_MAG1_ID")
            property Fact cal_mag2_id:      controller.getParameterFact(-1, "CAL_MAG2_ID")
            property Fact cal_mag0_rot:     controller.getParameterFact(-1, "CAL_MAG0_ROT")
            property Fact cal_mag1_rot:     controller.getParameterFact(-1, "CAL_MAG1_ROT")
            property Fact cal_mag2_rot:     controller.getParameterFact(-1, "CAL_MAG2_ROT")

            property Fact cal_mag_sides:     controller.getParameterFact(-1, "CAL_MAG_SIDES")

            property Fact cal_gyro0_id:     controller.getParameterFact(-1, "CAL_GYRO0_ID")
            property Fact cal_acc0_id:      controller.getParameterFact(-1, "CAL_ACC0_ID")

            property Fact sens_board_rot:   controller.getParameterFact(-1, "SENS_BOARD_ROT")
            property Fact sens_board_x_off: controller.getParameterFact(-1, "SENS_BOARD_X_OFF")
            property Fact sens_board_y_off: controller.getParameterFact(-1, "SENS_BOARD_Y_OFF")
            property Fact sens_board_z_off: controller.getParameterFact(-1, "SENS_BOARD_Z_OFF")
            property Fact sens_dpres_off:   controller.getParameterFact(-1, "SENS_DPRES_OFF")

            // Id > = signals compass available, rot < 0 signals internal compass
            property bool showCompass0Rot: cal_mag0_id.value > 0 && cal_mag0_rot.value >= 0
            property bool showCompass1Rot: cal_mag1_id.value > 0 && cal_mag1_rot.value >= 0
            property bool showCompass2Rot: cal_mag2_id.value > 0 && cal_mag2_rot.value >= 0

            property bool   _sensorsHaveFixedOrientation:   QGroundControl.corePlugin.options.sensorsHaveFixedOrientation
            property bool   _wifiReliableForCalibration:    QGroundControl.corePlugin.options.wifiReliableForCalibration
            property int    _buttonWidth:                   ScreenTools.defaultFontPixelWidth * 15

            property bool calmagtime: false
            SensorsComponentController {
                id:                         controller
                factPanel:                  sensorsPage.viewPanel
                statusLog:                  statusTextArea
                progressBar:                pro//progressBar
                compassButton:              compassButton
                gyroButton:                 gyroButton
                accelButton:                accelButton
                airspeedButton:             airspeedButton
                levelButton:                levelButton
                cancelButton:               cancelButton
                setOrientationsButton:      setOrientationsButton
                orientationCalAreaHelpText: orientationCalAreaHelpText

                onResetStatusTextArea: statusLog.text = statusTextAreaDefaultText

                onSetCompassRotations: {
                    if (!_sensorsHaveFixedOrientation && (showCompass0Rot || showCompass1Rot || showCompass2Rot)) {
                        setOrientationsDialogShowBoardOrientation = false
                        showDialog(setOrientationsDialogComponent, qsTr("设置磁罗盘安装反向"), sensorsPage.showDialogDefaultWidth, StandardButton.Ok)
                    }
                }

                onWaitingForCancelChanged: {
                    if (controller.waitingForCancel) {
                        showMessage(qsTr("校准取消")/*qsTr("Calibration Cancel")*/, qsTr("等待大概几秒，机体响应取消校准")/*qsTr("Waiting for Vehicle to response to Cancel. This may take a few seconds.")*/, 0)
                    } else {
                        hideDialog()
                    }
                }

            }

            Component.onCompleted: {
                var usingUDP = controller.usingUDPLink()
                if (usingUDP && !_wifiReliableForCalibration) {
                    showMessage(qsTr("传感器校准"), "Performing sensor calibration over a WiFi connection is known to be unreliable. You should disconnect and perform calibration using a direct USB connection instead.", StandardButton.Ok)
                }
            }

            Component {
                id: preCalibrationDialogComponent

                QGCViewDialog {
                    id: preCalibrationDialog

                    function accept() {
                        if (preCalibrationDialogType == "gyro") {
                            controller.calibrateGyro()
                        } else if (preCalibrationDialogType == "accel") {
                            controller.calibrateAccel()
                        } else if (preCalibrationDialogType == "level") {
                            controller.calibrateLevel()
                        } else if (preCalibrationDialogType == "compass") {
                            controller.calibrateCompass()
                        } else if (preCalibrationDialogType == "airspeed") {
                            controller.calibrateAirspeed()
                        }
                        preCalibrationDialog.hideDialog()
                    }

                    Column {
                        anchors.fill:   parent
                        spacing:        ScreenTools.defaultFontPixelWidth / 2

                        QGCLabel {
                            width:      parent.width
                            wrapMode:   Text.WordWrap
                            text:       preCalibrationDialogHelp
                        }

                        Column {
                            spacing:        5
                            visible:        !_sensorsHaveFixedOrientation

                            QGCLabel {
                                id:         boardRotationHelp
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                visible:    (preCalibrationDialogType != "airspeed") && (preCalibrationDialogType != "gyro")
                                text:       boardRotationText
                            }

                            Column {
                                visible:    boardRotationHelp.visible
                            	spacing:        ScreenTools.defaultFontPixelHeight
                                QGCLabel {
                                    text: qsTr("飞控安装方向:")
                                }

                                FactComboBox {
                                    id:     boardRotationCombo
                                    width:  rotationColumnWidth;
                                    model:  rotations
                                    fact:   sens_board_rot
                                }
                            }
                        }
                    }
                }
            }

            property bool setOrientationsDialogShowBoardOrientation: true

            Component {
                id: setOrientationsDialogComponent

                QGCViewDialog {
                    id: setOrientationsDialog
                    height:    ScreenTools.defaultFontPixelHeight*15
                    QGCFlickable {
                        anchors.fill:   parent
                        contentHeight:  columnLayout.height
                        clip:           true

                        Column {
                            id:                 columnLayout
                            anchors.margins:    ScreenTools.defaultFontPixelWidth
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            anchors.top:        parent.top
                            spacing:            ScreenTools.defaultFontPixelHeight

                            QGCLabel {
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                text:       boardRotationText
                            }

                            Column {
                                visible: setOrientationsDialogShowBoardOrientation
                                spacing:        ScreenTools.defaultFontPixelHeight
                                QGCLabel {
                                    text: qsTr("飞控安装方向:")//Autopilot Orientation
                                }

                                FactComboBox {
                                    id:     boardRotationCombo
                                    width:  rotationColumnWidth;
                                    model:  rotations
                                    fact:   sens_board_rot
                                }
                            }

                            Column {
                                // Compass 0 rotation
                                Component {
                                    id: compass0ComponentLabel2

                                    QGCLabel {
                                        text: qsTr("外部磁罗盘安装方向:")//qsTr("External Compass Orientation:")
                                    }
                                }

                                Component {
                                    id: compass0ComponentCombo2

                                    FactComboBox {
                                        id:     compass0RotationCombo
                                        width:  rotationColumnWidth
                                        model:  rotations
                                        fact:   cal_mag0_rot
                                    }
                                }

                                Loader { sourceComponent: showCompass0Rot ? compass0ComponentLabel2 : null }
                                Loader { sourceComponent: showCompass0Rot ? compass0ComponentCombo2 : null }
                            }

                            Column {
                                // Compass 1 rotation
                                Component {
                                    id: compass1ComponentLabel2

                                    QGCLabel {
                                        text: qsTr("外部磁罗盘1安装方向:")//qsTr("External Compass 1 Orientation:")
                                    }
                                }

                                Component {
                                    id: compass1ComponentCombo2

                                    FactComboBox {
                                        id:     compass1RotationCombo
                                        width:  rotationColumnWidth
                                        model:  rotations
                                        fact:   cal_mag1_rot
                                    }
                                }

                                Loader { sourceComponent: showCompass1Rot ? compass1ComponentLabel2 : null }
                                Loader { sourceComponent: showCompass1Rot ? compass1ComponentCombo2 : null }
                            }

                            Column {
                                spacing: ScreenTools.defaultFontPixelWidth

                                // Compass 2 rotation
                                Component {
                                    id: compass2ComponentLabel2

                                    QGCLabel {
                                        text: qsTr("磁罗盘2安装方向:")//qsTr("Compass 2 Orientation")
                                    }
                                }

                                Component {
                                    id: compass2ComponentCombo2

                                    FactComboBox {
                                        id:     compass1RotationCombo
                                        width:  rotationColumnWidth
                                        model:  rotations
                                        fact:   cal_mag2_rot
                                    }
                                }
                                Loader { sourceComponent: showCompass2Rot ? compass2ComponentLabel2 : null }
                                Loader { sourceComponent: showCompass2Rot ? compass2ComponentCombo2 : null }
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - setOrientationsDialogComponent
            Rectangle {
                id:                         title
                anchors.top:                parent.top
                anchors.horizontalCenter:   parent.horizontalCenter
                width:                      parent.width
                height:                     ScreenTools.defaultFontPixelHeight*6
                color:                      "transparent"
                QGCCircleProgress{
                    id:                     setcircle
                    anchors.left:           parent.left
                    anchors.top:            parent.top
                    anchors.leftMargin:     ScreenTools.defaultFontPixelHeight*5
                    anchors.topMargin:      ScreenTools.defaultFontPixelHeight
                    width:                  ScreenTools.defaultFontPixelHeight*5
                    value:                  0
                }
                QGCColoredImage {
                    id:                     setimg
                    height:                 ScreenTools.defaultFontPixelHeight*2.5
                    width:                  height
                    sourceSize.width: width
                    source:     "/qmlimages/SensorsComponentIcon.svg"
                    fillMode:   Image.PreserveAspectFit
                    color:      qgcPal.text
                    anchors.horizontalCenter:setcircle.horizontalCenter
                    anchors.verticalCenter: setcircle.verticalCenter
                }
                Image {
                    source:    "/qmlimages/title.svg"
                    width:      idset.width+ScreenTools.defaultFontPixelHeight*4
                    height:     ScreenTools.defaultFontPixelHeight*3
                    anchors.verticalCenter: setcircle.verticalCenter
                    anchors.left:          setcircle.right
                    //                fillMode: Image.PreserveAspectFit
                }
		                QGCLabel {
                    id:             idset
                    anchors.left:   setimg.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("传感器")//"sensors"
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold:              true
                    color:          qgcPal.text
                    anchors.verticalCenter: setimg.verticalCenter
                }
            }
            Row {
                id:         buttonColumn
                anchors.top: title.bottom
                spacing:    ScreenTools.defaultFontPixelHeight / 2
                anchors.horizontalCenter:  parent.horizontalCenter
                readonly property int buttonWidth: parent.width * 0.1
                ExclusiveGroup { id: calGroup }
                QGCButton {
                    id:             compassButton
                    width:          parent.buttonWidth
                    height:         ScreenTools.defaultFontPixelWidth * 5
                    exclusiveGroup: calGroup
                    checkable:          true
                    text:           qsTr("磁罗盘")//qsTr("Compass")
                    primary:        true
                    bordercolor:    cal_mag0_id.value !== 0?qgcPal.primaryButton:"red"
		    visible:        QGroundControl.corePlugin.options.showSensorCalibrationCompass
                    _showBorder:    true
                    onClicked: {
                         calmagtime=true
                         magcal.visible=true//  controller.calibrateCompass()
                        //    preCalibrationDialogType = "compass"
                        //    preCalibrationDialogHelp = compassHelp
                        //   showDialog(preCalibrationDialogComponent, qsTr("Calibrate Compass"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                    }
                }
                QGCButton {
                    id:             accelButton
                    width:          parent.buttonWidth
                    height:         ScreenTools.defaultFontPixelWidth * 5
                    exclusiveGroup: calGroup
                    checkable:          true
                    text:           qsTr("加速度")//qsTr("Accelerometer")
                    primary:        true
                    bordercolor:    cal_acc0_id.value !== 0 ? qgcPal.primaryButton:"red"
                    visible:        QGroundControl.corePlugin.options.showSensorCalibrationGyro
                    _showBorder:    true
                    onClicked: {
                        calmagtime=false
                        controller.calibrateAccel()
                        //    preCalibrationDialogType = "accel"
                        //    preCalibrationDialogHelp = accelHelp
                        //    showDialog(preCalibrationDialogComponent, qsTr("Calibrate Accelerometer"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                    }
                }

                QGCButton {
                    id:             gyroButton
                    width:          parent.buttonWidth
                    height:         ScreenTools.defaultFontPixelWidth * 5
                    exclusiveGroup: calGroup
                    checkable:          true
                    text:           qsTr("角速度")//qsTr("Gyroscope")
                    primary:        true
                    bordercolor:    (cal_gyro0_id.value !== 0) ? qgcPal.primaryButton:"red"
                    visible:        QGroundControl.corePlugin.options.showSensorCalibrationAccel
                    _showBorder:    true
                    onClicked: {                           
                        controller.calibrateGyro()
                        //    preCalibrationDialogType = "gyro"
                        //    preCalibrationDialogHelp = gyroHelp
                        //  showDialog(preCalibrationDialogComponent, qsTr("Calibrate Gyro"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                    }
                }

                QGCButton {
                    id:             levelButton
                    width:          parent.buttonWidth
                    height:         ScreenTools.defaultFontPixelWidth * 5
                    exclusiveGroup: calGroup
                    checkable:          true
                    text:           qsTr("水平")//qsTr("Level Horizon")
                    primary:        true
                    bordercolor:    (sens_board_x_off.value != 0 || sens_board_y_off != 0 | sens_board_z_off != 0)?qgcPal.primaryButton:"red"
                    _showBorder:    true
                    enabled:        cal_acc0_id.value !== 0 && cal_gyro0_id.value != 0
                    visible:        QGroundControl.corePlugin.options.showSensorCalibrationLevel

                    onClicked: {
                        controller.calibrateLevel()
                        //    preCalibrationDialogType = "level"
                        //    preCalibrationDialogHelp = levelHelp
                        //    showDialog(preCalibrationDialogComponent, qsTr("Level Horizon"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                    }
                }

                QGCButton {
                    id:             airspeedButton
                    width:          parent.buttonWidth
                    height:         ScreenTools.defaultFontPixelWidth * 5
                    text:           qsTr("空速计")//qsTr("Airspeed")
                    checkable:      true
                    primary:        true
                    visible:        (controller.vehicle.fixedWing || controller.vehicle.vtol) && controller.getParameterFact(-1, "CBRK_AIRSPD_CHK").value != 162128 && QGroundControl.corePlugin.options.showSensorCalibrationAirspeed
                    bordercolor:    (sens_dpres_off.value !== 0)?qgcPal.primaryButton:"red"
                    _showBorder:    true
                    onClicked: {
                        controller.calibrateAirspeed()
                        //     preCalibrationDialogType = "airspeed"
                        //     preCalibrationDialogHelp = airspeedHelp
                        //      showDialog(preCalibrationDialogComponent, qsTr("Calibrate Airspeed"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                    }
                }

                //                QGCButton {
                //                    id:         cancelButton
                //                    width:      parent.buttonWidth
                //                    text:       qsTr("取消")//qsTr("Cancel")
                //                    primary:        true
                //                    enabled:    false
                //                    onClicked:  controller.cancelCalibration()
                //                }

                QGCButton {
                    id:         setOrientationsButton
                    width:      parent.buttonWidth
                    height:         ScreenTools.defaultFontPixelWidth * 5
                    text:       qsTr("安装方向")//qsTr("Set Orientations")
                    visible:    !_sensorsHaveFixedOrientation
                    primary:        true
                    onClicked:  {
                        setOrientationsDialogShowBoardOrientation = true
                        showDialog(setOrientationsDialogComponent, qsTr("设置安装方向")/*qsTr("Set Orientations")*/, sensorsPage.showDialogDefaultWidth, StandardButton.Ok)
                    }
                }
            } // Column - Buttons

            Column {
                id:                 calColumn
                width:              parent.width*0.8
                anchors.top:        buttonColumn.bottom
                anchors.topMargin:  ScreenTools.defaultFontPixelWidth / 2
                anchors.horizontalCenter:  parent.horizontalCenter

                Item { height: ScreenTools.defaultFontPixelHeight; width: 10 } // spacer

                Item {
                    property int calDisplayAreaWidth: parent.width

                    width:  parent.width
                    height: parent.height - y

                    TextArea {
                        id:             statusTextArea
                        width:          parent.calDisplayAreaWidth
                        height:         parent.height
                        readOnly:       true
                        frameVisible:   false
                        text:           statusTextAreaDefaultText
                        horizontalAlignment:    Text.AlignHCenter
                        style: TextAreaStyle {
                            textColor: qgcPal.text
                            backgroundColor: qgcPal.windowShade
                        }
                    }

                    Rectangle {
                        id:         orientationCalArea
                        width:      parent.calDisplayAreaWidth
                        height:     parent.height
                        visible:    controller.showOrientationCalArea
                        color:    "#1e2328"//#bdbdbd  qgcPal._windowShadeDark

                        QGCLabel {
                            id:                 orientationCalAreaHelpText
                            anchors.margins:    ScreenTools.defaultFontPixelWidth
                            anchors.top:        orientationCalArea.top
                            anchors.left:       orientationCalArea.left
                            horizontalAlignment:    Text.AlignHCenter
                            width:              parent.width*0.8
                            wrapMode:           Text.WordWrap
                            font.pointSize:     ScreenTools.mediumFontPointSize
                        }
                        ImageButton {
                            id:         cancelButton
                            anchors.right: parent.right
                            anchors.verticalCenter: orientationCalAreaHelpText.verticalCenter
                            width:       ScreenTools.defaultFontPixelWidth * 5
                            height:      ScreenTools.defaultFontPixelWidth * 5
                            imageResource:"/qmlimages/cal_cancel.svg"
                            // text:       qsTr("取消")//qsTr("Cancel")
                            //  enabled:    false
                            onClicked:  controller.cancelCalibration()
                        }
                        Flow {
                            id:                 flow
                            anchors.topMargin:  ScreenTools.defaultFontPixelWidth
                            anchors.top:        orientationCalAreaHelpText.bottom
                            anchors.bottom:     parent.bottom
                            anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 20
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            spacing:            ScreenTools.defaultFontPixelWidth / 2
                            //       anchors.horizontalCenter:  parent.horizontalCenter
                            property real indicatorWidth:   (width / 3) - (spacing * 2)
                            property real indicatorHeight:  (height / 2) - spacing

                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalDownSideVisible
                                calValid:           controller.orientationCalDownSideDone
                                calInProgress:      controller.orientationCalDownSideInProgress
                                rotate:             calmagtime ? 5 :1
                                calInProgressText:  controller.orientationCalDownSideRotate ? qsTr("旋转"):qsTr("保持静止")/*qsTr("Rotate") : qsTr("Hold Still")*/
                                imageSource:        controller.orientationCalDownSideRotate ? "qrc:///qmlimages/VehicleDownRotate.png" : "qrc:///qmlimages/VehicleDown.png"
                                Rectangle {
                                    id:       pro
                                    property real value : 0
                                    anchors.bottom:    parent.bottom
                                    anchors.left:      parent.left
                                    anchors.margins:   parent.width*0.05
                                    visible:!controller.orientationCalUpsideDownSideVisible&&! controller.orientationCalNoseDownSideVisible&& !controller.orientationCalTailDownSideVisible
                                    height: parent.height/6
                                    width:  value*parent.width*0.9
                                    color:  Qt.rgba(0.102,0.887,0.609,0.6)
                                }
                            }

                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalUpsideDownSideVisible
                                calValid:           controller.orientationCalUpsideDownSideDone
                                calInProgress:      controller.orientationCalUpsideDownSideInProgress
                                rotate:             calmagtime ? 5: 1
                                calInProgressText:  controller.orientationCalUpsideDownSideRotate ? qsTr("旋转"):qsTr("保持静止")//qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalUpsideDownSideRotate ? "qrc:///qmlimages/VehicleUpsideDownRotate.png" : "qrc:///qmlimages/VehicleUpsideDown.png"
                            }
                            VehicleRotationCal {
                                width:             parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalNoseDownSideVisible
                                calValid:           controller.orientationCalNoseDownSideDone
                                calInProgress:      controller.orientationCalNoseDownSideInProgress
                                rotate:             calmagtime ? 5 : 1
                                calInProgressText:  controller.orientationCalNoseDownSideRotate ? qsTr("旋转"):qsTr("保持静止")//qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalNoseDownSideRotate ? "qrc:///qmlimages/VehicleNoseDownRotate.png" : "qrc:///qmlimages/VehicleNoseDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalTailDownSideVisible
                                calValid:           controller.orientationCalTailDownSideDone
                                calInProgress:      controller.orientationCalTailDownSideInProgress
                                rotate:             calmagtime ? 5 : 1
                                calInProgressText:  controller.orientationCalTailDownSideRotate ? qsTr("旋转"):qsTr("保持静止")//qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalTailDownSideRotate ? "qrc:///qmlimages/VehicleTailDownRotate.png" : "qrc:///qmlimages/VehicleTailDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalLeftSideVisible
                                calValid:           controller.orientationCalLeftSideDone
                                calInProgress:      controller.orientationCalLeftSideInProgress
                                rotate:             calmagtime ? 5 : 1
                                calInProgressText:  controller.orientationCalLeftSideRotate ? qsTr("旋转"):qsTr("保持静止")//qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalLeftSideRotate ? "qrc:///qmlimages/VehicleLeftRotate.png" : "qrc:///qmlimages/VehicleLeft.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalRightSideVisible
                                calValid:           controller.orientationCalRightSideDone
                                calInProgress:      controller.orientationCalRightSideInProgress
                                rotate:             calmagtime ? 5 : 1
                                calInProgressText:  controller.orientationCalRightSideRotate ? qsTr("旋转"):qsTr("保持静止")//qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalRightSideRotate ? "qrc:///qmlimages/VehicleRightRotate.png" : "qrc:///qmlimages/VehicleRight.png"
                            }
                        }
                    }
                }
            }//Column

            Column{
                id:                     magcal
                anchors.topMargin:  ScreenTools.defaultFontPixelWidth*5
                anchors.top:        calColumn.top
                anchors.right:      calColumn.left
                anchors.rightMargin:  -ScreenTools.defaultFontPixelWidth*10
                spacing:            ScreenTools.defaultFontPixelWidth *5
                visible:            false
                QGCButton {
                    width:      ScreenTools.defaultFontPixelWidth * 15
                    height:         ScreenTools.defaultFontPixelWidth * 5
                    text:       qsTr("6面校准")//qsTr("Set Orientations")
                    primary:        true
                    onClicked:  {
                        cal_mag_sides.value=calmagsides[1]
                        cal_mag_sides.valueChanged(cal_mag_sides.value)
                        magcal.visible=false
                        controller.calibrateCompass()
                    }
                }
                QGCButton {
                    width:      ScreenTools.defaultFontPixelWidth * 15
                    height:         ScreenTools.defaultFontPixelWidth * 5
                    text:       qsTr("3面校准")//qsTr("Set Orientations")
                    primary:        true
                    onClicked:  {
                        cal_mag_sides.value=calmagsides[2]
                        cal_mag_sides.valueChanged(cal_mag_sides.value)
                        magcal.visible=false
                        controller.calibrateCompass()
                    }
                }
                QGCButton {
                    width:      ScreenTools.defaultFontPixelWidth * 15
                    height:     ScreenTools.defaultFontPixelWidth * 5
                    text:       qsTr("2面校准")//qsTr("Set Orientations")
                    primary:        true
                    onClicked:  {
                        cal_mag_sides.value=calmagsides[0]
                        cal_mag_sides.valueChanged(cal_mag_sides.value)
                        magcal.visible=false
                        controller.calibrateCompass()

                    }
                }
            }
        } // Row
    } // Component
} // SetupPage

