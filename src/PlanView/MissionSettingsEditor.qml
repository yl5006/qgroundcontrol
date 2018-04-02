import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Vehicle           1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactSystem        1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0
import QGroundControl.SettingsManager   1.0
import QGroundControl.Controllers       1.0

// Editor for Mission Settings
Rectangle {
    id:                 valuesRect
    width:              availableWidth
    height:             valuesColumn.height + (_margin * 2)
    color:              qgcPal.windowShadeDark
    visible:            missionItem.isCurrentItem
    radius:             _margin/2

    property var    _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle
    property var    _masterControler:               masterController
    property var    _missionController:             _masterControler.missionController
    property var    _missionVehicle:                _masterControler.controllerVehicle
    property bool   _vehicleHasHomePosition:        _missionVehicle.homePosition.isValid
    property bool   _offlineEditing:                _missionVehicle.isOfflineEditingVehicle
    property bool   _showOfflineVehicleCombos:      _multipleFirmware
    property bool   _enableOfflineVehicleCombos:    _offlineEditing && _noMissionItemsAdded
    property bool   _showCruiseSpeed:               !_missionVehicle.multiRotor
    property bool   _showHoverSpeed:                _missionVehicle.multiRotor || _missionVehicle.vtol
    property bool   _multipleFirmware:              QGroundControl.supportedFirmwareCount > 2
    property real   _fieldWidth:                    ScreenTools.defaultFontPixelWidth * 16
    property bool   _mobile:                        ScreenTools.isMobile
    property var    _savePath:                      QGroundControl.settingsManager.appSettings.missionSavePath
    property var    _fileExtension:                 QGroundControl.settingsManager.appSettings.missionFileExtension
    property var    _appSettings:                   QGroundControl.settingsManager.appSettings
    property bool   _waypointsOnlyMode:             QGroundControl.corePlugin.options.missionWaypointsOnly
    property bool   _showCameraSection:             !_waypointsOnlyMode || QGroundControl.corePlugin.showAdvancedUI

    property Fact   _offlinespeed:              _showCruiseSpeed ? QGroundControl.settingsManager.appSettings.offlineEditingCruiseSpeed : QGroundControl.settingsManager.appSettings.offlineEditingHoverSpeed
    readonly property string _firmwareLabel:    qsTr("Firmware")
    readonly property string _vehicleLabel:     qsTr("Vehicle")
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2

    QGCPalette { id: qgcPal }
    QGCFileDialogController { id: fileController }

    Column {
        id:                 valuesColumn
        anchors.margins:    _margin
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        parent.top
        spacing:            _margin

            Column {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin

                GridLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    columnSpacing:  ScreenTools.defaultFontPixelWidth
                    rowSpacing:     columnSpacing
                    columns:        2

                    QGCLabel {
                        text:               qsTr("航点高度:")
                    }
                    FactTextField {
                        fact:               QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude
                        Layout.fillWidth:   true
                    }
                    QGCLabel {
                        text:               qsTr("飞行速度")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               _activeVehicle&&QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable ? missionItem.speedSection.flightSpeed : _offlinespeed
                        Layout.fillWidth:   true
                    }	
    /*
                    QGCCheckBox {
                        id:         flightSpeedCheckBox
                        text:       qsTr("Flight speed")
                        visible:    !_missionVehicle.vtol
                        checked:    missionItem.speedSection.specifyFlightSpeed
                        onClicked:  missionItem.speedSection.specifyFlightSpeed = checked
                    }
                    FactTextField {
                        fact:               _activeVehicle ? missionItem.speedSection.flightSpeed : _offlinespeed
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        Layout.fillWidth:   true
                        fact:               missionItem.speedSection.flightSpeed
                        visible:            flightSpeedCheckBox.visible
                        enabled:            flightSpeedCheckBox.checked
                    }
*/
                } // GridLayout
            }

            CameraSection {
                id:         cameraSection
                checked:    missionItem.cameraSection.settingsSpecified
            	visible:    _showCameraSection
            }

            QGCLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                text:                   qsTr("相机控制命令在任务开始时立即执行.")
                wrapMode:               Text.WordWrap
                horizontalAlignment:    Text.AlignHCenter
                font.pointSize:         ScreenTools.smallFontPointSize
            	visible:                _showCameraSection && cameraSection.checked
            }

