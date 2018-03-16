/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Layouts          1.2
import QtGraphicalEffects       1.0

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0


SetupPage {
    id:             safetyPage
    pageComponent:  pageComponent
    Component {
        id: pageComponent

        Item {
            width:  Math.max(availableWidth, mainCol.width)
            height: mainCol.height+ScreenTools.defaultFontPixelHeight*8

            FactPanelController {
                id:         controller
                factPanel:  safetyPage.viewPanel
            }

            property real _margins:         ScreenTools.defaultFontPixelHeight
            property real _editFieldWidth:  ScreenTools.defaultFontPixelWidth * 20
            property real _imageWidth:      ScreenTools.defaultFontPixelWidth * 15
            property real _imageHeight:     ScreenTools.defaultFontPixelHeight * 3

            property Fact _fenceAction:     controller.getParameterFact(-1, "GF_ACTION")
            property Fact _fenceRadius:     controller.getParameterFact(-1, "GF_MAX_HOR_DIST")
            property Fact _fenceAlt:        controller.getParameterFact(-1, "GF_MAX_VER_DIST")
            property Fact _rtlLandDelay:    controller.getParameterFact(-1, "RTL_LAND_DELAY")
            property Fact _lowBattAction:   controller.getParameterFact(-1, "COM_LOW_BAT_ACT")
            property Fact _rcLossAction:    controller.getParameterFact(-1, "NAV_RCL_ACT")
            property Fact _dlLossAction:    controller.getParameterFact(-1, "NAV_DLL_ACT")
            property Fact _disarmLandDelay: controller.getParameterFact(-1, "COM_DISARM_LAND")
            property Fact _landSpeedMC:     controller.getParameterFact(-1, "MPC_LAND_SPEED", false)
            property Fact _hitlEnabled:     controller.getParameterFact(-1, "SYS_HITL", false)

            property Fact _disAction:       controller.getParameterFact(-1, "MPC_SAFE_EN", false)
            property bool _showIcons: !ScreenTools.isTinyScreen

            ExclusiveGroup { id: homeLoiterGroup }
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
                    source:     "/qmlimages/SafetyComponentIcon.svg"
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
                    text:           qsTr("安全")//"safe"
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold:              true
                    color:          qgcPal.text
                    anchors.verticalCenter: img.verticalCenter
                }               
            }
            Flow {
                id:                                     mainCol
                anchors.top:                             title.bottom
                anchors.topMargin:                      ScreenTools.defaultFontPixelHeight
                spacing:                                _margins
                anchors.horizontalCenter:               parent.horizontalCenter
                width:                                  parent.width*0.8
                /*
                   **** safe distance****
                */
                Rectangle {
                    width:                          Math.max(parent.width/2-ScreenTools.defaultFontPixelHeight*2, ScreenTools.defaultFontPixelHeight*30)
                    height:                         Math.max(disColumn.height+disColumn.y,disimg.height) + _margins
                    color:                          "transparent"
                    visible:                        !controller.vehicle.fixedWing
                    Image {
                        anchors.fill:               parent
                        mipmap:                     true
                        source:                     "/qmlimages/safebackground.svg"
                    }
                    Image {
                        id:                         disimg
                        width:                      ScreenTools.defaultFontPixelWidth * 20
                        fillMode:                   Image.PreserveAspectFit
                        anchors.top:                parent.top
                        anchors.right:              parent.right
                        anchors.margins:            ScreenTools.defaultFontPixelHeight/2
                        mipmap:                     true
                        source:                     "/qmlimages/safedistance.svg"
                    }
                    Image {
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.right:                  disimg.left
                      //  fillMode:                       Image.PreserveAspectFit
                        height:                         ScreenTools.defaultFontPixelHeight*2.4
                        anchors.topMargin:              ScreenTools.defaultFontPixelHeight/2
                        mipmap:                         true
                        source:                         "/qmlimages/safetitlebg.svg"
                    }
                    QGCLabel {
                        id:                             dissafeid
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        text:                           qsTr("安全距离")//  qsTr("safe distance")
                        font.family:                    ScreenTools.demiboldFontFamily
                        font.pointSize:                 ScreenTools.mediumFontPointSize
                    }
                    Column {
                        id:                             disColumn
                        spacing:                        _margins * 0.5
                        anchors.top:                    dissafeid.bottom
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        Row {
                            QGCLabel {
                                id:                 disActionLabel
                                anchors.baseline:   disActionCombo.baseline
                                text:               qsTr("安全距离启用")//qsTr("Action on safe distance")
                                Layout.fillWidth:   true
                            }
                            FactComboBox {
                                id:                 disActionCombo
                                width:              _editFieldWidth
                                fact:               _disAction
                                indexModel:         false
                            }
                        }
                        Row {
                            QGCLabel {
                                anchors.baseline:   disField.baseline
                                 Layout.fillWidth:   true
                                //       font.pointSize:     ScreenTools.mediumFontPointSize
                                text:               qsTr("安全距离")//qsTr("Battery Warn Level:")
                            }
                            FactTextField {
                                id:                 disField
                                fact:               controller.getParameterFact(-1, "MPC_SAFE_DIS", false)
                                showUnits:          true
                                width:              _editFieldWidth
                            }
                        }

                    }

                }
                /*
                   **** Low Battery ****
                */
                Rectangle {
                    width:                              Math.max(parent.width/2-ScreenTools.defaultFontPixelHeight*2, ScreenTools.defaultFontPixelHeight*30)
                    height:                             Math.max(lowBattColumn.height+lowBattColumn.y,baimg.height)+ _margins
                    color:                          "transparent"
                    Image {
                        anchors.fill:               parent
                        mipmap:                     true
                        source:                     "/qmlimages/safebackground.svg"
                    }
                    Image {
                        id:                         baimg
                        width:                      ScreenTools.defaultFontPixelWidth * 20
                        fillMode:                   Image.PreserveAspectFit
                        anchors.top:                parent.top
                        anchors.right:              parent.right
                        anchors.margins:            ScreenTools.defaultFontPixelHeight/2
                        mipmap:                     true
                        source:                     "/qmlimages/safeBattery.svg"
                    }
                    Image {
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.right:                  baimg.left
                      //  fillMode:                       Image.PreserveAspectFit
                        height:                         ScreenTools.defaultFontPixelHeight*2.4
                        anchors.topMargin:              ScreenTools.defaultFontPixelHeight/2
                        mipmap:                         true
                        source:                         "/qmlimages/safetitlebg.svg"
                    }
                    QGCLabel {
                        id:                             batsafeid
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        text:                           qsTr("低电压安全触发")// qsTr("Low Battery Failsafe Trigger")
                        font.family:                    ScreenTools.demiboldFontFamily
                        font.pointSize:                 ScreenTools.mediumFontPointSize
                    }
                    Column {
                        id:                             lowBattColumn
                        spacing:                        _margins * 0.5
                        anchors.top:                    batsafeid.bottom
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        Row {
                            QGCLabel {
                                anchors.baseline:   lowBattCombo.baseline
                                 Layout.fillWidth:   true
                                //        font.pointSize:     ScreenTools.mediumFontPointSize
                                text:               qsTr("触发动作")//qsTr("Failsafe Action:")
                            }
                            FactComboBox {
                                id:                 lowBattCombo
                                width:              _editFieldWidth
                                fact:               _lowBattAction
                                indexModel:         false
                            }
                        }
                        Row {
                            QGCLabel {
                                anchors.baseline:   batLowLevelField.baseline
                                Layout.fillWidth:   true
                                //       font.pointSize:     ScreenTools.mediumFontPointSize
                                text:               qsTr("低电压警告")//qsTr("Battery Warn Level:")
                            }
                            FactTextField {
                                id:                 batLowLevelField
                                fact:               controller.getParameterFact(-1, "BAT_LOW_THR")
                                showUnits:          true
                                width:              _editFieldWidth

                            }
                        }
                        Row {
                            QGCLabel {
                                anchors.baseline:   batCritLevelField.baseline
                                Layout.fillWidth:   true
                                //        font.pointSize:     ScreenTools.mediumFontPointSize
                                text:               qsTr("低电压安全")//qsTr("Battery Failsafe Level:")
                            }
                            FactTextField {
                                id:                 batCritLevelField
                                fact:               controller.getParameterFact(-1, "BAT_CRIT_THR")
                                showUnits:          true
                                width:              _editFieldWidth
                            }
                        }
                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth
                            property Fact _percentRemainingAnnounce:    QGroundControl.settingsManager.appSettings.batteryPercentRemainingAnnounce
                            QGCCheckBox {
                                id:                 announcePercentCheckbox
                                text:               qsTr("地面站报警:")
                                checked:            parent._percentRemainingAnnounce.value !== 0
                                width:              (_editFieldWidth) * 0.65
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    if (checked) {
                                        parent._percentRemainingAnnounce.value = parent._percentRemainingAnnounce.defaultValueString
                                    } else {
                                        parent._percentRemainingAnnounce.value = 0
                                    }
                                }
                            }
                            FactTextField {
                                id:                 announcePercent
                                fact:               parent._percentRemainingAnnounce
                                width:              (_editFieldWidth) * 0.65
                                enabled:            announcePercentCheckbox.checked
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                }
                /*
                   **** RC Loss ****
                */
                Rectangle {
                    width:                          Math.max(parent.width/2-ScreenTools.defaultFontPixelHeight*2, ScreenTools.defaultFontPixelHeight*30)
                    height:                         Math.max(rcColumn.height+rcColumn.y,rcimg.height)+ _margins
                    color:                          "transparent"
                    Image {
                        anchors.fill:               parent
                        mipmap:                     true
                        source:                     "/qmlimages/safebackground.svg"
                    }
                    Image {
                        id:                         rcimg
                        width:                      ScreenTools.defaultFontPixelWidth * 20
                        fillMode:                   Image.PreserveAspectFit
                        anchors.top:                parent.top
                        anchors.right:              parent.right
                        anchors.margins:            ScreenTools.defaultFontPixelHeight/2
                        mipmap:                     true
                        source:                     "/qmlimages/saferc.svg"
                    }
                    Image {
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.right:                  rcimg.left
                      //  fillMode:                       Image.PreserveAspectFit
                        height:                         ScreenTools.defaultFontPixelHeight*2.4
                        anchors.topMargin:              ScreenTools.defaultFontPixelHeight/2
                        mipmap:                         true
                        source:                         "/qmlimages/safetitlebg.svg"
                    }
                    QGCLabel {
                        id:                             rcsafeid
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        text:                           qsTr("遥控丢失触发行为")// qsTr("RC Loss Failsafe Trigger")
                        font.family:                    ScreenTools.demiboldFontFamily
                        font.pointSize:                 ScreenTools.mediumFontPointSize
                    }
                    Column {
                        id:                             rcColumn
                        spacing:                        _margins * 0.5
                        anchors.top:                    rcsafeid.bottom
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        Row {
                            QGCLabel {
                                anchors.baseline:   rcLossCombo.baseline
                                Layout.fillWidth:   true
                                text:               qsTr("遥控丢失触发行为")// qsTr("Failsafe Action:")
                            }
                            FactComboBox {
                                id:                 rcLossCombo
                                width:              _editFieldWidth
                                fact:               _rcLossAction
                                indexModel:         false
                            }
                        }
                        Row {
                            QGCLabel {
                                anchors.baseline:   rcLossField.baseline
                                Layout.fillWidth:   true
                                text:               qsTr("遥控丢失超时时间:")// qsTr("RC Loss Timeout:")
                            }
                            FactTextField {
                                id:                 rcLossField
                                fact:               controller.getParameterFact(-1, "COM_RC_LOSS_T")
                                showUnits:          true
                                width:              _editFieldWidth
                            }
                        }
                    }

                }

                /*
                   **** Data Link Loss ****
                */
                Rectangle {
                    width:                           Math.max(parent.width/2-ScreenTools.defaultFontPixelHeight*2, ScreenTools.defaultFontPixelHeight*30)
                    height:                          Math.max(dlColumn.height+dlColumn.y,dlimg.height)+ _margins
                    color:                          "transparent"
                    Image {
                        anchors.fill:               parent
                        mipmap:                     true
                        source:                     "/qmlimages/safebackground.svg"
                    }
                    Image {
                        id:                         dlimg
                        width:                      ScreenTools.defaultFontPixelWidth * 20
                        fillMode:                   Image.PreserveAspectFit
                        anchors.top:                parent.top
                        anchors.right:              parent.right
                        anchors.margins:            ScreenTools.defaultFontPixelHeight/2
                        mipmap:                     true
                        source:                     "/qmlimages/safelink.svg"
                    }
                    Image {
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.right:                  dlimg.left
                      //  fillMode:                       Image.PreserveAspectFit
                        height:                         ScreenTools.defaultFontPixelHeight*2.4
                        anchors.topMargin:              ScreenTools.defaultFontPixelHeight/2
                        mipmap:                         true
                        source:                         "/qmlimages/safetitlebg.svg"
                    }
                    QGCLabel {
                        id:                             dlsafeid
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        text:                           qsTr("数据链丢失")// qsTr("Data Link Loss Failsafe Trigger")
                        font.family:                    ScreenTools.demiboldFontFamily
                        font.pointSize:                 ScreenTools.mediumFontPointSize
                    }
                    Column {
                        id:                             dlColumn
                        spacing:                        _margins * 0.5
                        anchors.top:                    dlsafeid.bottom
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        Row {
                            QGCLabel {
                                anchors.baseline:   dlLossCombo.baseline
                                 Layout.fillWidth:   true
                                text:              qsTr("触发行为:")// qsTr("Failsafe Action:")
                            }
                            FactComboBox {
                                id:                 dlLossCombo
                                width:              _editFieldWidth
                                fact:               _dlLossAction
                                indexModel:         false
                            }
                        }
                        Row {
                            QGCLabel {
                                anchors.baseline:   dlLossField.baseline
                                Layout.fillWidth:   true
                                text:              qsTr("数据链丢失超时:")//  qsTr("Data Link Loss Timeout:")
                            }
                            FactTextField {
                                id:                 dlLossField
                                fact:               controller.getParameterFact(-1, "COM_DL_LOSS_T")
                                showUnits:          true
                                width:              _editFieldWidth
                            }
                        }
                    }

                }

                /*
                   **** Geofence ****
                */
                Rectangle {
                    width:                              Math.max(parent.width/2-ScreenTools.defaultFontPixelHeight*2, ScreenTools.defaultFontPixelHeight*30)
                    height:                             Math.max(geoColumn.height+geoColumn.y,geoimg.height) + _margins
                    color:                          "transparent"
                    Image {
                        anchors.fill:               parent
                        mipmap:                     true
                        source:                     "/qmlimages/safebackground.svg"
                    }
                    Image {
                        id:                         geoimg
                        width:                      ScreenTools.defaultFontPixelWidth * 20
                        fillMode:                   Image.PreserveAspectFit
                        anchors.top:                parent.top
                        anchors.right:              parent.right
                        anchors.margins:            ScreenTools.defaultFontPixelHeight/2
                        mipmap:                     true
                        source:                     "/qmlimages/safeGeofence.svg"
                    }
                    Image {
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.right:                  geoimg.left
                      //  fillMode:                       Image.PreserveAspectFit
                        height:                         ScreenTools.defaultFontPixelHeight*2.4
                        anchors.topMargin:              ScreenTools.defaultFontPixelHeight/2
                        mipmap:                         true
                        source:                         "/qmlimages/safetitlebg.svg"
                    }
                    QGCLabel {
                        id:                             geosafeid
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        text:                           qsTr("围栏设置")//  qsTr("Geofence Failsafe Trigger")
                        font.family:                    ScreenTools.demiboldFontFamily
                        font.pointSize:                 ScreenTools.mediumFontPointSize
                    }
                    Column {
                        id:                             geoColumn
                        spacing:                        _margins * 0.5
                        anchors.top:                    geosafeid.bottom
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        Row {
                            QGCLabel {
                                id:                 fenceActionLabel
                                anchors.baseline:   fenceActionCombo.baseline
                                text:               qsTr("违反设置")//qsTr("Action on breach:")
                                Layout.fillWidth:   true
                            }
                            FactComboBox {
                                id:                 fenceActionCombo
                                width:              _editFieldWidth
                                fact:               _fenceAction
                                indexModel:         false
                            }
                        }
                        Row {
                            QGCCheckBox {
                                id:                 fenceRadiusCheckBox
                                anchors.baseline:   fenceRadiusField.baseline
                                text:               qsTr("最大半径")//qsTr("Max radius:")
                                checked:            _fenceRadius.value > 0
                                onClicked:          _fenceRadius.value = checked ? 100 : 0
                                Layout.fillWidth:   true
                            }
                            FactTextField {
                                id:                 fenceRadiusField
                                showUnits:          true
                                fact:               _fenceRadius
                                enabled:            fenceRadiusCheckBox.checked
                                width:              _editFieldWidth
                            }
                        }
                        Row {
                            QGCCheckBox {
                                id:                 fenceAltMaxCheckBox
                                anchors.baseline:   fenceAltMaxField.baseline
                                text:               qsTr("最大高度")//qsTr("Max altitude:")
                                checked:            _fenceAlt.value > 0
                                onClicked:          _fenceAlt.value = checked ? 100 : 0
                                Layout.fillWidth:   true
                            }
                            FactTextField {
                                id:                 fenceAltMaxField
                                showUnits:          true
                                fact:               _fenceAlt
                                enabled:            fenceAltMaxCheckBox.checked
                                width:              _editFieldWidth
                            }
                        }
                    }

                }

                /*
                   **** Return Home Settings ****
                */

                Rectangle {
                    width:                           Math.max(parent.width/2-ScreenTools.defaultFontPixelHeight*2, ScreenTools.defaultFontPixelHeight*30)
                    height:                          Math.max(rtlColumn.height+rtlColumn.y,rtlimg.height) + _margins
                    color:                          "transparent"
                    Image {
                        anchors.fill:               parent
                        mipmap:                     true
                        source:                     "/qmlimages/safebackground.svg"
                    }
                    Image {
                        id:                         rtlimg
                        width:                      ScreenTools.defaultFontPixelWidth * 20
                        fillMode:                   Image.PreserveAspectFit
                        anchors.top:                parent.top
                        anchors.right:              parent.right
                        anchors.margins:            ScreenTools.defaultFontPixelHeight/2
                        mipmap:                     true
                        source:                     "/qmlimages/safebackhome.svg"
                    }
                    Image {
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.right:                  rtlimg.left
                      //  fillMode:                       Image.PreserveAspectFit
                        height:                         ScreenTools.defaultFontPixelHeight*2.4
                        anchors.topMargin:              ScreenTools.defaultFontPixelHeight/2
                        mipmap:                         true
                        source:                         "/qmlimages/safetitlebg.svg"
                    }
                    QGCLabel {
                        id:                             rtlsafeid
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        text:                           qsTr("返航设置")//   qsTr("Return Home Settings")
                        font.family:                    ScreenTools.demiboldFontFamily
                        font.pointSize:                 ScreenTools.mediumFontPointSize
                    }
                    Column {
                        id:                             rtlColumn
                        spacing:                        _margins * 0.5
                        anchors.top:                    rtlsafeid.bottom
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        Row {
                            QGCLabel {
                                id:                 climbLabel
                                anchors.baseline:   climbField.baseline
                                Layout.fillWidth:   true
                                text:               qsTr("上升高度")//qsTr("Climb to altitude of:")
                            }
                            FactTextField {
                                id:                 climbField
                                fact:               controller.getParameterFact(-1, "RTL_RETURN_ALT")
                                showUnits:          true
                                Layout.minimumWidth: _editFieldWidth
                            }
                        }
                        Row {
                            QGCLabel {
                                id:                     returnHomeLabel
                                width:                 _editFieldWidth
                                text:                   qsTr("返航后:")// "Return home, then:"
                            }
                            Column {
                                spacing:            _margins * 0.5
                                QGCRadioButton {
                                    id:             homeLandRadio
                                    checked:        _rtlLandDelay.value === 0
                                    exclusiveGroup: homeLoiterGroup
                                    text:            qsTr("立即降落")//"Land immediately"
                                    onClicked:      _rtlLandDelay.value = 0
                                }
                                QGCRadioButton {
                                    id:             homeLoiterNoLandRadio
                                    checked:        _rtlLandDelay.value < 0
                                    exclusiveGroup: homeLoiterGroup
                                    text:           qsTr("悬停(盘旋)")//"Loiter and do not land"
                                    onClicked:      _rtlLandDelay.value = -1
                                }
                                QGCRadioButton {
                                    id:             homeLoiterLandRadio
                                    checked:        _rtlLandDelay.value > 0
                                    exclusiveGroup: homeLoiterGroup
                                    text:           qsTr("悬停(盘旋)一定时间后降落")//qsTr("Loiter and land after specified time")
                                    onClicked:      _rtlLandDelay.value = 60
                                }
                            }
                        }
                        Row {
                            QGCLabel {
                                text:                qsTr("悬停(盘旋)时间")//qsTr("Loiter Time")
                                Layout.fillWidth:   true
                                anchors.baseline:   landDelayField.baseline
                                color:              qgcPal.text
                                enabled:            homeLoiterLandRadio.checked === true
                            }
                            FactTextField {
                                id:                 landDelayField
                                fact:               controller.getParameterFact(-1, "RTL_LAND_DELAY")
                                showUnits:          true
                                enabled:            homeLoiterLandRadio.checked === true
                                width:              _editFieldWidth
                            }
                        }
                        Row {
                            QGCLabel {
                                text:               qsTr("悬停(盘旋)高度")//qsTr("Loiter Altitude")
                                Layout.fillWidth:   true
                                anchors.baseline:   descendField.baseline
                                color:              qgcPal.text
                                enabled:            homeLoiterLandRadio.checked === true || homeLoiterNoLandRadio.checked === true
                            }
                            FactTextField {
                                id:                 descendField
                                fact:               controller.getParameterFact(-1, "RTL_DESCEND_ALT")
                                enabled:            homeLoiterLandRadio.checked === true || homeLoiterNoLandRadio.checked === true
                                showUnits:          true
                                width:              _editFieldWidth
                            }
                        }
                    }

                }
                //                QGCLabel {
                //                    id:                                 rtlLabel
                //                    text:                               qsTr("Return Home Settings")
                //                    font.family:                        ScreenTools.demiboldFontFamily
                //                }
                //                Rectangle {
                //                    id:                                 rtlSettings
                //                    color:                              qgcPal.windowShade
                //                    width:                              rtlRow.width  + _margins * 2
                //                    height:                             rtlRow.height + _margins * 2
                //                    Row {
                //                        id:                             rtlRow
                //                        spacing:                        _margins
                //                        anchors.verticalCenter:         parent.verticalCenter
                //                        Item { width: _margins * 0.5; height: 1; }
                //                        QGCColoredImage {
                //                            id:                         icon
                //                            color:                      qgcPal.text
                //                            height:                     ScreenTools.defaultFontPixelWidth * 10
                //                            width:                      ScreenTools.defaultFontPixelWidth * 20
                //                            sourceSize.width:           width
                //                            mipmap:                     true
                //                            fillMode:                   Image.PreserveAspectFit
                //                            source:                     controller.vehicle.fixedWing ? "/qmlimages/ReturnToHomeAltitude.svg" : "/qmlimages/ReturnToHomeAltitudeCopter.svg"
                //                            anchors.verticalCenter:     parent.verticalCenter
                //                            visible:                    _showIcons
                //                        }
                //                        Item {
                //                            width:      _margins * 0.5
                //                            height:     1
                //                            visible:    _showIcons
                //                        }
                //                        Column {
                //                            spacing:                    _margins * 0.5
                //                            Row {
                //                                QGCLabel {
                //                                    id:                 climbLabel
                //                                    anchors.baseline:   climbField.baseline
                //                                    width:              _middleRowWidth
                //                                    text:               qsTr("Climb to altitude of:")
                //                                }
                //                                FactTextField {
                //                                    id:                 climbField
                //                                    fact:               controller.getParameterFact(-1, "RTL_RETURN_ALT")
                //                                    showUnits:          true
                //                                    width:              _editFieldWidth
                //                                }
                //                            }
                //                            Item { width: 1; height: _margins * 0.5; }
                //                            QGCLabel {
                //                                id:                     returnHomeLabel
                //                                text:                   "Return home, then:"
                //                            }
                //                            Row {
                //                                Item { height: 1; width: _margins; }
                //                                Column {
                //                                    spacing:            _margins * 0.5
                //                                    ExclusiveGroup { id: homeLoiterGroup }
                //                                    QGCRadioButton {
                //                                        id:             homeLandRadio
                //                                        checked:        _rtlLandDelay.value === 0
                //                                        exclusiveGroup: homeLoiterGroup
                //                                        text:           "Land immediately"
                //                                        onClicked:      _rtlLandDelay.value = 0
                //                                    }
                //                                    QGCRadioButton {
                //                                        id:             homeLoiterNoLandRadio
                //                                        checked:        _rtlLandDelay.value < 0
                //                                        exclusiveGroup: homeLoiterGroup
                //                                        text:           "Loiter and do not land"
                //                                        onClicked:      _rtlLandDelay.value = -1
                //                                    }
                //                                    QGCRadioButton {
                //                                        id:             homeLoiterLandRadio
                //                                        checked:        _rtlLandDelay.value > 0
                //                                        exclusiveGroup: homeLoiterGroup
                //                                        text:           qsTr("Loiter and land after specified time")
                //                                        onClicked:      _rtlLandDelay.value = 60
                //                                    }
                //                                }
                //                            }
                //                            Item { width: 1; height: _margins * 0.5; }
                //                            Row {
                //                                QGCLabel {
                //                                    text:               qsTr("Loiter Time")
                //                                    width:              _middleRowWidth
                //                                    anchors.baseline:   landDelayField.baseline
                //                                    color:              qgcPal.text
                //                                    enabled:            homeLoiterLandRadio.checked === true
                //                                }
                //                                FactTextField {
                //                                    id:                 landDelayField
                //                                    fact:               controller.getParameterFact(-1, "RTL_LAND_DELAY")
                //                                    showUnits:          true
                //                                    enabled:            homeLoiterLandRadio.checked === true
                //                                    width:              _editFieldWidth
                //                                }
                //                            }
                //                            Row {
                //                                QGCLabel {
                //                                    text:               qsTr("Loiter Altitude")
                //                                    width:              _middleRowWidth
                //                                    anchors.baseline:   descendField.baseline
                //                                    color:              qgcPal.text
                //                                    enabled:            homeLoiterLandRadio.checked === true || homeLoiterNoLandRadio.checked === true
                //                                }
                //                                FactTextField {
                //                                    id:                 descendField
                //                                    fact:               controller.getParameterFact(-1, "RTL_DESCEND_ALT")
                //                                    enabled:            homeLoiterLandRadio.checked === true || homeLoiterNoLandRadio.checked === true
                //                                    showUnits:          true
                //                                    width:              _editFieldWidth
                //                                }
                //                            }
                //                        }
                //                    }
                //                }
                /*
                   **** Land Mode Settings ****
                */
                Rectangle {
                    width:                              Math.max(parent.width/2-ScreenTools.defaultFontPixelHeight*2, ScreenTools.defaultFontPixelHeight*30)
                    height:                             Math.max(landColumn.height+landColumn.y,landimg.height) + _margins
                    color:                          "transparent"
                    Image {
                        anchors.fill:               parent
                        mipmap:                     true
                        source:                     "/qmlimages/safebackground.svg"
                    }
                    Image {
                        id:                         landimg
                        width:                      ScreenTools.defaultFontPixelWidth * 20
                        fillMode:                   Image.PreserveAspectFit
                        anchors.top:                parent.top
                        anchors.right:              parent.right
                        anchors.margins:            ScreenTools.defaultFontPixelHeight/2
                        mipmap:                     true
                        source:                     "/qmlimages/safeland.svg"
                    }
                    Image {
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.right:                  landimg.left
                      //  fillMode:                       Image.PreserveAspectFit
                        height:                         ScreenTools.defaultFontPixelHeight*2.4
                        anchors.topMargin:              ScreenTools.defaultFontPixelHeight/2
                        mipmap:                         true
                        source:                         "/qmlimages/safetitlebg.svg"
                    }
                    QGCLabel {
                        id:                             landsafeid
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        text:                           qsTr("降落设置")//   qsTr("Land Mode Settings")
                        font.family:                    ScreenTools.demiboldFontFamily
                        font.pointSize:                 ScreenTools.mediumFontPointSize
                    }
                    Column {
                        id:                             landColumn
                        spacing:                        _margins * 0.5
                        anchors.top:                    landsafeid.bottom
                        anchors.left:                   parent.left
                        anchors.margins:                ScreenTools.defaultFontPixelHeight
                        Row {
                            visible:                !controller.vehicle.fixedWing && (_landSpeedMC !== -1)
                            QGCLabel {
                                anchors.baseline:   landVelField.baseline
                                Layout.fillWidth:   true
                                text:               qsTr("降落速度")//  qsTr("Landing Velocity:")
                            }
                            FactTextField {
                                id:                 landVelField
                                fact:               _landSpeedMC
                                showUnits:          true
                                width:              _editFieldWidth
                            }
                        }
                        Row {
                            QGCCheckBox {
                                id:                 disarmDelayCheckBox
                                anchors.baseline:   disarmField.baseline
                                text:               qsTr("加锁时间")//qsTr("Disarm After:")
                                checked:            _disarmLandDelay.value > 0
                                onClicked:          _disarmLandDelay.value = checked ? 2 : 0
                                Layout.fillWidth:   true
                            }
                            FactTextField {
                                id:                 disarmField
                                showUnits:          true
                                fact:               _disarmLandDelay
                                enabled:            disarmDelayCheckBox.checked
                                width:              _editFieldWidth
                            }
                        }
                    }
                }
                Item { width: 1; height: _margins * 0.5; }
            } // Column
        } // Item
    } // Component
} // SetupPage

