/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

QGCView {
    id:         qgcView
    viewPanel:  panel
    // Those user visible strings are hard to translate because we can't send the
    // HTML strings to translation as this can create a security risk. we need to find
    // a better way to hightlight them, or use less hightlights.

    // User visible strings
    readonly property string firwaretitle:             "FIRMWARE"
    readonly property string highlightPrefix:   "<font color=\"" + qgcPal.warningText + "\">"
    readonly property string highlightSuffix:   "</font>"
    readonly property string welcomeText:       qsTr("地面站下载固件")//GroundStation can upgrade the firmware on EWT2.0 devices
    readonly property string plugInText:        "<big>" + highlightPrefix + qsTr("通过USB接入你的设备")+"</big>"//"Plug in your device"+ highlightSuffix + " via USB to " + highlightPrefix + "start" + highlightSuffix + " firmware upgrade.</big>"
    readonly property string flashFailText:     "If upgrade failed, make sure to connect " + highlightPrefix + "directly" + highlightSuffix + " to a powered USB port on your computer, not through a USB hub. " +
                                                "Also make sure you are only powered via USB " + highlightPrefix + "not battery" + highlightSuffix + "."
    readonly property string qgcUnplugText1:    "<big>"+ highlightPrefix+qsTr("通过USB接入你的设备")+"<big>" //////"All GroundStation connections to vehicles must be " + highlightPrefix + " disconnected " + highlightSuffix + "prior to firmware upgrade."
    readonly property string qgcUnplugText2:    highlightPrefix + "<big>"+qsTr("重新连接USB设备.")+"</big>" + highlightSuffix

    readonly property int _defaultFimwareTypePX4:   12
    readonly property int _defaultFimwareTypeAPM:   3

    property var    _defaultFirmwareFact:   QGroundControl.settingsManager.appSettings.defaultFirmwareType
    property bool   _defaultFirmwareIsPX4:  _defaultFirmwareFact.rawValue == _defaultFimwareTypePX4

    property string firmwareWarningMessage
    property bool   controllerCompleted:      false
    property bool   initialBoardSearch:       true
    property string firmwareName

    property bool _singleFirmwareMode: QGroundControl.corePlugin.options.firmwareUpgradeSingleURL.length != 0   ///< true: running in special single firmware download mode

    function cancelFlash() {
        statusTextArea.append(highlightPrefix + qsTr("更新固件取消") + highlightSuffix)//Upgrade cancelled
        statusTextArea.append("------------------------------------------")
        controller.cancel()
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    FirmwareUpgradeController {
        id:             controller
        progressBar:    progressBar
        statusLog:      statusTextArea

        property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

        Component.onCompleted: {
            controllerCompleted = true
            if (qgcView.completedSignalled) {
                // We can only start the board search when the Qml and Controller are completely done loading
                controller.startBoardSearch()
            }
        }

        onActiveVehicleChanged: {
            if (!activeVehicle) {
                statusTextArea.append(plugInText)
            }
        }

        onNoBoardFound: {
            initialBoardSearch = false
            if (!QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                statusTextArea.append(plugInText)
            }
        }

        onBoardGone: {
            initialBoardSearch = false
            if (!QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                statusTextArea.append(plugInText)
            }
        }

        onBoardFound: {
            if (initialBoardSearch) {
                // Board was found right away, so something is already plugged in before we've started upgrade
                statusTextArea.append(qgcUnplugText1)
                statusTextArea.append(qgcUnplugText2)
                QGroundControl.multiVehicleManager.activeVehicle.autoDisconnect = true
            } else {
                // We end up here when we detect a board plugged in after we've started upgrade
                statusTextArea.append(highlightPrefix + qsTr("找到设备") + highlightSuffix + ": " + controller.boardType)
                if (controller.pixhawkBoard || controller.px4FlowBoard) {
                    controller.flash(FirmwareUpgradeController.AutoPilotStackPX4, FirmwareUpgradeController.StableFirmware, FirmwareUpgradeController.DefaultVehicleFirmware)
                    //showDialog(pixhawkFirmwareSelectDialogComponent, firwaretitle, qgcView.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                }
            }
        }

        onError: {
            hideDialog()
            statusTextArea.append(flashFailText)
        }
    }

    onCompleted: {
        if (controllerCompleted) {
            // We can only start the board search when the Qml and Controller are completely done loading
            controller.startBoardSearch()
        }
    }

    Component {
        id: pixhawkFirmwareSelectDialogComponent

        QGCViewDialog {
            id:             pixhawkFirmwareSelectDialog
     //       anchors.fill:   parent
            height:     ScreenTools.defaultFontPixelHeight*20
            property bool showFirmwareTypeSelection:    _advanced.checked
            property bool px4Flow:                      controller.px4FlowBoard

            function updatePX4VersionDisplay() {
                var versionString = ""
                if (_advanced.checked) {
                    switch (controller.selectedFirmwareType) {
                    case FirmwareUpgradeController.StableFirmware:
                        versionString = controller.px4StableVersion
                        break
                    case FirmwareUpgradeController.BetaFirmware:
                        versionString = controller.px4BetaVersion
                        break
                    }
                } else {
                    versionString = controller.px4StableVersion
                }
                px4FlightStack.text = qsTr("EWT2.0 Flight Stack ") + versionString
            }

            Component.onCompleted: updatePX4VersionDisplay()

            function accept() {
                hideDialog()
                if (_singleFirmwareMode) {
                    controller.flashSingleFirmwareMode()
                } else {
                    var stack = apmFlightStack.checked ? FirmwareUpgradeController.AutoPilotStackAPM : FirmwareUpgradeController.AutoPilotStackPX4
                    if (px4Flow) {
                        stack = FirmwareUpgradeController.PX4Flow
                    }

                    var firmwareType = firmwareVersionCombo.model.get(firmwareVersionCombo.currentIndex).firmwareType
                    var vehicleType = FirmwareUpgradeController.DefaultVehicleFirmware
                    if (apmFlightStack.checked) {
                        vehicleType = controller.vehicleTypeFromVersionIndex(vehicleTypeSelectionCombo.currentIndex)
                    }
                    controller.flash(stack, firmwareType, vehicleType)
                }
            }

            function reject() {
                hideDialog()
                cancelFlash()
            }

            ExclusiveGroup {
                id: firmwareGroup
            }

            ListModel {
                id: firmwareTypeList

                ListElement {
                    text:           qsTr("Standard Version (stable)")
                    firmwareType:   FirmwareUpgradeController.StableFirmware
                }
                ListElement {
                    text:           qsTr("Beta Testing (beta)")
                    firmwareType:   FirmwareUpgradeController.BetaFirmware
                }
                ListElement {
                    text:           qsTr("Developer Build (master)")
                    firmwareType:   FirmwareUpgradeController.DeveloperFirmware
                }
                ListElement {
                    text:           qsTr("Custom firmware file...")
                    firmwareType:   FirmwareUpgradeController.CustomFirmware
                }
            }

            ListModel {
                id: px4FlowTypeList

                ListElement {
                    text:           qsTr("Standard Version (stable)")
                    firmwareType:   FirmwareUpgradeController.StableFirmware
                }
                ListElement {
                    text:           qsTr("Custom firmware file...")
                    firmwareType:   FirmwareUpgradeController.CustomFirmware
                }
            }

            ListModel {
                id: singleFirmwareModeTypeList

                ListElement {
                    text:           qsTr("Standard Version")
                    firmwareType:   FirmwareUpgradeController.StableFirmware
                }
                ListElement {
                    text:           qsTr("Custom firmware file...")
                    firmwareType:   FirmwareUpgradeController.CustomFirmware
                }
            }

            Column {
                anchors.fill:   parent
                spacing:        defaultTextHeight

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       _singleFirmwareMode ? _singleFirmwareLabel : (px4Flow ? _px4FlowLabel : _pixhawkLabel)

                    readonly property string _px4FlowLabel:          qsTr("Detected PX4 Flow board. You can select from the following firmware:")
                    readonly property string _pixhawkLabel:          qsTr("Detected Pixhawk board. You can select from the following flight stacks:")
                    readonly property string _singleFirmwareLabel:   qsTr("Press Ok to upgrade your vehicle.")
                }

                function firmwareVersionChanged(model) {
                    firmwareVersionWarningLabel.visible = false
                    // All of this bizarre, setting model to null and index to 1 and then to 0 is to work around
                    // strangeness in the combo box implementation. This sequence of steps correctly changes the combo model
                    // without generating any warnings and correctly updates the combo text with the new selection.
                    firmwareVersionCombo.model = null
                    firmwareVersionCombo.model = model
                    firmwareVersionCombo.currentIndex = 1
                    firmwareVersionCombo.currentIndex = 0
                }

                Component.onCompleted: {
                    if (_defaultFirmwareIsPX4) {
                        px4FlightStack.checked = true
                    } else {
                        apmFlightStack.checked = true
                    }
                }

                QGCRadioButton {
                    id:             px4FlightStack
                    exclusiveGroup: firmwareGroup
                    text:           qsTr("EWT2.0 Flight Stack ")
                    visible:        !_singleFirmwareMode && !px4Flow

                    onClicked: {
                        _defaultFirmwareFact.rawValue = _defaultFimwareTypePX4
                        parent.firmwareVersionChanged(firmwareTypeList)
                    }
                }

                QGCRadioButton {
                    id:             apmFlightStack
                    exclusiveGroup: firmwareGroup
                    text:           qsTr("ArduPilot Flight Stack")
                    visible:        !_singleFirmwareMode && !px4Flow

                    onClicked: {
                        _defaultFirmwareFact.rawValue = _defaultFimwareTypeAPM
                        parent.firmwareVersionChanged(firmwareTypeList)
                    }
                }

                QGCComboBox {
                    id:             vehicleTypeSelectionCombo
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    visible:        apmFlightStack.checked
                    model:          controller.apmAvailableVersions
                }

                Row {
                    width:      parent.width
                    spacing:    ScreenTools.defaultFontPixelWidth / 2
                    visible:    !px4Flow

                    Rectangle {
                        height: 1
                        width:      ScreenTools.defaultFontPixelWidth * 5
                        color:      qgcPal.text
                        anchors.verticalCenter: _advanced.verticalCenter
                    }

                    QGCCheckBox {
                        id:         _advanced
                        text:       qsTr("Advanced settings")
                        checked:    px4Flow ? true : false

                        onClicked: {
                            firmwareVersionCombo.currentIndex = 0
                            firmwareVersionWarningLabel.visible = false
                            updatePX4VersionDisplay()
                        }
                    }

                    Rectangle {
                        height:     1
                        width:      ScreenTools.defaultFontPixelWidth * 5
                        color:      qgcPal.text
                        anchors.verticalCenter: _advanced.verticalCenter
                    }
                }

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    visible:    showFirmwareTypeSelection
                    text:       px4Flow ? qsTr("Select which version of the firmware you would like to install:") : qsTr("Select which version of the above flight stack you would like to install:")
                }

                QGCComboBox {
                    id:             firmwareVersionCombo
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    visible:        showFirmwareTypeSelection
                    model:          _singleFirmwareMode ? singleFirmwareModeTypeList: (px4Flow ? px4FlowTypeList : firmwareTypeList)
                    currentIndex:   controller.selectedFirmwareType

                    onActivated: {
                        controller.selectedFirmwareType = index
                        if (model.get(index).firmwareType == FirmwareUpgradeController.BetaFirmware) {
                            firmwareVersionWarningLabel.visible = true
                            firmwareVersionWarningLabel.text = qsTr("WARNING: BETA FIRMWARE. ") +
                                    qsTr("This firmware version is ONLY intended for beta testers. ") +
                                    qsTr("Although it has received FLIGHT TESTING, it represents actively changed code. ") +
                                    qsTr("Do NOT use for normal operation.")
                        } else if (model.get(index).firmwareType == FirmwareUpgradeController.DeveloperFirmware) {
                            firmwareVersionWarningLabel.visible = true
                            firmwareVersionWarningLabel.text = qsTr("WARNING: CONTINUOUS BUILD FIRMWARE. ") +
                                    qsTr("This firmware has NOT BEEN FLIGHT TESTED. ") +
                                    qsTr("It is only intended for DEVELOPERS. ") +
                                    qsTr("Run bench tests without props first. ") +
                                    qsTr("Do NOT fly this without additional safety precautions. ") +
                                    qsTr("Follow the mailing list actively when using it.")
                        } else {
                            firmwareVersionWarningLabel.visible = false
                        }
                        updatePX4VersionDisplay()
                    }
                }

                QGCLabel {
                    id:         firmwareVersionWarningLabel
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    visible:    false
                }
            } // Column
        } // QGCViewDialog
    } // Component - pixhawkFirmwareSelectDialogComponent

    Component {
        id: firmwareWarningDialog

        QGCViewMessage {
            message: firmwareWarningMessage

            function accept() {
                hideDialog()
                controller.doFirmwareUpgrade();
            }
        }
    }

    QGCViewPanel {
        id:             panel
        anchors.fill:   parent
        //        ProgressBar {
        //            id:                 progressBar
        //            anchors.topMargin:  ScreenTools.defaultFontPixelHeight
        //            anchors.top:        titleLabel.bottom
        //            width:              parent.width
        //        }
        Rectangle {
            id:                         title
            anchors.top:                parent.top
            anchors.horizontalCenter:   parent.horizontalCenter
            width:                  parent.width
            height:                 ScreenTools.defaultFontPixelHeight*10
            color:                  "transparent"
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
                source:     "/qmlimages/FirmwareUpgradeIcon.svg"
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
                text:           qsTr("固件下载")//"Systemseting"
                font.pointSize: ScreenTools.mediumFontPointSize
                font.bold:              true
                color:          qgcPal.text
                anchors.verticalCenter: setimg.verticalCenter
            }
        }

        QGCProgressBar
        {
            id:                 progressBar
            anchors.top:        title.bottom
            anchors.topMargin: ScreenTools.defaultFontPixelHeight*4
            anchors.horizontalCenter:   parent.horizontalCenter
            width:              ScreenTools.defaultFontPixelHeight*16
            height:             ScreenTools.defaultFontPixelHeight*16
            test:               qsTr("Firmware")
            value:              0.0
        }
        TextArea {
            id:                 statusTextArea
            anchors.top:        progressBar.bottom
            anchors.bottom:     parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            width:              parent.width*0.8
            readOnly:           true
            frameVisible:       false
            font.pointSize:     ScreenTools.defaultFontPointSize
            textFormat:         TextEdit.RichText
            text:               welcomeText

            style: TextAreaStyle {
                textColor:          qgcPal.text
                backgroundColor:    qgcPal.windowShade
            }
        }

    } // QGCViewPabel
} // QGCView
