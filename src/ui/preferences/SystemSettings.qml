﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.5
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtQuick.Dialogs          1.1

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0

SetupPage {
    id:             generalPage
    pageComponent:  pageComponent
    QGCPalette { id: qgcPal }

    Component {
        id: pageComponent
        Item {
            width:  Math.max(availableWidth, settingsColumn.width)
            height: settingsColumn.height

            property Fact _percentRemainingAnnounce:    QGroundControl.batteryPercentRemainingAnnounce
            property real _editFieldWidth:              ScreenTools.defaultFontPixelWidth * 15

            QGCCircleProgress{
                id:                 setcircle
                anchors.left:       parent.left
                anchors.top:        parent.top
                anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                width:              ScreenTools.defaultFontPixelHeight*5
                value:              0
            }
            QGCColoredImage {
                id:         setimg
                height:     ScreenTools.defaultFontPixelHeight*2.5
                width:      height
                sourceSize.width: width
                source:     "/qmlimages/tool-01.svg"
                fillMode:   Image.PreserveAspectFit
                color:      qgcPal.text
                anchors.horizontalCenter:setcircle.horizontalCenter
                anchors.verticalCenter: setcircle.verticalCenter
            }
            QGCLabel {
                    id:             idset
                    anchors.left:   setimg.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("系统设置")//"Systemseting"
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold:              true
                    color:          qgcPal.text
                    anchors.verticalCenter: setimg.verticalCenter
                }
            Image {
                source:    "/qmlimages/title.svg"
                width:      idset.width+ScreenTools.defaultFontPixelHeight*4
                height:     ScreenTools.defaultFontPixelHeight*3
                anchors.verticalCenter: setcircle.verticalCenter
                anchors.left:          setcircle.right
                fillMode: Image.PreserveAspectFit
            }
            Column {
                id:                 settingsColumn
                anchors.top:        setimg.bottom
                anchors.margins:    ScreenTools.defaultFontPixelWidth*2
                spacing:            ScreenTools.defaultFontPixelHeight / 2
                anchors.horizontalCenter: parent.horizontalCenter
                //-----------------------------------------------------------------
                //-- Base UI Font Point Size
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCLabel {
                        id:     baseFontLabel
                        text:   qsTr("Base UI font size:")
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        id:         baseFontRow
                        spacing:    ScreenTools.defaultFontPixelWidth / 2
                        anchors.verticalCenter: parent.verticalCenter

                        QGCButton {
                            id:     decrementButton
                            width:  height
                            height: baseFontEdit.height
                            text:   "-"
                            _showHighlight : true
                            onClicked: {
                                if(ScreenTools.defaultFontPointSize > 6) {
                                    QGroundControl.baseFontPointSize = QGroundControl.baseFontPointSize - 1
                                }
                            }
                        }

                        QGCTextField {
                            id:             baseFontEdit
                            width:          _editFieldWidth - (decrementButton.width * 2) - (baseFontRow.spacing * 2)
                            text:           QGroundControl.baseFontPointSize
                            showUnits:      true
                            unitsLabel:     "pt"
                            maximumLength:  6
                            validator:      DoubleValidator {bottom: 6.0; top: 48.0; decimals: 2;}

                            onEditingFinished: {
                                var point = parseFloat(text)
                                if(point >= 6.0 && point <= 48.0)
                                    QGroundControl.baseFontPointSize = point;
                            }
                        }

                        QGCButton {
                            width:  height
                            height: baseFontEdit.height
                            text:   "+"

                            onClicked: {
                                if(ScreenTools.defaultFontPointSize < 49) {
                                    QGroundControl.baseFontPointSize = QGroundControl.baseFontPointSize + 1
                                }
                            }
                        }
                    }

                    QGCLabel {
                        anchors.verticalCenter: parent.verticalCenter
                        text:                   qsTr("(requires app restart)")
                    }
                }

                //-----------------------------------------------------------------
                //-- Units

                Row {
                    spacing:    ScreenTools.defaultFontPixelWidth

                    QGCLabel {
                        width:              baseFontLabel.width
                        anchors.baseline:   distanceUnitsCombo.baseline
                        text:               qsTr("Distance units:")
                    }

                    FactComboBox {
                        id:                 distanceUnitsCombo
                        width:              _editFieldWidth
                        fact:               QGroundControl.distanceUnits
                        indexModel:         false
                    }

                    QGCLabel {
                        anchors.baseline:   distanceUnitsCombo.baseline
                        text:               qsTr("(requires app restart)")
                    }

                }

                Row {
                    spacing:    ScreenTools.defaultFontPixelWidth

                    QGCLabel {
                        width:              baseFontLabel.width
                        anchors.baseline:   areaUnitsCombo.baseline
                        text:               qsTr("Area units:")
                    }

                    FactComboBox {
                        id:                 areaUnitsCombo
                        width:              _editFieldWidth
                        fact:               QGroundControl.areaUnits
                        indexModel:         false
                    }

                    QGCLabel {
                        anchors.baseline:   areaUnitsCombo.baseline
                        text:               qsTr("(requires app restart)")
                    }

                }

                Row {
                    spacing:                ScreenTools.defaultFontPixelWidth

                    QGCLabel {
                        width:              baseFontLabel.width
                        anchors.baseline:   speedUnitsCombo.baseline
                        text:               qsTr("Speed units:")
                    }

                    FactComboBox {
                        id:                 speedUnitsCombo
                        width:              _editFieldWidth
                        fact:               QGroundControl.speedUnits
                        indexModel:         false
                    }

                    QGCLabel {
                        anchors.baseline:   speedUnitsCombo.baseline
                        text:               qsTr("(requires app restart)")
                    }
                }

                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                }

                //-----------------------------------------------------------------
                //-- Audio preferences
                QGCCheckBox {
                    text:       qsTr("消除音频输出")//"Mute all audio output"
                    checked:    QGroundControl.isAudioMuted
                    onClicked: {
                        QGroundControl.isAudioMuted = checked
                    }
                }
                //-----------------------------------------------------------------
                //-- Prompt Save Log
                QGCCheckBox {
                    id:         promptSaveLog
                    text:       qsTr("在每次飞行中存储飞行日志")//"Prompt to save Flight Data Log after each flight"
                    checked:    QGroundControl.isSaveLogPrompt
                    visible:    !ScreenTools.isMobile
                    onClicked: {
                        QGroundControl.isSaveLogPrompt = checked
                    }
                }
                //-----------------------------------------------------------------
                //-- Prompt Save even if not armed
                QGCCheckBox {
                    text:       qsTr("即使未解锁也存储飞行日志")//"Prompt to save Flight Data Log even if vehicle was not armed"
                    checked:    QGroundControl.isSaveLogPromptNotArmed
                    visible:    !ScreenTools.isMobile
                    enabled:    promptSaveLog.checked
                    onClicked: {
                        QGroundControl.isSaveLogPromptNotArmed = checked
                    }
                }
                //-----------------------------------------------------------------
                //-- Clear settings
                QGCCheckBox {
                    id:         clearCheck
                    text:       qsTr("每次启动清除配置文件")//"Clear all settings on next start"
                    checked:    false
                    onClicked: {
                        checked ? clearDialog.visible = true : QGroundControl.clearDeleteAllSettingsNextBoot()
                    }
                    MessageDialog {
                        id:         clearDialog
                        visible:    false
                        icon:       StandardIcon.Warning
                        standardButtons: StandardButton.Yes | StandardButton.No
                        title:      qsTr("清除设置")//"Clear Settings"
                        text:       qsTr("所有保持设置会在下次重启都清除,你确认要这样做？")//"All saved settings will be reset the next time you start QGroundControl. Is this really what you want?"
                        onYes: {
                            QGroundControl.deleteAllSettingsNextBoot()
                            clearDialog.visible = false
                        }
                        onNo: {
                            clearCheck.checked  = false
                            clearDialog.visible = false
                        }
                    }
                }
                //-----------------------------------------------------------------
                //-- Battery talker
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCCheckBox {
                        id:                 announcePercentCheckbox
                        anchors.baseline:   announcePercent.baseline
                        text:               qsTr("Announce battery lower than:")
                        checked:            _percentRemainingAnnounce.value != 0

                        onClicked: {
                            if (checked) {
                                _percentRemainingAnnounce.value = _percentRemainingAnnounce.defaultValueString
                            } else {
                                _percentRemainingAnnounce.value = 0
                            }
                        }
                    }

                    FactTextField {
                        id:                 announcePercent
                        fact:               _percentRemainingAnnounce
                        enabled:            announcePercentCheckbox.checked
                    }
                }

                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                }

                //-----------------------------------------------------------------
                //-- Map Providers
                Row {

                    /*
                      TODO: Map settings should come from QGroundControl.mapEngineManager. What is currently in
                      QGroundControl.flightMapSettings should be moved there so all map related funtions are in
                      one place.
                     */

                    spacing:    ScreenTools.defaultFontPixelWidth
                    visible:    QGroundControl.flightMapSettings.googleMapEnabled

                    QGCLabel {
                        id:                 mapProvidersLabel
                        anchors.baseline:   mapProviders.baseline
                        text:               qsTr("Map Provider:")
                    }

                    QGCComboBox {
                        id:                 mapProviders
                        width:              _editFieldWidth
                        model:              QGroundControl.flightMapSettings.mapProviders
                        Component.onCompleted: {
                            var index = mapProviders.find(QGroundControl.flightMapSettings.mapProvider)
                            if (index < 0) {
                                console.warn(qsTr("Active map provider not in combobox"), QGroundControl.flightMapSettings.mapProvider)
                            } else {
                                mapProviders.currentIndex = index
                            }
                        }
                        onActivated: {
                            if (index != -1) {
                                currentIndex = index
                                console.log(qsTr("New map provider: ") + model[index])
                                QGroundControl.flightMapSettings.mapProvider = model[index]
                            }
                        }
                    }
                }
                //-----------------------------------------------------------------
                //-- Palette Styles
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCLabel {
                        width:              mapProvidersLabel.width
                        anchors.baseline:   paletteCombo.baseline
                        text:   qsTr("主题")//"Style"
                    }

                    QGCComboBox {
                        id:             paletteCombo
                        width:          _editFieldWidth
                        model: [ qsTr("黑色"), qsTr("亮色") ]//model: [ "Indoor", "Outdoor" ]
                        currentIndex:   QGroundControl.isDarkStyle ? 0 : 1

                        onActivated: {
                            if (index != -1) {
                                currentIndex = index
                                QGroundControl.isDarkStyle = index === 0 ? true : false
                            }
                        }
                    }
                }

                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                }

                //-----------------------------------------------------------------
                //            -- Autoconnect settings  Maybe here do not use (yaoling)
                QGCLabel { text: "Autoconnect to the following devices:" }

                Row {
                    spacing: ScreenTools.defaultFontPixelWidth * 2

                    QGCCheckBox {
                        text:       qsTr("Ewt2.0")//qsTr("Pixhawk")
                        visible:    !ScreenTools.isiOS
                        checked:    QGroundControl.linkManager.autoconnectPixhawk
                        onClicked:  QGroundControl.linkManager.autoconnectPixhawk = checked
                    }

                    QGCCheckBox {
                        text:       qsTr("EWT Radio")//qsTr("SiK Radio")
                        visible:    !ScreenTools.isiOS
                        checked:    QGroundControl.linkManager.autoconnect3DRRadio
                        onClicked:  QGroundControl.linkManager.autoconnect3DRRadio = checked
                    }

                    QGCCheckBox {
                        text:       qsTr("EWT Flow")//qsTr("PX4 Flow")
                        visible:    !ScreenTools.isiOS
                        checked:    QGroundControl.linkManager.autoconnectPX4Flow
                        onClicked:  QGroundControl.linkManager.autoconnectPX4Flow = checked
                    }

                    QGCCheckBox {
                        text:       qsTr("UDP")
                        checked:    QGroundControl.linkManager.autoconnectUDP
                        onClicked:  QGroundControl.linkManager.autoconnectUDP = checked
                    }

                    QGCCheckBox {
                        text:       qsTr("RTK GPS")
                        checked:    QGroundControl.linkManager.autoconnectRTKGPS
                        onClicked:  QGroundControl.linkManager.autoconnectRTKGPS = checked
                    }
                }

                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                }

                //-----------------------------------------------------------------
                //-- Virtual joystick settings
                QGCCheckBox {
                    text:       qsTr("虚拟遥控")//"Virtual Joystick"
                    checked:    QGroundControl.virtualTabletJoystick
                    onClicked:  QGroundControl.virtualTabletJoystick = checked
                }

                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                }

                //-----------------------------------------------------------------
                //-- Offline mission editing settings

                QGCLabel { text: "Offline mission editing" }
                //              only use px4 fly stack(yaoling)
                //                Row {
                //                    spacing: ScreenTools.defaultFontPixelWidth

                //                    QGCLabel {
                //                        text:               qsTr("Firmware:")
                //                        width:              hoverSpeedLabel.width
                //                        anchors.baseline:   offlineTypeCombo.baseline
                //                    }

                //                    FactComboBox {
                //                        id:         offlineTypeCombo
                //                        width:      ScreenTools.defaultFontPixelWidth * 18
                //                        fact:       QGroundControl.offlineEditingFirmwareType
                //                        indexModel: false
                //                    }
                //                }

                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCLabel {
                        text:               qsTr("Vehicle:")
                        width:              hoverSpeedLabel.width
                        anchors.baseline:   offlineVehicleCombo.baseline
                    }

                    FactComboBox {
                        id:         offlineVehicleCombo
                        width:      ScreenTools.defaultFontPixelWidth * 18//offlineTypeCombo.width
                        fact:       QGroundControl.offlineEditingVehicleType
                        indexModel: false
                    }
                }

                Row {
                    spacing: ScreenTools.defaultFontPixelWidth
                    visible:  offlineVehicleCombo.currentText != "Multicopter"

                    QGCLabel {
                        text:               qsTr("Cruise speed:")
                        width:              hoverSpeedLabel.width
                        anchors.baseline:   cruiseSpeedField.baseline
                    }


                    FactTextField {
                        id:                 cruiseSpeedField
                        width:              ScreenTools.defaultFontPixelWidth * 18//offlineTypeCombo.width
                        fact:               QGroundControl.offlineEditingCruiseSpeed
                        enabled:            true
                    }
                }

                Row {
                    spacing: ScreenTools.defaultFontPixelWidth
                    visible:  offlineVehicleCombo.currentText != "Fixedwing"

                    QGCLabel {
                        id:                 hoverSpeedLabel
                        text:               qsTr("Hover speed:")
                        width:              baseFontLabel.width
                        anchors.baseline:   hoverSpeedField.baseline
                    }


                    FactTextField {
                        id:                 hoverSpeedField
                        width:              ScreenTools.defaultFontPixelWidth * 18//offlineTypeCombo.width
                        fact:               QGroundControl.offlineEditingHoverSpeed
                        enabled:            true
                    }
                }
                QGCCircleProgress{
                    width:    60
                    value:    1
                }

                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                }
            }
        }
    } // QGCViewPanel
} // QGCView
