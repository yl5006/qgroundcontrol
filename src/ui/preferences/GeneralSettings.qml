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
    property Fact _userBrandImageIndoor:        QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor
    property Fact _userBrandImageOutdoor:       QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor
    property real _labelWidth:                  ScreenTools.defaultFontPixelWidth * 20
    property real _editFieldWidth:              ScreenTools.defaultFontPixelWidth * 30
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
                    visible:                    false//QGroundControl.settingsManager.unitsSettings.visible
                    Column {
                        id:         unitsCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent

                        Repeater {
                            id:     unitsRepeater
                            model:  [ QGroundControl.settingsManager.unitsSettings.distanceUnits, QGroundControl.settingsManager.unitsSettings.areaUnits, QGroundControl.settingsManager.unitsSettings.speedUnits, QGroundControl.settingsManager.unitsSettings.temperatureUnits ]

                            property var names: [ qsTr("距离:"), qsTr("面积:"), qsTr("速度:"), qsTr("温度:") ]

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
                //-- Miscellaneous
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
                                text:           qsTr("Color Scheme:")
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
                                imageResource:       "/qmlimages/bingmap.png"
                                exclusiveGroup:      mapActionGroup
                                width:               ScreenTools.defaultFontPixelHeight * 5
                                height:              ScreenTools.defaultFontPixelHeight * 4
                                imageResource2:      "/qmlimages/checked.svg"
                                img2visible:        true
                                checkable:          true
                                checked:            _mapProvider.value==0
                                onClicked: {
                                   _mapProvider.value=0
                                }
                            }
                            ImageButton{
                                imageResource:      "/qmlimages/googlemap.png"
                                exclusiveGroup:     mapActionGroup
                                width:              ScreenTools.defaultFontPixelHeight * 5
                                height:             ScreenTools.defaultFontPixelHeight * 4
                                imageResource2:     "/qmlimages/checked.svg"
                                img2visible:        true
                                checkable:          true
                                checked:            _mapProvider.value==1
                                onClicked: {
                                    _mapProvider.value=1
                                }
                            }
                            ImageButton{
                                imageResource:      "/qmlimages/gaodemap.png"
                                exclusiveGroup:     mapActionGroup
                                width:              ScreenTools.defaultFontPixelHeight * 5
                                height:             ScreenTools.defaultFontPixelHeight * 4
                                imageResource2:     "/qmlimages/checked.svg"
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
                            visible:    false//_mapProvider.visible
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
                                        console.log(_mapType.enumStrings)
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
                            visible:    _telemetrySave.visible
                            property Fact _telemetrySave: QGroundControl.settingsManager.appSettings.telemetrySave
                        }
                        //-----------------------------------------------------------------
                        //-- Save even if not armed
                        FactCheckBox {
                            text:       qsTr("即使未解锁也存储飞行日志")//"Prompt to save Flight Data Log even if vehicle was not armed"
                            fact:       _telemetrySaveNotArmed
                            visible:    _telemetrySaveNotArmed.visible
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
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible: false//visible:    QGroundControl.settingsManager.appSettings.batteryPercentRemainingAnnounce.visible
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
                            text:       qsTr("AutoLoad Missions")
                            fact:       _autoLoad
                            visible:    false//_autoLoad.visible

                            property Fact _autoLoad: QGroundControl.settingsManager.appSettings.autoLoadMissions
                        }

                        //-----------------------------------------------------------------
                        //-- Save path
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:     false//_savePath.visible && !ScreenTools.isMobile

                            QGCLabel {
                                anchors.baseline:   savePathBrowse.baseline
                                text:               qsTr("File Save Path:")
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
                //-- RTK GPS
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     unitLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false//QGroundControl.settingsManager.rtkSettings.visible
                    QGCLabel {
                        id:             rtkLabel
                        text:           qsTr("RTK GPS (Requires Restart)")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     rtkGrid.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.rtkSettings.visible
                    GridLayout {
                        id:                 rtkGrid
                        anchors.centerIn:   parent
                        columns:            2
                        rowSpacing:         ScreenTools.defaultFontPixelWidth
                        columnSpacing:      ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            text:               qsTr("RTK精确度:")
                        }
                        FactTextField {
                            fact:               QGroundControl.settingsManager.rtkSettings.surveyInAccuracyLimit
                        }

                        QGCLabel {
                            text:               qsTr("RTK最小平均观察时间:")
                        }
                        FactTextField {
                            fact:               QGroundControl.settingsManager.rtkSettings.surveyInMinObservationDuration
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
                    visible:                    QGroundControl.settingsManager.autoConnectSettings.visible

                    Column {
                        id:         autoConnectCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth * 2

                            Repeater {
                                id:     autoConnectRepeater
                                model:  [// QGroundControl.settingsManager.autoConnectSettings.autoConnectPixhawk,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectSiKRadio,
                                    //QGroundControl.settingsManager.autoConnectSettings.autoConnectPX4Flow,
                                    //QGroundControl.settingsManager.autoConnectSettings.autoConnectLibrePilot,
                                    //QGroundControl.settingsManager.autoConnectSettings.autoConnectUDP,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectRTKGPS
                                ]

                                property var names: [ /*qsTr("Pixhawk"),*/ qsTr("自动连接数传"),/* qsTr("PX4 Flow"), qsTr("LibrePilot"), qsTr("UDP"), */qsTr("自动连接 RTK GPS") ]

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
                        text:           qsTr("Video")
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
                                text:               qsTr("视频源:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                id:         videoSource
                                width:      _editFieldWidth
                                indexModel: false
                                fact:       QGroundControl.settingsManager.videoSettings.videoSource
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.udpPort.visible && QGroundControl.videoManager.isGStreamer && videoSource.currentIndex === 1
                            QGCLabel {
                                text:               qsTr("UDP 端口:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactTextField {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.udpPort
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.rtspUrl.visible && QGroundControl.videoManager.isGStreamer && videoSource.currentIndex === 2
                            QGCLabel {
                                anchors.verticalCenter: parent.verticalCenter
                                text:               qsTr("RTSP URL:")
                                width:              _labelWidth
                            }
                            FactTextField {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.rtspUrl
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.tcpUrl.visible && QGroundControl.videoManager.isGStreamer && videoSource.currentIndex === 3
                            QGCLabel {
                                text:               qsTr("TCP URL:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactTextField {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.tcpUrl
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex && videoSource.currentIndex < 3 && QGroundControl.settingsManager.videoSettings.aspectRatio.visible
                            QGCLabel {
                                text:               qsTr("长宽比:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactTextField {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.aspectRatio
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex && videoSource.currentIndex < 3 && QGroundControl.settingsManager.videoSettings.gridLines.visible
                            QGCLabel {
                                text:               qsTr("解锁时禁用:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactCheckBox {
                                text:                   ""
                                fact:                   QGroundControl.settingsManager.videoSettings.disableWhenDisarmed
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                } // Video Source - Rectangle
                //-----------------------------------------------------------------
                //-- Video Source
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     videoRecLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false//QGroundControl.settingsManager.videoSettings.visible
                    QGCLabel {
                        id:             videoRecLabel
                        text:           qsTr("视频录制")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     videoRecCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.videoSettings.visible

                    Column {
                        id:         videoRecCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex && videoSource.currentIndex < 4 && QGroundControl.settingsManager.videoSettings.enableStorageLimit.visible
                            QGCLabel {
                                text:               qsTr("Auto-Delete Files:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactCheckBox {
                                text:                   ""
                                fact:                   QGroundControl.settingsManager.videoSettings.enableStorageLimit
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex && videoSource.currentIndex < 4 && QGroundControl.settingsManager.videoSettings.maxVideoSize.visible && QGroundControl.settingsManager.videoSettings.enableStorageLimit.value
                            QGCLabel {
                                text:               qsTr("最大空间:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactTextField {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.maxVideoSize
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex && videoSource.currentIndex < 4 && QGroundControl.settingsManager.videoSettings.recordingFormat.visible
                            QGCLabel {
                                text:               qsTr("视频格式:")//qsTr("Video File Format:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.recordingFormat
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                //-----------------------------------------------------------------
                //-- Custom Brand Image
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     userBrandImageLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false//QGroundControl.settingsManager.brandImageSettings.visible && !ScreenTools.isMobile
                    QGCLabel {
                        id:             userBrandImageLabel
                        text:           qsTr("Brand Image")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     userBrandImageCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false//QGroundControl.settingsManager.brandImageSettings.visible && !ScreenTools.isMobile

                    Column {
                        id:         userBrandImageCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    _userBrandImageIndoor.visible

                            QGCLabel {
                                anchors.baseline:   userBrandImageIndoorBrowse.baseline
                                width:              _labelWidth*1.5
                                text:               qsTr("Indoor Brand Image Path:")
                            }
                            QGCTextField {
                                anchors.baseline:   userBrandImageIndoorBrowse.baseline
                                readOnly:           true
                                width:              _editFieldWidth
                                text:               _userBrandImageIndoor.valueString.replace("file:///","")
                            }
                            QGCButton {
                                id:         userBrandImageIndoorBrowse
                                text:       "Browse"
                                onClicked:  userBrandImageIndoorBrowseDialog.openForLoad()

                                QGCFileDialog {
                                    id:             userBrandImageIndoorBrowseDialog
                                    qgcView:        _qgcView
                                    title:          qsTr("Choose custom brand image file:")
                                    folder:         _userBrandImageIndoor.rawValue.replace("file:///","")
                                    selectExisting: true
                                    selectFolder:   false

                                    onAcceptedForLoad: _userBrandImageIndoor.rawValue = "file:///" + file
                                }
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    _userBrandImageOutdoor.visible

                            QGCLabel {
                                anchors.baseline:   userBrandImageOutdoorBrowse.baseline
                                width:              _labelWidth*1.5
                                text:               qsTr("Outdoor Brand Image Path:")
                            }
                            QGCTextField {
                                anchors.baseline:   userBrandImageOutdoorBrowse.baseline
                                readOnly:           true
                                width:              _editFieldWidth
                                text:               _userBrandImageOutdoor.valueString.replace("file:///","")
                            }
                            QGCButton {
                                id:         userBrandImageOutdoorBrowse
                                text:       "Browse"
                                onClicked:  userBrandImageOutdoorBrowseDialog.openForLoad()

                                QGCFileDialog {
                                    id:             userBrandImageOutdoorBrowseDialog
                                    qgcView:        _qgcView
                                    title:          qsTr("Choose custom brand image file:")
                                    folder:         _userBrandImageOutdoor.rawValue.replace("file:///","")
                                    selectExisting: true
                                    selectFolder:   false

                                    onAcceptedForLoad: _userBrandImageOutdoor.rawValue = "file:///" + file
                                }
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    _userBrandImageIndoor.visible

                            QGCButton {
                                id:         userBrandImageReset
                                text:       "Reset Default Brand Image"
                                onClicked:  {
                                    _userBrandImageIndoor.rawValue = ""
                                    _userBrandImageOutdoor.rawValue = ""
                                }
                            }
                        }
                    }
                }

                QGCLabel {
                    anchors.horizontalCenter:   parent.horizontalCenter
                    text:                       qsTr("%1 Version: %2").arg(QGroundControl.appName).arg(QGroundControl.qgcVersion)
                    visible:                    false
                }
            } // settingsColumn
        } // QGCFlickable
    } // QGCViewPanel
} // QGCView