//            SectionHeader {
//                id:         missionEndHeader
//                text:       qsTr("Mission End")
//                checked:    true
//            }

//            Column {
//                anchors.left:   parent.left
//                anchors.right:  parent.right
//                spacing:        _margin
//                visible:        missionEndHeader.checked

                QGCCheckBox {
                    text:       qsTr("任务结束后返航")
                    checked:    missionItem.missionEndRTL
                    onClicked:  missionItem.missionEndRTL = checked
                }
//            }


            SectionHeader {
                id:         vehicleInfoSectionHeader
                text:       qsTr("机体信息")
                visible:    false//_offlineEditing && !_waypointsOnlyMode
                checked:    false
            }

            GridLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                columnSpacing:  ScreenTools.defaultFontPixelWidth
                rowSpacing:     columnSpacing
                columns:        2
                visible:        vehicleInfoSectionHeader.visible && vehicleInfoSectionHeader.checked

                QGCLabel {
                    text:               _firmwareLabel
                    Layout.fillWidth:   true
                    visible:            _showOfflineVehicleCombos
                }
                FactComboBox {
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingFirmwareType
                    indexModel:             false
                    Layout.preferredWidth:  _fieldWidth
                    visible:                _showOfflineVehicleCombos
                    enabled:                _enableOfflineVehicleCombos
                }

                QGCLabel {
                    text:               _vehicleLabel
                    Layout.fillWidth:   true
                    visible:            _showOfflineVehicleCombos
                }
                FactComboBox {
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingVehicleType
                    indexModel:             false
                    Layout.preferredWidth:  _fieldWidth
                    visible:                _showOfflineVehicleCombos
                    enabled:                _enableOfflineVehicleCombos
                }

                QGCLabel {
                    text:               qsTr("巡航速度")
                    visible:            _showCruiseSpeed
                    Layout.fillWidth:   true
                }
                FactTextField {
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingCruiseSpeed
                    visible:                _showCruiseSpeed
                    Layout.preferredWidth:  _fieldWidth
                }

                QGCLabel {
                    text:               qsTr("Hover speed")
                    visible:            _showHoverSpeed
                    Layout.fillWidth:   true
                }
                FactTextField {
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingHoverSpeed
                    visible:                _showHoverSpeed
                    Layout.preferredWidth:  _fieldWidth
                }
            } // GridLayout

            SectionHeader {
                id:         plannedHomePositionSection
                text:       qsTr("Home点位置")
                visible:    !_vehicleHasHomePosition
                checked:    false
            }

            Column {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin
                visible:        plannedHomePositionSection.checked && !_vehicleHasHomePosition

                GridLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    columnSpacing:  ScreenTools.defaultFontPixelWidth
                    rowSpacing:     columnSpacing
                    columns:        2

                    QGCLabel {
                        text: qsTr("高度")
                    }
                    FactTextField {
                        fact:               missionItem.plannedHomePositionAltitude
                        Layout.fillWidth:   true
                    }
                }

                QGCLabel {
                    width:                  parent.width
                    wrapMode:               Text.WordWrap
                    font.pointSize:         ScreenTools.smallFontPointSize
                    text:                   qsTr("实际位置由飞行确定.")
                    horizontalAlignment:    Text.AlignHCenter
                }

                QGCButton {
                    text:                       qsTr("移动Home到地图中心")
                    onClicked:                  missionItem.coordinate = map.center
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }
        } // Column
} // Rectangle
