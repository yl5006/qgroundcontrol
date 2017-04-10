/****************************************************************************
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
    id:                 qgcView
    viewPanel:          panel
    color:              qgcPal.window
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    property Fact _percentRemainingAnnounce:    QGroundControl.settingsManager.appSettings.batteryPercentRemainingAnnounce
    property Fact _autoLoadDir:                 QGroundControl.settingsManager.appSettings.missionAutoLoadDir
    property Fact _appFontPointSize:            QGroundControl.settingsManager.appSettings.appFontPointSize
    property real _labelWidth:                  ScreenTools.defaultFontPixelWidth * 15
    property real _editFieldWidth:              ScreenTools.defaultFontPixelWidth * 30

    readonly property string _requiresRestart:  qsTr("(Requires Restart)")

    QGCPalette { id: qgcPal }

    FactPanelController {
        id:         controller
        factPanel:  qgcView
    }

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
            contentWidth:       qgcView.width
            flickableDirection: Flickable.VerticalFlick
            Column {
                id:                 settingsColumn
                anchors.top:        parent.top
                anchors.topMargin:  ScreenTools.defaultFontPixelWidth
                spacing:            ScreenTools.defaultFontPixelHeight / 2
                width:              fontrow.width
                anchors.horizontalCenter: parent.horizontalCenter
                //-----------------------------------------------------------------
                //-- Base UI Font Point Size
                Row {
                    id:      fontrow
                    spacing: ScreenTools.defaultFontPixelWidth
                    QGCLabel {
                        id:     baseFontLabel
                        text:   qsTr("字体大小:")//"Base UI font size:"
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
                            _showHighlight : true
                            onClicked: {
                                if (_appFontPointSize.value < _appFontPointSize.max) {
                                    _appFontPointSize.value = _appFontPointSize.value + 1
                                }
                            }
                        }
                    }

                    QGCLabel {
                        anchors.verticalCenter: parent.verticalCenter
                        text:                   qsTr("重启生效")//qsTr("(requires app restart)")
                    }
                }

                //-----------------------------------------------------------------
                //-- Units
                Rectangle {
                    height:                     unitsCol.height //+ (ScreenTools.defaultFontPixelHeight * 2)
                    color:                      "transparent"//qgcPal.windowShade
                    width:                      parent.width//
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
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

                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                    visible:  false
                }
                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                    PathDraw {
                        lineWidth: 1
                        lineColor: qgcPal.button
                        point1x:parent.x
                        point1y:parent.height/2
                        point2x:parent.x+parent.width
                        point2y:parent.height/2
                    }
                }


                //-----------------------------------------------------------------
                //-- Map Providers
                Row {
                    id:   map
                    /*
                      TODO: Map settings should come from QGroundControl.mapEngineManager. What is currently in
                      QGroundControl.flightMapSettings should be moved there so all map related funtions are in
                      one place.
                     */
                    spacing:    ScreenTools.defaultFontPixelWidth
                    visible:    QGroundControl.flightMapSettings.googleMapEnabled

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
                        checked:            QGroundControl.flightMapSettings.mapProviders[0]==QGroundControl.flightMapSettings.mapProvider
                        onClicked: {
                            QGroundControl.flightMapSettings.mapProvider=QGroundControl.flightMapSettings.mapProviders[0]
                            QGroundControl.flightMapSettings.mapType=
                                    console.log(qsTr("New map provider: ") + QGroundControl.flightMapSettings.mapProvider)
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
                        checked:            QGroundControl.flightMapSettings.mapProviders[1]==QGroundControl.flightMapSettings.mapProvider
                        onClicked: {
                            QGroundControl.flightMapSettings.mapProvider=QGroundControl.flightMapSettings.mapProviders[1]
                            console.log(qsTr("New map provider: ") + QGroundControl.flightMapSettings.mapProvider)
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
                        checked:            QGroundControl.flightMapSettings.mapProviders[2]==QGroundControl.flightMapSettings.mapProvider
                        onClicked: {
                            QGroundControl.flightMapSettings.mapProvider=QGroundControl.flightMapSettings.mapProviders[2]
                            console.log(qsTr("New map provider: ") + QGroundControl.flightMapSettings.mapProvider)
                        }
                    }
                    //                ImageButton{
                    //                    imageResource:             "/qmlimages/baidumap.png"
                    //                    exclusiveGroup:     mapActionGroup
                    //                    width:              ScreenTools.defaultFontPixelHeight * 5
                    //                    height:             ScreenTools.defaultFontPixelHeight * 4
                    //                    imageResource2:             "/qmlimages/checked.svg"
                    //                    img2visible:        true
                    //                    checkable:          true
                    //                    checked:            QGroundControl.flightMapSettings.mapProviders[3]==QGroundControl.flightMapSettings.mapProvider
                    //                    onClicked: {
                    //                        QGroundControl.flightMapSettings.mapProvider=QGroundControl.flightMapSettings.mapProviders[3]
                    //                        console.log(qsTr("New map provider: ") + QGroundControl.flightMapSettings.mapProvider)
                    //                    }
                    //                }
                }

                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                }
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth
                    QGCLabel {
                        width:              baseFontLabel.width
                        text:   qsTr("语言")//"Style"
                    }

                    FactComboBox {
                        id:         langCombo
                        width:      _editFieldWidth
                        fact:       QGroundControl.language
                        indexModel: false
                        onActivated: {
                            if (index != -1) {
                                sys_language.value = index
                            }
                        }
                    }

                    //                QGCComboBox {
                    //                    id:             langCombo
                    //                    width:          _editFieldWidth
                    //                    model: [ "中文", "English" ]//model: [ "Indoor", "Outdoor" ]
                    //                    currentIndex:       0//QGroundControl.isDarkStyle ? 0 : 1

                    //                    onActivated: {
                    //                        if (index != -1) {
                    //                            currentIndex = index
                    //                            //  QGroundControl.isDarkStyle = index === 0 ? true : false
                    //                        }
                    //                    }
                    //                }
                }

                //-- Palette Styles
                Item {
                    height: ScreenTools.defaultFontPixelHeight / 2
                    width:  parent.width
                    PathDraw {
                        lineWidth: 1
                        lineColor: qgcPal.button
                        point1x:parent.x
                        point1y:parent.height/2
                        point2x:parent.x+parent.width
                        point2y:parent.height/2
                    }
                }
                //-- Prompt Save Log
                Column {                   
                    spacing:            ScreenTools.defaultFontPixelHeight / 2
                    FactCheckBox {
                        id:         promptSaveLog
                        text:       qsTr("在每次飞行中存储飞行日志")//"Prompt to save Flight Data Log after each flight"
                        fact:       _promptFlightTelemetrySave
                        visible:    !ScreenTools.isMobile && _promptFlightTelemetrySave.visible

                        property Fact _promptFlightTelemetrySave: QGroundControl.settingsManager.appSettings.promptFlightTelemetrySave
                    }
                    //-----------------------------------------------------------------
                    //-- Prompt Save even if not armed
                    FactCheckBox {
                        text:       qsTr("即使未解锁也存储飞行日志")//"Prompt to save Flight Data Log even if vehicle was not armed"
                        fact:       _promptFlightTelemetrySaveNotArmed
                        visible:    !ScreenTools.isMobile && _promptFlightTelemetrySaveNotArmed.visible
                        enabled:    promptSaveLog.checked

                        property Fact _promptFlightTelemetrySaveNotArmed: QGroundControl.settingsManager.appSettings.promptFlightTelemetrySaveNotArmed
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
                }
                //-----------------------------------------------------------------
                //-- Battery talker
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth
                    visible: false
                    QGCCheckBox {
                        id:                 announcePercentCheckbox
                        anchors.verticalCenter: parent.verticalCenter
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
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                //-----------------------------------------------------------------
                //-- Default mission item altitude
                Row {
                    spacing:    ScreenTools.defaultFontPixelWidth
                    QGCLabel {
                        anchors.baseline:   defaultItemAltitudeField.baseline
                        text:               qsTr("默认任务高度:")
                    }
                    FactTextField {
                        id:     defaultItemAltitudeField
                        fact:   QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude
                    }
                }
                //-----------------------------------------------------------------
                //-- Mission AutoLoad
                Row {
                    visible: false
                    spacing: ScreenTools.defaultFontPixelWidth
                    QGCCheckBox {
                        id:                     autoLoadCheckbox
                        anchors.verticalCenter: parent.verticalCenter
                        text:                   qsTr("AutoLoad mission directory:")
                        checked:                _autoLoadDir.valueString

                        onClicked: {
                            if (checked) {
                                _autoLoadDir.rawValue = QGroundControl.urlToLocalFile(autoloadDirPicker.shortcuts.home)
                            } else {
                                _autoLoadDir.rawValue = ""
                            }
                        }
                    }
                    FactTextField {
                        id:                     autoLoadDirField
                        width:                  _editFieldWidth
                        enabled:                autoLoadCheckbox.checked
                        anchors.verticalCenter: parent.verticalCenter
                        fact:                   _autoLoadDir
                    }
                    QGCButton {
                        text:       qsTr("Browse")
                        onClicked:  autoloadDirPicker.visible = true

                        FileDialog {
                            id:             autoloadDirPicker
                            title:          qsTr("Choose the location of mission file.")
                            folder:         shortcuts.home
                            selectFolder:   true
                            onAccepted:     _autoLoadDir.rawValue = QGroundControl.urlToLocalFile(autoloadDirPicker.fileUrl)
                        }
                    }
                }
                //-----------------------------------------------------------------
                //-- Autoconnect settings
                Item {
                    width:                      qgcView.width * 0.8
                    height:                     autoConnectLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    visible:                    false
                    QGCLabel {
                        id:             autoConnectLabel
                        text:           qsTr("AutoConnect to the following devices:")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     autoConnectCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    false

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
                    width:                      qgcView.width * 0.8
                    height:                     videoLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    visible:                    false//QGroundControl.settingsManager.videoSettings.visible
                    QGCLabel {
                        id:             videoLabel
                        text:           qsTr("视频(设置后需重启软件)")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     videoCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      parent.width//qgcView.width * 0.8
                    color:                      "transparent"//qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
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
                            visible:    QGroundControl.settingsManager.videoSettings.videoSavePath.visible && QGroundControl.videoManager.isGStreamer && QGroundControl.videoManager.recordingEnabled
                            QGCLabel {
                                anchors.baseline:   pathField.baseline
                                text:               qsTr("保存路径:")
                                width:              _labelWidth
                            }
                            FactTextField {
                                id:                 pathField
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.videoSavePath
                            }
                            QGCButton {
                                text:       qsTr("选择:")//"Browse"
                                onClicked:  videoLocationFileDialog.visible = true

                                QGCFileDialog {
                                    id:             savePathBrowseDialog
                                    qgcView:        _qgcView
                                    title:          qsTr("选择一个路径保存视频文件:")//qsTr("Choose the location to save files:")
                                    folder:         _savePath.rawValue
                                    selectExisting: true
                                    selectFolder:   true

                                    onAcceptedForLoad: _savePath.rawValue = file
                                }
                            }
                        }
                    }
                } // Video Source - Rectangle

                QGCLabel {
                    text:                       qsTr("QGroundControl Version: " + QGroundControl.qgcVersion)
                    visible:                    false
                }
            }
        } // settingsColumn
    } // QGCView
}
