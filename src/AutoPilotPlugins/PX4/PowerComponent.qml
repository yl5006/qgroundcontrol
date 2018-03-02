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
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

SetupPage {
    id:             powerPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  Math.max(availableWidth, innerColumn.width)
            height: innerColumn.height+ScreenTools.defaultFontPixelHeight*8

            property int textEditWidth:    ScreenTools.defaultFontPixelWidth * 8

            property Fact battNumCells:         controller.getParameterFact(-1, "BAT_N_CELLS")
            property Fact battHighVolt:         controller.getParameterFact(-1, "BAT_V_CHARGED")
            property Fact battLowVolt:          controller.getParameterFact(-1, "BAT_V_EMPTY")
            property Fact battVoltLoadDrop:     controller.getParameterFact(-1, "BAT_V_LOAD_DROP")
            property Fact battVoltageDivider:   controller.getParameterFact(-1, "BAT_V_DIV")
            property Fact battAmpsPerVolt:      controller.getParameterFact(-1, "BAT_A_PER_V")
            property Fact uavcanEnable:         controller.getParameterFact(-1, "UAVCAN_ENABLE", false)

            readonly property string highlightPrefix:   "<font color=\"" + qgcPal.warningText + "\">"
            readonly property string highlightSuffix:   "</font>"

            function getBatteryImage()
            {
                switch(battNumCells.value) {
                case 1:  return "/qmlimages/PowerComponentBattery_01cell.svg";
                case 2:  return "/qmlimages/PowerComponentBattery_02cell.svg"
                case 3:  return "/qmlimages/PowerComponentBattery_03cell.svg"
                case 4:  return "/qmlimages/PowerComponentBattery_04cell.svg"
                case 5:  return "/qmlimages/PowerComponentBattery_05cell.svg"
                case 6:  return "/qmlimages/PowerComponentBattery_06cell.svg"
                default: return "/qmlimages/PowerComponentBattery_01cell.svg";
                }
            }

            function drawArrowhead(ctx, x, y, radians)
            {
                ctx.save();
                ctx.beginPath();
                ctx.translate(x,y);
                ctx.rotate(radians);
                ctx.moveTo(0,0);
                ctx.lineTo(5,10);
                ctx.lineTo(-5,10);
                ctx.closePath();
                ctx.restore();
                ctx.fill();
            }

            function drawLineWithArrow(ctx, x1, y1, x2, y2)
            {
                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
                ctx.stroke();
                var rd = Math.atan((y2 - y1) / (x2 - x1));
                rd += ((x2 > x1) ? 90 : -90) * Math.PI/180;
                drawArrowhead(ctx, x2, y2, rd);
            }

            PowerComponentController {
                id:         controller
                factPanel:  powerPage.viewPanel

                onOldFirmware:          showMessage(qsTr("ESC Calibration"), qsTr("QGroundControl cannot perform ESC Calibration with this version of firmware. You will need to upgrade to a newer firmware."), StandardButton.Ok)
                onNewerFirmware:        showMessage(qsTr("ESC Calibration"), qsTr("QGroundControl cannot perform ESC Calibration with this version of firmware. You will need to upgrade QGroundControl."), StandardButton.Ok)
                onBatteryConnected:     showMessage(qsTr("ESC Calibration"), qsTr("Performing calibration. This will take a few seconds.."), 0)
                onCalibrationFailed:    showMessage(qsTr("ESC Calibration failed"), errorMessage, StandardButton.Ok)
                onCalibrationSuccess:   showMessage(qsTr("ESC Calibration"), qsTr("Calibration complete. You can disconnect your battery now if you like."), StandardButton.Ok)
                onConnectBattery:       showMessage(qsTr("ESC Calibration"), highlightPrefix + qsTr("WARNING: Props must be removed from vehicle prior to performing ESC calibration.") + highlightSuffix + qsTr(" Connect the battery now and calibration will begin."), 0)
                onDisconnectBattery:    showMessage(qsTr("ESC Calibration failed"), qsTr("You must disconnect the battery prior to performing ESC Calibration. Disconnect your battery and try again."), StandardButton.Ok)
            }

            Component {
                id: calcVoltageDividerDlgComponent

                QGCViewDialog {
                    id: calcVoltageDividerDlg

                    QGCFlickable {
                        anchors.fill:   parent
                        contentHeight:  column.height
                        contentWidth:   column.width

                        Column {
                            id:         column
                            width:      calcVoltageDividerDlg.width
                            spacing:    ScreenTools.defaultFontPixelHeight

                            QGCLabel {
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                text:       "Measure battery voltage using an external voltmeter and enter the value below. Click Calculate to set the new voltage multiplier."
                            }

                            Grid {
                                columns: 2
                                spacing: ScreenTools.defaultFontPixelHeight / 2
                                verticalItemAlignment: Grid.AlignVCenter

                                QGCLabel {
                                    text: "Measured voltage:"
                                }
                                QGCTextField { id: measuredVoltage }

                                QGCLabel { text: "Vehicle voltage:" }
                                QGCLabel { text: controller.vehicle.battery.voltage.valueString }

                                QGCLabel { text: "Voltage divider:" }
                                FactLabel { fact: battVoltageDivider }
                            }

                            QGCButton {
                                text: "Calculate"

                                onClicked:  {
                                    var measuredVoltageValue = parseFloat(measuredVoltage.text)
                                    if (measuredVoltageValue == 0 || isNaN(measuredVoltageValue)) {
                                        return
                                    }
                                    var newVoltageDivider = (measuredVoltageValue * battVoltageDivider.value) / controller.vehicle.battery.voltage.value
                                    if (newVoltageDivider > 0) {
                                        battVoltageDivider.value = newVoltageDivider
                                    }
                                }
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - calcVoltageDividerDlgComponent

            Component {
                id: calcAmpsPerVoltDlgComponent

                QGCViewDialog {
                    id: calcAmpsPerVoltDlg

                    QGCFlickable {
                        anchors.fill:   parent
                        contentHeight:  column.height
                        contentWidth:   column.width

                        Column {
                            id:         column
                            width:      calcAmpsPerVoltDlg.width
                            spacing:    ScreenTools.defaultFontPixelHeight

                            QGCLabel {
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                text:       "Measure current draw using an external current meter and enter the value below. Click Calculate to set the new amps per volt value."
                            }

                            Grid {
                                columns: 2
                                spacing: ScreenTools.defaultFontPixelHeight / 2
                                verticalItemAlignment: Grid.AlignVCenter

                                QGCLabel {
                                    text: "Measured current:"
                                }
                                QGCTextField { id: measuredCurrent }

                                QGCLabel { text: "Vehicle current:" }
                                QGCLabel { text: controller.vehicle.battery.current.valueString }

                                QGCLabel { text: "Amps per volt:" }
                                FactLabel { fact: battAmpsPerVolt }
                            }

                            QGCButton {
                                text: "Calculate"

                                onClicked:  {
                                    var measuredCurrentValue = parseFloat(measuredCurrent.text)
                                    if (measuredCurrentValue == 0) {
                                        return
                                    }
                                    var newAmpsPerVolt = (measuredCurrentValue * battAmpsPerVolt.value) / controller.vehicle.battery.current.value
                                    if (newAmpsPerVolt != 0) {
                                        battAmpsPerVolt.value = newAmpsPerVolt
                                    }
                                }
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - calcAmpsPerVoltDlgComponent

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
                    source:     "/qmlimages/Battery.svg"
                    fillMode:   Image.PreserveAspectFit
                    color:      qgcPal.text
                    anchors.horizontalCenter:circle.horizontalCenter
                    anchors.verticalCenter: circle.verticalCenter
                }
                QGCLabel {
                    id:             idset
                    anchors.left:   img.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("电池")//"safe"
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
            Row {
                id:          innerColumn
                anchors.top: title.bottom
                anchors.left:          parent.left
                anchors.leftMargin:     ScreenTools.defaultFontPixelHeight*5
                anchors.topMargin: ScreenTools.defaultFontPixelHeight
                //                anchors.horizontalCenter:   parent.horizontalCenter
                spacing:    ScreenTools.defaultFontPixelHeight *2

                //                QGCLabel {
                //                    text: qsTr("Battery")
                //                    font.family: ScreenTools.demiboldFontFamily
                //                }
                Item {
                    width:                         Math.max(parent.width/2-ScreenTools.defaultFontPixelHeight*2, ScreenTools.defaultFontPixelHeight*30)
                    height:                        batteryGrid.y+batteryGrid.height+ScreenTools.defaultFontPixelHeight

                    Image {
                        anchors.fill:               parent
                        mipmap:                     true
                        source:                     "/qmlimages/safebackground.svg"
                    }
                    Rectangle {
                        id:                backcolor
                        width:             parent.width*0.95
                        height:            width*0.6
                        anchors.top:       parent.top
                        anchors.topMargin: ScreenTools.defaultFontPixelHeight
                        anchors.horizontalCenter: parent.horizontalCenter
                        color:             Qt.rgba(0.1804,0.7333,0.856,0.15)
                    }
                    Image {
                        id:                 bat
                        anchors.verticalCenter: backcolor.verticalCenter
                        width:             backcolor.height*0.8
                        height:            width
                        mipmap:            true
                        source:            getBatteryImage()
                        anchors.left:       parent.left
                        anchors.leftMargin:   ScreenTools.defaultFontPixelHeight*2
                    }
                    Image {
                        id:                minmaximg
                        anchors.verticalCenter: backcolor.verticalCenter
                        width:             ScreenTools.defaultFontPixelHeight*4
                        height:            bat.height
                        mipmap:            true
                        source:             "/qmlimages/batteryminmax.svg"
                        anchors.left:       bat.right
                        anchors.leftMargin:   ScreenTools.defaultFontPixelHeight
                    }
                    Column
                    {
                        anchors.top:            minmaximg.top
                        anchors.left:           minmaximg.right
                        anchors.leftMargin:     ScreenTools.defaultFontPixelHeight
                        spacing:            ScreenTools.defaultFontPixelHeight/2
                        QGCLabel {
                            text:   qsTr("最大电压:")//qsTr("Battery Max:")
                            font.family:                    ScreenTools.demiboldFontFamily
                            font.pointSize:                 ScreenTools.mediumFontPointSize
                            font.bold:      true
                        }

                        QGCLabel {
                            text:   (battNumCells.value * battHighVolt.value).toFixed(1) + ' V'
                            font.family:                    ScreenTools.demiboldFontFamily
                            font.pointSize:                 ScreenTools.mediumFontPointSize
                            color:                          "#05f068" //green
                            font.bold:      true
                        }
                    }
                    Column
                    {
                        anchors.bottom:         minmaximg.bottom
                        anchors.left:           minmaximg.right
                        anchors.leftMargin:     -ScreenTools.defaultFontPixelHeight
                        spacing:                ScreenTools.defaultFontPixelHeight/2
                        QGCLabel {
                            text:               qsTr("最小电压:")//qsTr("Battery Min:")
                            font.family:                    ScreenTools.demiboldFontFamily
                            font.pointSize:                 ScreenTools.mediumFontPointSize
                            font.bold:      true
                        }

                        QGCLabel {
                            text:   (battNumCells.value * battLowVolt.value).toFixed(1) + ' V'
                            font.family:                    ScreenTools.demiboldFontFamily
                            font.pointSize:                 ScreenTools.mediumFontPointSize
                            color:                  "red"
                            font.bold:      true
                        }
                    }
                    GridLayout {
                        id:                 batteryGrid
                        anchors.margins:    ScreenTools.defaultFontPixelHeight
                        anchors.horizontalCenter:   parent.horizontalCenter
                        anchors.top:        backcolor.bottom
                        columns:            2
                        columnSpacing:      ScreenTools.defaultFontPixelHeight*3

                        QGCLabel {
                            text:              qsTr("电池芯数") //qsTr("Number of Cells (in Series)")
                        }

                        FactTextField {
                            id:         cellsField
                            width:      textEditWidth
                            fact:       battNumCells
                            showUnits:  true
                        }
                        QGCLabel {
                            id:                 battHighLabel
                            text:               qsTr("单芯电池满电压") //qsTr("Full Voltage (per cell)")
                        }

                        FactTextField {
                            id:         battHighField
                            width:      textEditWidth
                            fact:       battHighVolt
                            showUnits:  true
                        }
                        QGCLabel {
                            id:                 battLowLabel
                            text:               qsTr("单芯电池空电压") //qsTr("Empty Voltage (per cell)")
                        }

                        FactTextField {
                            id:         battLowField
                            width:      textEditWidth
                            fact:       battLowVolt
                            showUnits:  true
                        }

                    }
                }
                Item {
                    width:                         Math.max(parent.width/2-ScreenTools.defaultFontPixelHeight*2, ScreenTools.defaultFontPixelHeight*30)
                    height:                        rightcolum.height+ScreenTools.defaultFontPixelHeight*2
                    Image {
                        anchors.fill:               parent
                        mipmap:                     true
                        source:                     "/qmlimages/safebackground.svg"
                    }
                    Column {
                        id:                rightcolum
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        anchors.leftMargin: ScreenTools.defaultFontPixelHeight*2
                        anchors.right:      parent.right
                        anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                        spacing:    ScreenTools.defaultFontPixelHeight *0.5

                        QGCLabel {
                            text:            qsTr("电调最大值最小值校准")//qsTr("ESC PWM Minimum and Maximum Calibration")
                            font.family:    ScreenTools.demiboldFontFamily
                        }
                        Rectangle {
                            width:      parent.width*0.8
                            height:     ScreenTools.defaultFontPixelHeight*3
                            color:      "red"
                            Image {
                                id:                 warnimg
                                anchors.left:       parent.left
                                anchors.leftMargin: ScreenTools.defaultFontPixelHeight*2
                                source:             "/qmlimages/Yield.svg"
                                height:             ScreenTools.defaultFontPixelHeight*2
                                width:              ScreenTools.defaultFontPixelHeight*2
                                anchors.verticalCenter:   parent.verticalCenter
                            }
                            QGCLabel {
                                anchors.verticalCenter:   parent.verticalCenter
                                anchors.left:       warnimg.right
                                anchors.leftMargin: ScreenTools.defaultFontPixelHeight*2
                                color:      qgcPal.warningText
                                wrapMode:   Text.WordWrap
                                font.pointSize:                 ScreenTools.mediumFontPointSize
                                font.bold:      true
                                text:       qsTr("警告: 在校准前去除螺旋桨")//qsTr("WARNING: Propellers must be removed from vehicle prior to performing ESC calibration.")
                            }
                        }

                        QGCLabel {
                            text:      qsTr("请连接USB")// qsTr("You must use USB connection for this operation.")
                        }

                        QGCButton {
                            text:      qsTr("校准")// qsTr("Calibrate")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            enabled:     true
                            onClicked:  controller.calibrateEsc()
                        }



                        QGCCheckBox {
                            id:         showUAVCAN
                            text:        qsTr("UAVCAN设置")//qsTr("Show UAVCAN Settings")
                            enabled:    false
                    	    checked:    uavcanEnable ? uavcanEnable.rawValue !== 0 : false
                        }

                        QGCLabel {
                            text:           qsTr("UAVCAN Bus Configuration")
                            font.family:    ScreenTools.demiboldFontFamily
                            visible:        showUAVCAN.checked
                        }

                        Rectangle {
                            width:      parent.width
                	    height:     uavCanConfigRow.height + ScreenTools.defaultFontPixelHeight
                            color:      qgcPal.windowShade
                            visible:    showUAVCAN.checked

                	Row {
                    		id:         uavCanConfigRow
                                anchors.margins:    ScreenTools.defaultFontPixelHeight / 2
                                anchors.left:       parent.left
                                anchors.top:        parent.top
                                spacing:            ScreenTools.defaultFontPixelWidth

                    	FactComboBox {
                                    id:                 uavcanEnabledCheckBox
                                    width:              ScreenTools.defaultFontPixelWidth * 20
                                    fact:               uavcanEnable
                        	    indexModel:         false
                    		}

                    	QGCLabel {
                       		  anchors.verticalCenter: parent.verticalCenter
                       		  text:                   qsTr("Change required restart")
                                }
                            }
                        }

                        QGCLabel {
                            text:           qsTr("UAVCAN Motor Index and Direction Assignment")
                            font.family:    ScreenTools.demiboldFontFamily
                            visible:        showUAVCAN.checked
                        }

                        Rectangle {
                            width:      parent.width
                            height:     uavCanEscCalColumn.height + ScreenTools.defaultFontPixelHeight
                            color:      qgcPal.windowShade
                            visible:    showUAVCAN.checked
                            enabled:    uavcanEnabledCheckBox.checked

                            Column {
                                id:                 uavCanEscCalColumn
                                anchors.margins:    ScreenTools.defaultFontPixelHeight / 2
                                anchors.left:       parent.left
                                anchors.right:      parent.right
                                anchors.top:        parent.top
                                spacing:            ScreenTools.defaultFontPixelWidth

                                QGCLabel {
                                    width:      parent.width
                                    wrapMode:   Text.WordWrap
                                    color:      qgcPal.warningText
                                    text:       qsTr("WARNING: Propellers must be removed from vehicle prior to performing UAVCAN ESC configuration.")
                                }

                                QGCLabel {
                                    width:      parent.width
                                    wrapMode:   Text.WordWrap
                                    text:       qsTr("ESC parameters will only be accessible in the editor after assignment.")
                                }

                                QGCLabel {
                                    width:      parent.width
                                    wrapMode:   Text.WordWrap
                                    text:       qsTr("Start the process, then turn each motor into its turn direction, in the order of their motor indices.")
                                }

                                QGCButton {
                                    text:       qsTr("Start Assignment")
                                    width:      ScreenTools.defaultFontPixelWidth * 20
                                    onClicked:  controller.busConfigureActuators()
                                }

                                QGCButton {
                                    text:       qsTr("Stop Assignment")
                                    width:      ScreenTools.defaultFontPixelWidth * 20
                                    onClicked:  controller.stopBusConfigureActuators()
                                }
                            }
                        }

                        QGCCheckBox {
                            id:     showAdvanced
                            text:   qsTr("Show Advanced Settings")
                            visible:        false
                        }

                        QGCLabel {
                            text:           qsTr("Advanced Power Settings")
                            font.family:    ScreenTools.demiboldFontFamily
                            visible:        showAdvanced.checked
                        }

                        Rectangle {
                            id:         batteryRectangle
                            width:      parent.width
                            height:     advBatteryColumn.height + ScreenTools.defaultFontPixelHeight
                            color:      qgcPal.windowShade
                            visible:    showAdvanced.checked

                            Column {
                                id: advBatteryColumn
                                anchors.margins:    ScreenTools.defaultFontPixelHeight / 2
                                anchors.left:       parent.left
                                anchors.right:      parent.right
                                anchors.top:        parent.top
                                spacing:            ScreenTools.defaultFontPixelWidth

                                Row {
                                    spacing: ScreenTools.defaultFontPixelWidth

                                    QGCLabel {
                                        text:               qsTr("Voltage Drop on Full Load (per cell)")
                                        anchors.baseline:   battDropField.baseline
                                    }

                                    FactTextField {
                                        id:         battDropField
                                        width:      textEditWidth
                                        fact:       battVoltLoadDrop
                                        showUnits:  true
                                    }
                                }

                                QGCLabel {
                                    width:      parent.width
                                    wrapMode:   Text.WordWrap
                                    text:       qsTr("Batteries show less voltage at high throttle. Enter the difference in Volts between idle throttle and full ") +
                                                qsTr("throttle, divided by the number of battery cells. Leave at the default if unsure. ") +
                                                highlightPrefix + qsTr("If this value is set too high, the battery might be deep discharged and damaged.") + highlightSuffix
                                }

                                Row {
                                    spacing: ScreenTools.defaultFontPixelWidth

                                    QGCLabel {
                                        text: qsTr("Compensated Minimum Voltage:")
                                    }

                                    QGCLabel {
                                        text: ((battNumCells.value * battLowVolt.value) - (battNumCells.value * battVoltLoadDrop.value)).toFixed(1) + qsTr(" V")
                                    }
                                }
                            }
                        }
                    } // Rectangle - Advanced power settings
                } //Column
            } // ROW
        }   //Item
    } // Component
} // SetupPage
