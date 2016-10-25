﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs  1.1

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

Item {
    id:     serialLinkSettings
    width:  parent ? parent.width : 0
    height: serialColumn.height

    function saveSettings() {
        // No Need
    }

    Column {
        id:         serialColumn
        width:      serialLinkSettings.width
        spacing:    ScreenTools.defaultFontPixelHeight / 2
        QGCLabel {
            id:     serialLabel
            text:   qsTr("串口设置")/*Serial Link Settings*/
        }
        Rectangle {
            height: 1
            width:  serialLabel.width
            color:  qgcPal.button
        }
        Item {
            height: ScreenTools.defaultFontPixelHeight / 2
            width:  parent.width
        }
        Row {
            spacing:    ScreenTools.defaultFontPixelWidth
            QGCLabel {
                text:   qsTr("端口:")/*Serial Port*/
                width:  _firstColumn
                anchors.verticalCenter: parent.verticalCenter
            }
            QGCLabel {
                text:       qsTr("无可用串口");/*No serial ports available*/
                visible:    QGroundControl.linkManager.serialPortStrings.length == 0
            }

            QGCComboBox {
                id:                     commPortCombo
                anchors.verticalCenter: parent.verticalCenter
                width:                  _secondColumn
                model:                  QGroundControl.linkManager.serialPortStrings
                visible:                QGroundControl.linkManager.serialPortStrings.length > 0
                onActivated: {
                    if (index != -1) {
                        subEditConfig.portName = QGroundControl.linkManager.serialPorts[index]
                    }
                }
                Component.onCompleted: {
                    if(subEditConfig != null) {
                        if(subEditConfig.portDisplayName === "" && QGroundControl.linkManager.serialPorts.length > 0)
                            subEditConfig.portName = QGroundControl.linkManager.serialPorts[0]
                        var index = commPortCombo.find(subEditConfig.portDisplayName)
                        if (index === -1) {
                            console.warn(qsTr("Serial Port not present"), subEditConfig.portName)
                        } else {
                            commPortCombo.currentIndex = index
                        }
                    } else {
                        commPortCombo.currentIndex = 0
                    }
                }
            }
        }
        Row {
            spacing:    ScreenTools.defaultFontPixelWidth
            QGCLabel {
                text:   qsTr("波特率:")/*Baud Rate*/
                width:  _firstColumn
                anchors.verticalCenter: parent.verticalCenter
            }
            QGCComboBox {
                id:             baudCombo
                width:          _secondColumn
                model:          QGroundControl.linkManager.serialBaudRates
                anchors.verticalCenter: parent.verticalCenter
                onActivated: {
                    if (index != -1) {
                        subEditConfig.baud = parseInt(QGroundControl.linkManager.serialBaudRates[index])
                    }
                }
                Component.onCompleted: {
                    var baud = "57600"
                    if(subEditConfig != null) {
                        baud = subEditConfig.baud.toString()
                    }
                    var index = baudCombo.find(baud)
                    if (index === -1) {
                        console.warn(qsTr("Baud rate name not in combo box"), baud)
                    } else {
                        baudCombo.currentIndex = index
                    }
                }
            }
        }
        Item {
            height: ScreenTools.defaultFontPixelHeight / 2
            width:  parent.width
        }
        //-----------------------------------------------------------------
        //-- Advanced Serial Settings
//        QGCCheckBox {
//            id:     showAdvanced
//            text:   qsTr("Show Advanced Serial Settings")
//        }
        Item {
            height: ScreenTools.defaultFontPixelHeight / 2
            width:  parent.width
        }
        //-- Flow Control
        QGCCheckBox {
            text:       qsTr("启用流控制:")//qsTr("Enable Flow Control")
            checked:    subEditConfig ? subEditConfig.flowControl !== 0 : false
//            visible:    showAdvanced.checked
            onCheckedChanged: {
                if(subEditConfig) {
                    subEditConfig.flowControl = checked ? 1 : 0
                }
            }
        }
        //-- Parity
        Row {
            spacing:    ScreenTools.defaultFontPixelWidth
//            visible:    showAdvanced.checked
            QGCLabel {
                text:   qsTr("校验:")//Parity
                width:  _firstColumn
                anchors.verticalCenter: parent.verticalCenter
            }
            QGCComboBox {
                id:             parityCombo
                width:          _firstColumn
                model:          [qsTr("None"), qsTr("Even"), qsTr("Odd")]
                anchors.verticalCenter: parent.verticalCenter
                onActivated: {
                    if (index != -1) {
                        // Hard coded values from qserialport.h
                        if(index == 0)
                            subEditConfig.parity = 0
                        else if(index == 1)
                            subEditConfig.parity = 2
                        else
                            subEditConfig.parity = 3
                    }
                }
                Component.onCompleted: {
                    var index = 0
                    if(subEditConfig != null) {
                        index = subEditConfig.parity
                    }
                    if(index > 1) {
                        index = index - 2
                    }
                    parityCombo.currentIndex = index
                }
            }
        }
        //-- Data Bits
        Row {
            spacing:    ScreenTools.defaultFontPixelWidth
//            visible:    showAdvanced.checked
            QGCLabel {
                text:   qsTr("数据位:")//"Data Bits:"
                width:  _firstColumn
                anchors.verticalCenter: parent.verticalCenter
            }
            QGCComboBox {
                id:             dataCombo
                width:          _firstColumn
                model:          ["5", "6", "7", "8"]
                anchors.verticalCenter: parent.verticalCenter
                onActivated: {
                    if (index != -1) {
                        subEditConfig.dataBits = index + 5
                    }
                }
                Component.onCompleted: {
                    var index = 3
                    if(subEditConfig != null) {
                        index = subEditConfig.parity - 5
                        if(index < 0)
                            index = 3
                    }
                    dataCombo.currentIndex = index
                }
            }
        }
        //-- Stop Bits
        Row {
            spacing:    ScreenTools.defaultFontPixelWidth
//            visible:    showAdvanced.checked
            QGCLabel {
                text:   qsTr("停止位:")//qsTr("Stop Bits:")
                width:  _firstColumn
                anchors.verticalCenter: parent.verticalCenter
            }
            QGCComboBox {
                id:             stopCombo
                width:          _firstColumn
                model:          ["1", "2"]
                anchors.verticalCenter: parent.verticalCenter
                onActivated: {
                    if (index != -1) {
                        subEditConfig.stopBits = index + 1
                    }
                }
                Component.onCompleted: {
                    var index = 0
                    if(subEditConfig != null) {
                        index = subEditConfig.stopBits - 1
                        if(index < 0)
                            index = 0
                    }
                    stopCombo.currentIndex = index
                }
            }
        }
    }
}
