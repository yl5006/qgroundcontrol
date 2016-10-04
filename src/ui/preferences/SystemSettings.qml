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

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0



Rectangle {
    id:                 generalPage
    color:              qgcPal.window
    anchors.fill:       parent
    // anchors.margins:    ScreenTools.defaultFontPixelWidth


    QGCPalette { id: qgcPal }

    //    width:  Math.max(availableWidth, settingsColumn.width)
    //    height: settingsColumn.height

    property Fact _percentRemainingAnnounce:    QGroundControl.batteryPercentRemainingAnnounce
    property real _editFieldWidth:              ScreenTools.defaultFontPixelWidth * 30
    Rectangle {
        id:         title
        anchors.top:        parent.top
        width:      parent.width
        height:     ScreenTools.defaultFontPixelHeight*10
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
        //                fillMode: Image.PreserveAspectFit
    }
    }
    QGCFlickable {
        clip:               true
        anchors.top:        title.bottom
   //     anchors.margins:    ScreenTools.defaultFontPixelWidth*5
        width:              parent.width
        height:             parent.height -ScreenTools.defaultFontPixelWidth*20
        contentHeight:      settingsColumn.height+ScreenTools.defaultFontPixelWidth*2
        contentWidth:       generalPage.width
        flickableDirection: Flickable.VerticalFlick
        Column {
            id:                 settingsColumn
            //  width:              generalPage.width*0.9
            anchors.top:        parent.top
            anchors.topMargin:  ScreenTools.defaultFontPixelWidth
            spacing:            ScreenTools.defaultFontPixelHeight / 2
            anchors.horizontalCenter: parent.horizontalCenter
            //-----------------------------------------------------------------
            //-- Base UI Font Point Size
            Row {
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
                        _showHighlight : true
                        onClicked: {
                            if(ScreenTools.defaultFontPointSize < 49) {
                                QGroundControl.baseFontPointSize = QGroundControl.baseFontPointSize + 1
                            }
                        }
                    }
                }

                QGCLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    text:                   qsTr("重启生效")//qsTr("(requires app restart)")
                }
            }

            //  -----------------------------------------------------------------
            //   -- Units

            Row {
                spacing:    ScreenTools.defaultFontPixelWidth

                QGCLabel {
                    width:              baseFontLabel.width
                    anchors.baseline:   distanceUnitsCombo.baseline
                    text:                qsTr("距离单位")//qsTr("Distance units:")
                }

                FactComboBox {
                    id:                 distanceUnitsCombo
                    width:              _editFieldWidth
                    fact:               QGroundControl.distanceUnits
                    indexModel:         false
                }

                QGCLabel {
                    anchors.baseline:   distanceUnitsCombo.baseline
                    text:                qsTr("重启生效")//qsTr("(requires app restart)")
                }

            }

            //                Row {
            //                    spacing:    ScreenTools.defaultFontPixelWidth

            //                    QGCLabel {
            //                        width:              baseFontLabel.width
            //                        anchors.baseline:   areaUnitsCombo.baseline
            //                        text:               qsTr("Area units:")
            //                    }

            //                    FactComboBox {
            //                        id:                 areaUnitsCombo
            //                        width:              _editFieldWidth
            //                        fact:               QGroundControl.areaUnits
            //                        indexModel:         false
            //                    }

            //                    QGCLabel {
            //                        anchors.baseline:   areaUnitsCombo.baseline
            //                        text:               qsTr("(requires app restart)")
            //                    }

            //                }

            //                Row {
            //                    spacing:                ScreenTools.defaultFontPixelWidth

            //                    QGCLabel {
            //                        width:              baseFontLabel.width
            //                        anchors.baseline:   speedUnitsCombo.baseline
            //                        text:               qsTr("Speed units:")
            //                    }

            //                    FactComboBox {
            //                        id:                 speedUnitsCombo
            //                        width:              _editFieldWidth
            //                        fact:               QGroundControl.speedUnits
            //                        indexModel:         false
            //                    }

            //                    QGCLabel {
            //                        anchors.baseline:   speedUnitsCombo.baseline
            //                        text:               qsTr("(requires app restart)")
            //                    }
            //                }

            Item {
                height: ScreenTools.defaultFontPixelHeight / 2
                width:  parent.width
            }
            //always true
            //-----------------------------------------------------------------
            //-- Audio preferences
            //                QGCCheckBox {
            //                    text:       qsTr("音频静音")//"Mute all audio output"
            //                    checked:    QGroundControl.isAudioMuted
            //                    onClicked: {
            //                        QGroundControl.isAudioMuted = checked
            //                    }
            //                }
            //                //-----------------------------------------------------------------

            //-----------------------------------------------------------------
            //                //-- Battery talker
            //                Row {
            //                    spacing: ScreenTools.defaultFontPixelWidth

            //                    QGCCheckBox {
            //                        id:                 announcePercentCheckbox
            //                        anchors.baseline:   announcePercent.baseline
            //                        text:               qsTr("Announce battery lower than:")
            //                        checked:            _percentRemainingAnnounce.value != 0

            //                        onClicked: {
            //                            if (checked) {
            //                                _percentRemainingAnnounce.value = _percentRemainingAnnounce.defaultValueString
            //                            } else {
            //                                _percentRemainingAnnounce.value = 0
            //                            }
            //                        }
            //                    }

            //                    FactTextField {
            //                        id:                 announcePercent
            //                        fact:               _percentRemainingAnnounce
            //                        enabled:            announcePercentCheckbox.checked
            //                    }
            //                }

            Item {
                height: ScreenTools.defaultFontPixelHeight / 2
                width:  map.width
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
                }
                ImageButton{
                    imageResource:             "/qmlimages/baidumap.png"
                    exclusiveGroup:     mapActionGroup
                    width:              ScreenTools.defaultFontPixelHeight * 5
                    height:             ScreenTools.defaultFontPixelHeight * 4
                    imageResource2:             "/qmlimages/checked.svg"
                    img2visible:        true
                    checkable:          true
                }
            }
            //-----------------------------------------------------------------
            //  maybe later              //-- Palette Styles
            //                Row {
            //                    spacing: ScreenTools.defaultFontPixelWidth

            //                    QGCLabel {
            //                        width:              mapProvidersLabel.width
            //                        anchors.baseline:   paletteCombo.baseline
            //                        text:   qsTr("主题")//"Style"
            //                    }

            //                    QGCComboBox {
            //                        id:             paletteCombo
            //                        width:          _editFieldWidth
            //                        model: [ qsTr("黑色"), qsTr("亮色") ]//model: [ "Indoor", "Outdoor" ]
            //                        currentIndex:   QGroundControl.isDarkStyle ? 0 : 1

            //                        onActivated: {
            //                            if (index != -1) {
            //                                currentIndex = index
            //                                QGroundControl.isDarkStyle = index === 0 ? true : false
            //                            }
            //                        }
            //                    }
            //                }
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

                QGCComboBox {
                    id:             langCombo
                    width:          _editFieldWidth
                    model: [ "中文", "English" ]//model: [ "Indoor", "Outdoor" ]
                    currentIndex:       0//QGroundControl.isDarkStyle ? 0 : 1

                    onActivated: {
                        if (index != -1) {
                            currentIndex = index
                            //  QGroundControl.isDarkStyle = index === 0 ? true : false
                        }
                    }
                }
            }

            //-- Palette Styles
            Item {
                height: ScreenTools.defaultFontPixelHeight / 2
                width:  map.width
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
            //            -- Autoconnect settings  Maybe here do not use (yaoling)
            QGCLabel {
                text: qsTr("自动连接设备")//"Autoconnect to the following devices:"
            }

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

                //                    QGCCheckBox {
                //                        text:       qsTr("EWT Flow")//qsTr("PX4 Flow")
                //                        visible:    !ScreenTools.isiOS
                //                        checked:    QGroundControl.linkManager.autoconnectPX4Flow
                //                        onClicked:  QGroundControl.linkManager.autoconnectPX4Flow = checked
                //                    }

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

            //-----------------------------------------------------------------
            //                //-- Virtual joystick settings
            //                QGCCheckBox {
            //                    text:       qsTr("虚拟遥控")//"Virtual Joystick"
            //                    checked:    QGroundControl.virtualTabletJoystick
            //                    onClicked:  QGroundControl.virtualTabletJoystick = checked
            //                }


            //-----------------------------------------------------------------
            //-- Offline mission editing settings
            Item {
                height: ScreenTools.defaultFontPixelHeight / 2
                width:  parent.width
            }
            QGCLabel { text: qsTr("离线地图编辑")/*"Offline mission editing"*/ }

            Row {
                spacing: ScreenTools.defaultFontPixelWidth

                QGCLabel {
                    text:               qsTr("无人机:")//qsTr("Vehicle:")
                    width:              baseFontLabel.width
                    anchors.baseline:   offlineVehicleCombo.baseline
                }


                FactComboBox {
                    id:         offlineVehicleCombo
                    width:      _editFieldWidth
                    fact:       QGroundControl.offlineEditingVehicleType
                    indexModel: false
                }
            }

            //-- Palette Styles
            Item {
                height: ScreenTools.defaultFontPixelHeight / 2
                width:  map.width
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
            Item {
                height: ScreenTools.defaultFontPixelHeight / 2
                width:  parent.width
            }
            //-----------------------------------------------------------------
            //-- Video Source
            Item {
                width:              parent.width
                height:             videoLabel.height
                anchors.margins:    ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel {
                    id:             videoLabel
                    text:           qsTr("Video (Requires Restart)")
                    font.family:    ScreenTools.demiboldFontFamily
                }
            }
            Rectangle {
                height:         videoCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                width:          parent.width
                color:          qgcPal.windowShade
                anchors.margins: ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    id:         videoCol
                    spacing:    ScreenTools.defaultFontPixelWidth
                    //anchors.centerIn: parent
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            anchors.baseline:   videoSource.baseline
                            text:               qsTr("视频源:")//qsTr("Video Source:")
                            width:              _editFieldWidth/2
                        }
                        QGCComboBox {
                            id:                 videoSource
                            width:              _editFieldWidth
                            model:              QGroundControl.videoManager.videoSourceList
                            Component.onCompleted: {
                                var index = videoSource.find(QGroundControl.videoManager.videoSource)
                                if (index >= 0) {
                                    videoSource.currentIndex = index
                                }
                            }
                            onActivated: {
                                if (index != -1) {
                                    currentIndex = index
                                    QGroundControl.videoManager.videoSource = model[index]
                                }
                            }
                        }
                    }
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex === 0
                        QGCLabel {
                            anchors.baseline:   udpField.baseline
                            text:               qsTr("UDP Port:")
                            width:              _editFieldWidth/2
                        }
                        QGCTextField {
                            id:                 udpField
                            width:              _editFieldWidth
                            text:               QGroundControl.videoManager.udpPort
                            validator:          IntValidator {bottom: 1024; top: 65535;}
                            inputMethodHints:   Qt.ImhDigitsOnly
                            onEditingFinished: {
                                QGroundControl.videoManager.udpPort = parseInt(text)
                            }
                        }
                    }
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex === 1
                        QGCLabel {
                            anchors.baseline:   rtspField.baseline
                            text:               qsTr("RTSP URL:")
                            width:              _editFieldWidth/2
                        }
                        QGCTextField {
                            id:                 rtspField
                            width:              _editFieldWidth
                            text:               QGroundControl.videoManager.rtspURL
                            onEditingFinished: {
                                QGroundControl.videoManager.rtspURL = text
                            }
                        }
                    }
                }
            }
        }// QGCViewPanel
    }// QGCView
}

