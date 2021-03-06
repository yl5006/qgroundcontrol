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
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.AutoPilotPlugin       1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Controllers           1.0

Rectangle {
    id:     setupView
    color:  Qt.rgba(0,0,0,0)
    z:      0//QGroundControl.zOrderTopMost

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    ExclusiveGroup { id: setupButtonGroup }

    readonly property real      _defaultTextHeight: ScreenTools.isMobile?ScreenTools.defaultFontPixelHeight * 0.6:ScreenTools.defaultFontPixelHeight
    readonly property real      _defaultTextWidth:  ScreenTools.isMobile?ScreenTools.defaultFontPixelWidth * 0.6:ScreenTools.defaultFontPixelWidth
    readonly property real      _horizontalMargin:  _defaultTextWidth / 2
    readonly property real      _verticalMargin:    _defaultTextHeight / 2
    readonly property real      _buttonWidth:       _defaultTextWidth * 18
    readonly property string    _armedVehicleText:  qsTr("This operation cannot be performed while vehicle is armed.")//"This operation cannot be performed while vehicle is armed."

    property string _messagePanelText:              qsTr("missing message panel text")//"missing message panel text"
    property bool   _fullParameterVehicleAvailable: QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable && !QGroundControl.multiVehicleManager.activeVehicle.missingParameters
    property var    _corePlugin:                    QGroundControl.corePlugin

    function showSummaryPanel()
    {
        if (_fullParameterVehicleAvailable) {
            if (QGroundControl.multiVehicleManager.activeVehicle.autopilot.vehicleComponents.length == 0) {
                panelLoader.setSourceComponent(noComponentsVehicleSummaryComponent)
            } else {
                panelLoader.setSource("VehicleSummary.qml")
            }
        } else if (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable) {
            panelLoader.setSourceComponent(missingParametersVehicleSummaryComponent)
        } else {
            panelLoader.setSourceComponent(disconnectedVehicleSummaryComponent)
        }
        loader.visible=true
    }

    function showFirmwarePanel()
    {
        if (!ScreenTools.isMobile) {
            if (QGroundControl.multiVehicleManager.activeVehicleAvailable && QGroundControl.multiVehicleManager.activeVehicle.armed) {
                _messagePanelText = _armedVehicleText
                panelLoader.setSourceComponent(messagePanelComponent)
            } else {
                panelLoader.setSource("FirmwareUpgrade.qml")
            }
        }
        loader.visible=true
    }

    function showJoystickPanel()
    {
        if (QGroundControl.multiVehicleManager.activeVehicleAvailable && QGroundControl.multiVehicleManager.activeVehicle.armed) {
            _messagePanelText = _armedVehicleText
            panelLoader.setSourceComponent(messagePanelComponent)
        } else {
            panelLoader.setSource("JoystickConfig.qml")
        }
        loader.visible=true
    }

    function showParametersPanel()
    {
        panelLoader.setSource("SetupParameterEditor.qml")
        loader.visible=true
    }

    function showPX4FlowPanel()
    {
        panelLoader.setSource("PX4FlowSensor.qml")
        loader.visible=true
    }
    function showAnalyzeView()
    {
        panelLoader.setSource("AnalyzeView.qml")
        loader.visible=true
    }
    function showGeneralPanel()
    {
        panelLoader.setSource("GeneralSettings.qml")
        loader.visible=true
    }
    function showLinksPanel()
    {
        panelLoader.setSource("LinkSettings.qml")
        loader.visible=true
    }
    function showOfflineMapsPanel()
    {
        panelLoader.setSource("OfflineMap.qml")
        loader.visible=true
    }
    function showVehicleComponentPanel(vehicleComponent)
    {
        if (QGroundControl.multiVehicleManager.activeVehicle.armed && !vehicleComponent.allowSetupWhileArmed) {
            _messagePanelText = _armedVehicleText
            panelLoader.setSourceComponent(messagePanelComponent)
        } else {
            var autopilotPlugin = QGroundControl.multiVehicleManager.activeVehicle.autopilot
            var prereq = autopilotPlugin.prerequisiteSetup(vehicleComponent)
            if (prereq != "") {
                _messagePanelText = qsTr("%1 setup must be completed prior to %2 setup.").arg(prereq).arg(vehicleComponent.name)
                panelLoader.setSourceComponent(messagePanelComponent)
            } else {
                panelLoader.setSource(vehicleComponent.setupSource, vehicleComponent)
                for(var i = 0; i < componentRepeater.count; i++) {
                    var obj = componentRepeater.itemAt(i);
                    if (obj.text === vehicleComponent.name) {
                        obj.checked = true;
                        break;
                    }
                }
            }
            loader.visible=true
        }
    }



//   Component.onCompleted: showSummaryPanel()

//    Connections {
//        target: QGroundControl.multiVehicleManager

//        onParameterReadyVehicleAvailableChanged: {
//            if (parameterReadyVehicleAvailable || summaryButton.checked || setupButtonGroup.current != firmwareButton) {
//                // Show/Reload the Summary panel when:
//                //      A new vehicle shows up
//                //      The summary panel is already showing and the active vehicle goes away
//                //      The active vehicle goes away and we are not on the Firmware panel.
//                summaryButton.checked = true
//                showSummaryPanel()
//            }
//        }
//    }

    Component {
        id: noComponentsVehicleSummaryComponent

        Rectangle {
            color: qgcPal.windowShade

            QGCLabel {
                anchors.margins:        _defaultTextWidth * 2
                anchors.fill:           parent
                verticalAlignment:      Text.AlignVCenter
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               Text.WordWrap
                font.pointSize:         ScreenTools.mediumFontPointSize
                text:                   qsTr("%1 does not currently support setup of your vehicle type. ").arg(QGroundControl.appName) +
                                        "If your vehicle is already configured you can still Fly."

                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: disconnectedVehicleSummaryComponent

        Rectangle {
            color: qgcPal.windowShade

            QGCLabel {
                anchors.margins:        _defaultTextWidth * 2
                anchors.fill:           parent
                verticalAlignment:      Text.AlignVCenter
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               Text.WordWrap
                font.pointSize:         ScreenTools.largeFontPointSize
                text:                   qsTr("Connect vehicle to your device and QGroundControl will automatically detect it.")+//"Connect vehicle to your device and QGroundControl will automatically detect it." +
                                        (ScreenTools.isMobile ? "" : ""/*" Click Firmware on the left to upgrade your vehicle."*/)

                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
    Component {
        id: missingParametersVehicleSummaryComponent

        Rectangle {
            color: qgcPal.windowShade

            QGCLabel {
                anchors.margins:        _defaultTextWidth * 2
                anchors.fill:           parent
                verticalAlignment:      Text.AlignVCenter
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               Text.WordWrap
                font.pointSize:         ScreenTools.mediumFontPointSize
                text:                   "You are currently connected to a vehicle, but that vehicle did not return back the full parameter list. " +
                                        "Because of this the full set of vehicle setup options are not available."

                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: messagePanelComponent

        Item {
            QGCLabel {
                anchors.margins:        _defaultTextWidth * 2
                anchors.fill:           parent
                verticalAlignment:      Text.AlignVCenter
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               Text.WordWrap
                font.pointSize:         ScreenTools.mediumFontPointSize
                text:                   _messagePanelText
            }
        }
    }

    QGCFlickable {
        id:                     flowscroll
        anchors.topMargin:      _defaultTextHeight*2
        anchors.top:            parent.top
        anchors.bottom:         rowscroll.top
        anchors.bottomMargin:   _defaultTextHeight
        anchors.right:          parent.right
        anchors.rightMargin:    _defaultTextHeight
        anchors.left:           parent.left
        anchors.leftMargin:     _defaultTextHeight*4
//        anchors.horizontalCenter: parent.horizontalCenter
        contentHeight:          buttonFlow.height
        flickableDirection:     Flickable.VerticalFlick
        clip:                   true
        Flow
        {
               id:             buttonFlow
               width:          parent.width*0.9
               spacing:        _defaultTextHeight
               Repeater {
                     id:     componentRepeater
                     model:  _fullParameterVehicleAvailable ? QGroundControl.multiVehicleManager.activeVehicle.autopilot.vehicleComponents : undefined
                     Rectangle {
                         width:          _defaultTextHeight*28
                         height:         _defaultTextHeight*18
                         color:          "transparent"
                         visible:        modelData.summaryQmlSource.toString() != ""
                         AirframeComponentController { id: controllerair;factPanel: qgcView}
                         QGCView {
                             id:         qgcView
                         }
                         QGCLabel {
                             id:                     name
                             anchors.top:            parent.top
                             anchors.left:           parent.left
                             anchors.leftMargin:     _defaultTextHeight
                             font.pointSize:         ScreenTools.mediumFontPointSize
                             color:                 modelData.setupComplete?"white":"red"
                             text:                   modelData.name
                             font.bold:             true
                         }
                         Rectangle {
                             id:                     divider
                             anchors.top:            name.bottom
                             anchors.topMargin:      _defaultTextHeight*0.5
                             height:                 2
                             width:                  parent.width
                             color:                  qgcPal.buttonHighlight
                         }
                         SubMenuButtonModify {
                                id:                     menubotton
                                anchors.left:           parent.left
                                anchors.leftMargin:     _defaultTextHeight
                                anchors.top:            divider.bottom
                                anchors.topMargin:      _defaultTextHeight*0.5
                                width:          index==0 ? _defaultTextHeight*8 *1.6   :       _defaultTextHeight*8
                                height:         index==0 ? _defaultTextHeight*8 *1.6   :       width*1.6
                                imageResource:  index==0 ? controllerair.currentAirframeImgSouce:modelData.iconResource
                                bigimg:         true
                                imgcolor:       modelData.setupComplete? "white"/*Qt.rgba(0.0627, 0.9216, 0.749, 1)*/ :Qt.rgba(0.8941, 0.2275, 0.2392, 1)//"green" : "red"
                                exclusiveGroup: setupButtonGroup
                                visible:        modelData.setupSource.toString() != ""
                                onClicked:
                                {   if(!loader.visible)
                                        showVehicleComponentPanel(modelData)
                                }
                               }
                         Rectangle {
                             anchors.top:               divider.bottom
                             anchors.left:              menubotton.right
                             anchors.leftMargin:        _defaultTextHeight
                             width:                    parent.width-menubotton.width- _defaultTextHeight * 2
                             color:                     "transparent"
                             height:                    _defaultTextHeight * 12
                             Loader {
                                 anchors.fill:       parent
                                 anchors.margins:    ScreenTools.defaultFontPixelWidth
                                 source:             modelData.summaryQmlSource
                             }
                         }
                     }


               }


        }
    }
    QGCFlickable {
        id:                     rowscroll
        height:                 _defaultTextHeight*8
        anchors.bottom:         parent.bottom
        anchors.bottomMargin:   _defaultTextHeight*2
        anchors.left:           parent.left
        anchors.right:          parent.right
        anchors.leftMargin:     _defaultTextHeight*5
        anchors.rightMargin:    _defaultTextHeight*3
        contentWidth:           buttonRow.width
        flickableDirection:     Flickable.HorizontalFlick
        clip:                   true
        Row{
            id:             buttonRow
            spacing:        _defaultTextHeight
            anchors.horizontalCenter: parent.horizontalCenter
        SubMenuButtonModify {
            id:             _generalButton
            width:          _defaultTextHeight*8
            height:         width
            imageResource:  "/qmlimages/tool-01.svg"
            exclusiveGroup: setupButtonGroup
            text:           qsTr("System set")//"General"
            onClicked:
                {   if(!loader.visible)
                        showGeneralPanel()
                }
        }
        SubMenuButtonModify {
            id:             linksButton
            imageResource:  "/qmlimages/connect.svg"
            width:          _defaultTextHeight*8
            height:         width
            exclusiveGroup: setupButtonGroup
            text:           qsTr("Comm Links")//"Comm Links"
            onClicked:
            {
                 if(!loader.visible)
                    showLinksPanel()
            }
        }
        SubMenuButtonModify {
            id:             offlinemapButton
            imageResource:  "/qmlimages/offlinemap.svg"
            width:          _defaultTextHeight*8
            height:         width
            exclusiveGroup: setupButtonGroup
            text:           qsTr("Offline Maps")//"Offline Maps"
            visible:        false//!ScreenTools.isMobile
            onClicked:
            {
                 if(!loader.visible)
                     showOfflineMapsPanel()
            }
        }
        SubMenuButtonModify {
             id:             firmwareButton
             width:          _defaultTextHeight*8
             height:         width
             imageResource:  "/qmlimages/FirmwareUpgradeIcon.svg"
             exclusiveGroup: setupButtonGroup
             visible:        !ScreenTools.isMobile//&&ScreenTools.isDebug
             text:           qsTr("Firmware update")//"Firmware"
             onClicked:
             {
                  if(!loader.visible)
                      showFirmwarePanel()
             }
       }
       SubMenuButtonModify {
             id:             px4FlowButton
             width:          _defaultTextHeight*8
             height:         width
             exclusiveGroup: setupButtonGroup
             visible:        ScreenTools.isDebug&&QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.genericFirmware : false
             text:           "PX4Flow"
             onClicked:
             {
                  if(!loader.visible)
                      showPX4FlowPanel()
             }
        }

        SubMenuButtonModify {
             id:             joystickButton
             width:          _defaultTextHeight*8
             height:         width
             setupComplete:  joystickManager.activeJoystick ? joystickManager.activeJoystick.calibrated : false
             exclusiveGroup: setupButtonGroup
             visible:        _fullParameterVehicleAvailable && joystickManager.joysticks.length != 0
             text:           "Joystick"
             onClicked:
             {
                  if(!loader.visible)
                      showJoystickPanel()
                  }
            }
        Repeater {
              model:  _fullParameterVehicleAvailable ? QGroundControl.multiVehicleManager.activeVehicle.autopilot.vehicleComponents : undefined
              SubMenuButtonModify {
                     width:          _defaultTextHeight*8
                     height:         width
                     imageResource:  modelData.iconResource
                     exclusiveGroup: setupButtonGroup
                     text:           modelData.name
                     visible:        modelData.summaryQmlSource.toString() == ""&&modelData.setupSource.toString() != ""
                     onClicked:
                     {
                          if(!loader.visible)
                              showVehicleComponentPanel(modelData)
                          }
                    }
        }
        SubMenuButtonModify {
              width:          _defaultTextHeight*8
              height:         width
              exclusiveGroup: setupButtonGroup
              visible:        QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable
              text:           qsTr("Back Parameters")//"Firmware""Parameters"
              onClicked:
              {
                   if(!loader.visible)
                       showParametersPanel()
                   }
            }
        SubMenuButtonModify {
              width:          _defaultTextHeight*8
              height:         width
              exclusiveGroup: setupButtonGroup
              imageResource:  "/qmlimages/Analyze.svg"
              visible:        !ScreenTools.isMobile&&QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable
              text:           qsTr("Logs")//"Firmware"
              onClicked:
              {
                   if(!loader.visible)
                       showAnalyzeView()
                   }
            }
        }
    }
    Rectangle {
        id:                     loader
        anchors.fill:           parent
        anchors.margins:        _defaultTextHeight
        visible:                false
        color:                  qgcPal.windowShade
        z:                       QGroundControl.zOrderTopMost
        Loader {
            id:                     panelLoader
            anchors.fill:           parent
   	    function setSource(source, vehicleComponent) {
            panelLoader.vehicleComponent = vehicleComponent
            panelLoader.source = source
            }

            function setSourceComponent(sourceComponent, vehicleComponent) {
            panelLoader.vehicleComponent = vehicleComponent
            panelLoader.sourceComponent = sourceComponent
            }
            property var vehicleComponent
        }

    }
    ImageButton {
        anchors.margins:        _defaultTextWidth*2
        anchors.top: parent.top
        anchors.right: parent.right
        imageResource:             "/res/XDelete.svg"
        width:              ScreenTools.defaultFontPixelHeight * 2
        height:             width
        visible:            loader.visible
        z:                  QGroundControl.zOrderTopMost+ 1
        onClicked:
        {
            panelLoader.sourceComponent = noComponentsVehicleSummaryComponent
            loader.visible =   false
        }
    }
}
