﻿/****************************************************************************
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
import QtQuick.Dialogs          1.2
import QtMultimedia             5.5
import QtQuick.Layouts          1.2

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controllers           1.0
import QGroundControl.SettingsManager       1.0

QGCView {
    id:                 _qgcView
    viewPanel:          panel
    color:              qgcPal.window
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    property Fact _percentRemainingAnnounce:    QGroundControl.settingsManager.appSettings.batteryPercentRemainingAnnounce
    property Fact _savePath:                    QGroundControl.settingsManager.appSettings.savePath
    property Fact _appFontPointSize:            QGroundControl.settingsManager.appSettings.appFontPointSize
    property real _labelWidth:                  ScreenTools.defaultFontPixelWidth * 15
    property real _editFieldWidth:              ScreenTools.defaultFontPixelWidth * 30
    property Fact _videoPath:                   QGroundControl.settingsManager.videoSettings.videoSavePath
    property Fact _mapProvider:                 QGroundControl.settingsManager.flightMapSettings.mapProvider
    property Fact _mapType:                     QGroundControl.settingsManager.flightMapSettings.mapType

    readonly property string _requiresRestart:  qsTr("(Requires Restart)")

    QGCPalette { id: qgcPal }

    QGCViewPanel {
        id:             panel
        anchors.fill:   parent
        Rectangle {
            id:         title
            anchors.top:        parent.top
            width:      parent.width
            height:     ScreenTools.defaultFontPixelHeight*8
            color:      "transparent"
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
                text:           qsTr("系统设置")//"Systemseting"
                font.pointSize: ScreenTools.mediumFontPointSize
                font.bold:              true
                color:          qgcPal.text
                anchors.verticalCenter: setimg.verticalCenter
            }
        }
        QGCFlickable {
            clip:               true
            anchors.top:        title.bottom
            width:              parent.width
            height:             parent.height -ScreenTools.defaultFontPixelWidth*20
            contentHeight:      settingsColumn.height+ScreenTools.defaultFontPixelWidth*2
            contentWidth:       _qgcView.width
            flickableDirection: Flickable.VerticalFlick
            Column {
                id:                 settingsColumn
                width:              _qgcView.width
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                anchors.margins:    ScreenTools.defaultFontPixelWidth
                anchors.top:        parent.top
                //-----------------------------------------------------------------
                //-- Units
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     unitLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false//QGroundControl.settingsManager.unitsSettings.visible
                    QGCLabel {
                        id:             unitLabel
                        text:           qsTr("Units (Requires Restart)")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     unitsCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.unitsSettings.visible
                    Column {
                        id:         unitsCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent

                        Repeater {
                            id:     unitsRepeater
                            model:  [ QGroundControl.settingsManager.unitsSettings.distanceUnits, QGroundControl.settingsManager.unitsSettings.areaUnits, QGroundControl.settingsManager.unitsSettings.speedUnits ]

                            property var names: [ qsTr("距离:"), qsTr("面积:"), qsTr("速度:") ]

                            Row {
                                spacing:    ScreenTools.defaultFontPixelWidth
                                visible:    modelData.visible

                                QGCLabel {
                                    width:              _labelWidth
                                    anchors.baseline:   factCombo.baseline
                                    text:               unitsRepeater.names[index]
                                }
                                FactComboBox {
                                    id:                 factCombo
                                    width:              _editFieldWidth
                                    fact:               modelData
                                    indexModel:         false
                                }
                            }
                        }
                    }
                }

                //-----------------------------------------------------------------
                //-- Miscellanous
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     miscLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false//QGroundControl.settingsManager.appSettings.visible
                    QGCLabel {
                        id:             miscLabel
                        text:           qsTr("Miscellaneous")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     miscCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.appSettings.visible
                    Column {
                        id:         miscCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent
                        //-----------------------------------------------------------------
                        //-- Base UI Font Point Size
                        Row {
                            visible: _appFontPointSize ? _appFontPointSize.visible : false
                            spacing: ScreenTools.defaultFontPixelWidth
                            QGCLabel {
                                id:     baseFontLabel
                                text:   qsTr("字体大小:")
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
                                    onClicked: {
                                        if (_appFontPointSize.value > _appFontPointSize.min) {
                                            _appFontPointSize.value = _appFontPointSize.value - 1
                                        }
                                    }
                                }
                                FactTextField {
                                    id:     baseFontEdit
                                    width:  _editFieldWidth - (decrementButton.width * 2) - (baseFontRow.spacing * 2)
                                    fact:   QGroundControl.settingsManager.appSettings.appFontPointSize
                                }
                                QGCButton {
                                    width:  height
                                    height: baseFontEdit.height
                                    text:   "+"
                                    onClicked: {
                                        if (_appFontPointSize.value < _appFontPointSize.max) {
                                            _appFontPointSize.value = _appFontPointSize.value + 1
                                        }
                                    }
                                }
                            }
                            QGCLabel {
                                anchors.verticalCenter: parent.verticalCenter
                                text:                   _requiresRestart
                                visible:                false
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Palette Styles
                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth
                            visible: false//QGroundControl.settingsManager.appSettings.indoorPalette.visible
                            QGCLabel {
                                text:           qsTr("Color scheme:")
                                width:          _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                width:          _editFieldWidth
                                fact:           QGroundControl.settingsManager.appSettings.indoorPalette
                                indexModel:     false
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Map Provider 
                        Row {
                            id:         map
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    _mapProvider.visible
                            QGCLabel {
                                anchors.verticalCenter: parent.verticalCenter
                                text:               qsTr("地图")//qsTr("Map Provider:")
                            }
                            ExclusiveGroup { id: mapActionGroup }
                            ImageButton{
                                imageResource:        "/qmlimages/bingmap.png"
                                exclusiveGroup:      mapActionGroup
                                width:               ScreenTools.defaultFontPixelHeight * 5
                                height:              ScreenTools.defaultFontPixelHeight * 4
                                imageResource2:             "/qmlimages/checked.svg"
                                img2visible:        true
                                checkable:          true
                                checked:            _mapProvider.value==0
                                onClicked: {
                                   _mapProvider.value=0
                                }
                            }
                            ImageButton{
                                imageResource:             "/qmlimages/googlemap.png"
                                exclusiveGroup:     mapActionGroup
                                width:              ScreenTools.defaultFontPixelHeight * 5
                                height:             ScreenTools.defaultFontPixelHeight * 4
                                imageResource2:             "/qmlimages/checked.svg"
                                img2visible:        true
                                checkable:          true
                                checked:            _mapProvider.value==1
                                onClicked: {
                                    _mapProvider.value=1
                                }
                            }
                            ImageButton{
                                imageResource:             "/qmlimages/gaodemap.png"
                                exclusiveGroup:     mapActionGroup
                                width:              ScreenTools.defaultFontPixelHeight * 5
                                height:             ScreenTools.defaultFontPixelHeight * 4
                                imageResource2:             "/qmlimages/checked.svg"
                                img2visible:        true
                                checkable:          true
                                checked:            _mapProvider.value==2
                                onClicked: {
                                   _mapProvider.value=2
                                }
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    _mapProvider.visible
                            QGCLabel {
                                text:       qsTr("地图提供商:")
                                width:      _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                width:      _editFieldWidth
                                fact:       _mapProvider
                                indexModel: false
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Map Type
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    false//_mapType.visible
                            QGCLabel {
                                text:               qsTr("Map Type:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                id:         mapTypes
                                width:      _editFieldWidth
                                fact:       _mapType
                                indexModel: false
                                anchors.verticalCenter: parent.verticalCenter
                                Connections {
                                    target: QGroundControl.settingsManager.flightMapSettings
                                    onMapTypeChanged: {
                                        mapTypes.model = _mapType.enumStrings
                                    }
                                }
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Audio preferences
                        FactCheckBox {
                            text:       qsTr("Mute all audio output")
                            fact:       _audioMuted
                            visible:    false//_audioMuted.visible
                            property Fact _audioMuted: QGroundControl.settingsManager.appSettings.audioMuted
                        }
                        //-----------------------------------------------------------------
                        //-- Save telemetry log
                        FactCheckBox {
                            id:         promptSaveLog
                            text:       qsTr("在每次飞行中存储飞行日志")//"Prompt to save Flight Data Log after each flight"
                            fact:       _telemetrySave
                            visible:    !ScreenTools.isMobile && _telemetrySave.visible
                            property Fact _telemetrySave: QGroundControl.settingsManager.appSettings.telemetrySave
                        }
                        //-----------------------------------------------------------------
                        //-- Save even if not armed
                        FactCheckBox {
                            text:       qsTr("即使未解锁也存储飞行日志")//"Prompt to save Flight Data Log even if vehicle was not armed"
                            fact:       _telemetrySaveNotArmed
                            visible:    !ScreenTools.isMobile && _telemetrySaveNotArmed.visible
                            enabled:    promptSaveLog.checked
                            property Fact _telemetrySaveNotArmed: QGroundControl.settingsManager.appSettings.telemetrySaveNotArmed
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
                            visible: false
                            QGCCheckBox {
                                id:                 announcePercentCheckbox
                                text:               qsTr("Announce battery lower than:")
                                checked:            _percentRemainingAnnounce.value !== 0
                                width:              (_labelWidth + _editFieldWidth) * 0.65
                                anchors.verticalCenter: parent.verticalCenter
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
                                width:              (_labelWidth + _editFieldWidth) * 0.35
                                enabled:            announcePercentCheckbox.checked
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Virtual joystick settings
                        FactCheckBox {
                            text:       qsTr("Virtual Joystick")
                            visible:    false//_virtualJoystick.visible
                            fact:       _virtualJoystick

                            property Fact _virtualJoystick: QGroundControl.settingsManager.appSettings.virtualJoystick
                        }
                        //-----------------------------------------------------------------
                        //-- Default mission item altitude
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    false//QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude.visible
                            QGCLabel {
                                anchors.verticalCenter: parent.verticalCenter
                                width:  (_labelWidth + _editFieldWidth) * 0.65
                                text:   qsTr("默认任务高度:")
                            }
                            FactTextField {
                                id:     defaultItemAltitudeField
                                width:  (_labelWidth + _editFieldWidth) * 0.35
                                fact:   QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        //-----------------------------------------------------------------
                        //-- Mission AutoLoad
                        FactCheckBox {
                            text:       qsTr("AutoLoad missions")
                            fact:       _autoLoad
                            visible:    false//_autoLoad.visible

                            property Fact _autoLoad: QGroundControl.settingsManager.appSettings.autoLoadMissions
                        }

                        //-----------------------------------------------------------------
                        //-- Save path
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    false//_savePath.visible

                            QGCLabel {
                                anchors.baseline:   savePathBrowse.baseline
                                text:               qsTr("File save path:")
                            }
                            QGCLabel {
                                anchors.baseline:   savePathBrowse.baseline
                                text:               _savePath.rawValue === "" ? qsTr("<not set>") : _savePath.value
                            }
                            QGCButton {
                                id:         savePathBrowse
                                text:       "Browse"
                                onClicked:  savePathBrowseDialog.openForLoad()

                                QGCFileDialog {
                                    id:             savePathBrowseDialog
                                    qgcView:        _qgcView
                                    title:          qsTr("Choose the location to save files:")
                                    folder:         _savePath.rawValue
                                    selectExisting: true
                                    selectFolder:   true

                                    onAcceptedForLoad: _savePath.rawValue = file
                                }
                            }
                        }
                    }
                }

                //-----------------------------------------------------------------
                //-- Autoconnect settings
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     autoConnectLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false//QGroundControl.settingsManager.autoConnectSettings.visible
                    QGCLabel {
                        id:             autoConnectLabel
                        text:           qsTr("AutoConnect to the following devices:")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     autoConnectCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false//QGroundControl.settingsManager.autoConnectSettings.visible

                    Column {
                        id:         autoConnectCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth * 2

                            Repeater {
                                id:     autoConnectRepeater
                                model:  [ QGroundControl.settingsManager.autoConnectSettings.autoConnectPixhawk,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectSiKRadio,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectPX4Flow,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectLibrePilot,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectUDP,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectRTKGPS
                                ]

                                property var names: [ qsTr("Pixhawk"), qsTr("SiK Radio"), qsTr("PX4 Flow"), qsTr("LibrePilot"), qsTr("UDP"), qsTr("RTK GPS") ]

                                FactCheckBox {
                                    text:       autoConnectRepeater.names[index]
                                    fact:       modelData
                                    visible:    !ScreenTools.isiOS && modelData.visible
                                }
                            }
                        }
                    }
                }

                //-----------------------------------------------------------------
                //-- Video Source
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     videoLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false//QGroundControl.settingsManager.videoSettings.visible
                    QGCLabel {
                        id:             videoLabel
                        text:           qsTr("Video (Requires Restart)")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     videoCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.videoSettings.visible

                    Column {
                        id:         videoCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent


                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.videoSource.visible
                            QGCLabel {
                                anchors.baseline:   videoSource.baseline
                                text:               qsTr("视频源:")
                                width:              _labelWidth
                            }
                            FactComboBox {
                                id:         videoSource
                                width:      _editFieldWidth
                                indexModel: false
                                fact:       QGroundControl.settingsManager.videoSettings.videoSource
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.udpPort.visible && QGroundControl.videoManager.isGStreamer && videoSource.currentIndex === 0
                            QGCLabel {
                                anchors.baseline:   udpField.baseline
                                text:               qsTr("UDP 端口:")
                                width:              _labelWidth
                            }
                            FactTextField {
                                id:                 udpField
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.udpPort
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.rtspUrl.visible && QGroundControl.videoManager.isGStreamer && videoSource.currentIndex === 1
                            QGCLabel {
                                anchors.baseline:   rtspField.baseline
                                text:               qsTr("RTSP URL:")
                                width:              _labelWidth
                            }
                            FactTextField {
                                id:                 rtspField
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.rtspUrl
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex < 2 && QGroundControl.settingsManager.videoSettings.aspectRatio.visible
                            QGCLabel {
                                anchors.baseline:   aspectField.baseline
                                text:               qsTr("Aspect Ratio:")
                                width:              _labelWidth
                            }
                            FactTextField {
                                id:                 aspectField
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.aspectRatio
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex < 2 && QGroundControl.settingsManager.videoSettings.gridLines.visible
                            QGCLabel {
                                anchors.baseline:   gridField.baseline
                                text:               qsTr("Grid Lines:")
                                width:              _labelWidth
                            }
                            FactComboBox {
                                id:                 gridField
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.gridLines
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.videoSavePath.visible && QGroundControl.videoManager.isGStreamer && QGroundControl.videoManager.recordingEnabled

                            QGCLabel {
                                anchors.baseline:   videoBrowse.baseline
                                text:               qsTr("保存路径:")
                                enabled:            promptSaveLog.checked
                            }
                            QGCLabel {
                                anchors.baseline:   videoBrowse.baseline
                                text:               _videoPath.value == "" ? qsTr("<not set>") : _videoPath.value
                            }
                            QGCButton {
                                id:         videoBrowse
                                text:       qsTr("选择:")//"Browse"
                                onClicked:  videoDialog.openForLoad()

                                QGCFileDialog {
                                    id:             videoDialog
                                    title:          qsTr("选择一个路径保存视频文件:")//"Choose a location to save video files."
                                    folder:         "file://" + _videoPath.value
                                    selectFolder:   true

                                    onAcceptedForLoad: {
                                        _videoPath.value = file
                                    }
                                }
                            }
                        }
                    }
                } // Video Source - Rectangle

                QGCLabel {
                    anchors.horizontalCenter:   parent.horizontalCenter
                    text:                       qsTr("%1 Version: %2").arg(QGroundControl.appName).arg(QGroundControl.qgcVersion)
                    visible:                    false
                }
            } // settingsColumn
        } // QGCFlickable
    } // QGCViewPanel
} // QGCView
