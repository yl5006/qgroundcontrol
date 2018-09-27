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
import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Layouts          1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Airmap        1.0

Item {
    id: widgetRoot

    property var    qgcView
    property bool   useLightColors
    property var    missionController
    property bool   showValues:             !QGroundControl.airspaceManager.airspaceVisible
    property var    orbitMapCircle
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _isSatellite:           _mainIsMap ? (_flightMap ? _flightMap.isSatelliteMap : true) : true
    property bool   _lightWidgetBorders:    _isSatellite
    property bool   _airspaceEnabled:       QGroundControl.airmapSupported ? QGroundControl.settingsManager.airMapSettings.enableAirMap.rawValue : false

    readonly property real _margins:        ScreenTools.defaultFontPixelHeight * 0.5
    readonly property real _toolButtonTopMargin:    parent.height - ScreenTools.availableHeight + (ScreenTools.defaultFontPixelHeight / 2)

    QGCMapPalette { id: mapPal; lightColors: useLightColors }
    QGCPalette    { id: qgcPal }

    property real _fontPointSize: ScreenTools.isMobile ? ScreenTools.largeFontPointSize : ScreenTools.defaultFontPointSize

    property bool showEmergenyStop:     _guidedActionsEnabled && !_hideEmergenyStop && _vehicleArmed && _vehicleFlying
    property bool showArm:              _guidedActionsEnabled && !_vehicleArmed
    property bool showDisarm:           _guidedActionsEnabled && _vehicleArmed && !_vehicleFlying
    property bool showRTL:              _guidedActionsEnabled && _vehicleArmed && _activeVehicle.guidedModeSupported && _vehicleFlying && !_vehicleInRTLMode
    property bool showTakeoff:          _guidedActionsEnabled && _activeVehicle.takeoffVehicleSupported && !_vehicleFlying
    property bool showLand:             _guidedActionsEnabled && _activeVehicle.guidedModeSupported && _vehicleArmed && !_activeVehicle.fixedWing && !_vehicleInLandMode
    property bool showStartMission:     _guidedActionsEnabled && _missionAvailable && !_missionActive && !_vehicleFlying
    property bool showContinueMission:  _guidedActionsEnabled && _missionAvailable && !_missionActive && _vehicleArmed && _vehicleFlying && (_currentMissionIndex < missionController.visualItems.count - 1)
    property bool showPause:            _guidedActionsEnabled && _vehicleArmed && _activeVehicle.pauseVehicleSupported && _vehicleFlying && !_vehiclePaused
    property bool showChangeAlt:        _guidedActionsEnabled && _vehicleFlying && _activeVehicle.guidedModeSupported && _vehicleArmed && !_missionActive
    property bool showOrbit:            _guidedActionsEnabled && !_hideOrbit && _vehicleFlying && _activeVehicle.orbitModeSupported && !_missionActive
    property bool showLandAbort:        _guidedActionsEnabled && _vehicleFlying && _activeVehicle.fixedWing && _vehicleLanding
    property bool showGotoLocation:     _guidedActionsEnabled && _vehicleFlying

    // Note: The 'missionController.visualItems.count - 3' is a hack to not trigger resume mission when a mission ends with an RTL item
    property bool showResumeMission:    _activeVehicle && !_vehicleArmed && _vehicleWasFlying && _missionAvailable && _resumeMissionIndex > 0 && (_resumeMissionIndex < missionController.visualItems.count - 3)

    property bool guidedUIVisible:      guidedModeConfirm.visible //|| guidedActionList.visible

    property bool   _guidedActionsEnabled:  (!ScreenTools.isDebug && QGroundControl.corePlugin.options.guidedActionsRequireRCRSSI && _activeVehicle) ? _rcRSSIAvailable : _activeVehicle
    property string _flightMode:            _activeVehicle ? _activeVehicle.flightMode : ""
    property bool   _missionAvailable:      missionController.containsItems
    property bool   _missionActive:         _activeVehicle ? _vehicleArmed && (_vehicleInLandMode || _vehicleInRTLMode || _vehicleInMissionMode) : false
    property bool   _vehicleArmed:          _activeVehicle ? _activeVehicle.armed  : false
    property bool   _vehicleFlying:         _activeVehicle ? _activeVehicle.flying  : false
    property bool   _vehicleLanding:        _activeVehicle ? _activeVehicle.landing  : false
    property bool   _vehiclePaused:         false
    property bool   _vehicleInMissionMode:  false
    property bool   _vehicleInRTLMode:      false
    property bool   _vehicleInLandMode:     false
    property int    _currentMissionIndex:   missionController.currentMissionIndex
    property int    _resumeMissionIndex:    missionController.resumeMissionIndex
    property bool   _hideEmergenyStop:      !QGroundControl.corePlugin.options.guidedBarShowEmergencyStop
    property bool   _hideOrbit:             !QGroundControl.corePlugin.options.guidedBarShowOrbit
    property bool   _vehicleWasFlying:      false
    property bool   _rcRSSIAvailable:       _activeVehicle ? _activeVehicle.rcRSSI > 0 && _activeVehicle.rcRSSI < 255 : false


    on_VehicleFlyingChanged: {
        if (!_vehicleFlying) {
            // We use _vehicleWasFLying to help trigger Resume Mission only if the vehicle actually flew and came back down.
            // Otherwise it may trigger during the Start Mission sequence due to signal ordering or armed and resume mission index.
            _vehicleWasFlying = true
        }
    }

    readonly property int actionRTL:                        1
    readonly property int actionLand:                       2
    readonly property int actionTakeoff:                    3
    readonly property int actionArm:                        4
    readonly property int actionDisarm:                     5
    readonly property int actionEmergencyStop:              6
    readonly property int actionChangeAlt:                  7
    readonly property int actionGoto:                       8
    readonly property int actionSetWaypoint:                9
    readonly property int actionOrbit:                      10
    readonly property int actionLandAbort:                  11
    readonly property int actionStartMission:               12
    readonly property int actionContinueMission:            13
    readonly property int actionResumeMission:              14
    readonly property int actionResumeMissionReady:         15
    readonly property int actionResumeMissionUploadFail:    16
    readonly property int actionPause:                      17
    readonly property int actionMVPause:                    18
    readonly property int actionMVStartMission:             19
    readonly property int actionVtolTransitionToFwdFlight:  20
    readonly property int actionVtolTransitionToMRFlight:   21

    property int    confirmActionCode
    property var    _actionData
    property real   _showMargin:    _margins
    property real   _hideMargin:    _margins - guidedModeBar.height
    property real   _barMargin:     _showMargin

    function actionConfirmed(actionData,actionAltitudeChange) {
        switch (confirmActionCode) {
        case actionRTL:
            _activeVehicle.guidedModeRTL()
            break;
        case actionLand:
            _activeVehicle.guidedModeLand()
            break;
        case actionTakeoff:
            _activeVehicle.guidedModeTakeoff(actionAltitudeChange)
            break;
        case actionArm:
            _activeVehicle.armed = true
            break;
        case actionDisarm:
            _activeVehicle.armed = false
            break;
        case actionEmergencyStop:
            _activeVehicle.emergencyStop()
            break;
        case actionChangeAlt:
             _activeVehicle.guidedModeChangeAltitude(actionAltitudeChange)
            break;
        case actionGoto:
            _activeVehicle.guidedModeGotoLocation(actionData)
            break;
        case actionSetWaypoint:
            _activeVehicle.setCurrentMissionSequence(actionData)
            break;
        case actionOrbit:
            //-- All parameters controlled by RC
            //-- Center on current flight map position and orbit with a 50m radius (velocity/direction controlled by the RC)
            _activeVehicle.guidedModeOrbit(orbitMapCircle.center, orbitMapCircle.radius(), _activeVehicle.altitudeAMSL.rawValue + actionAltitudeChange)
            break;
        case actionLandAbort:
            _activeVehicle.abortLanding(50)     // hardcoded value for climbOutAltitude that is currently ignored
            break;
        case actionResumeMission:
        case actionResumeMissionUploadFail:
            missionController.resumeMission(missionController.resumeMissionIndex)
            break
        case actionResumeMissionReady:
            _activeVehicle.startMission()
            break
        case actionStartMission:
        case actionContinueMission:
            _activeVehicle.startMission()
            break
        case actionPause:
            _activeVehicle.pauseVehicle()
            break
        case actionVtolTransitionToFwdFlight:
            _activeVehicle.vtolInFwdFlight = true
            break
        case actionVtolTransitionToMRFlight:
            _activeVehicle.vtolInFwdFlight = false
            break
        default:
            console.warn(qsTr("Internal error: unknown confirmActionCode"), confirmActionCode)
        }
    }

    function rejectGuidedModeConfirm() {
        guidedModeConfirm.visible = false
        guidedModeBar.visible = true
        altitudeSlider.visible = false
   //     _flightMap._gotoHereCoordinate = QtPositioning.coordinate()
        guidedModeHideTimer.restart()
    }

    function confirmAction(actionCode,actionData) {
        guidedModeHideTimer.stop()
        confirmActionCode = actionCode
        _actionData = actionData
        switch (confirmActionCode) {
        case actionArm:
            if (_vehicleFlying || !_guidedActionsEnabled) {
                return
            }
            guidedModeConfirm.confirmText = qsTr("Arming")
            break;
        case actionDisarm:
            if (_vehicleFlying) {
                return
            }
            guidedModeConfirm.confirmText = qsTr("Disarm")
            break;
        case actionEmergencyStop:
            guidedModeConfirm.confirmText = qsTr("!Disarm and Open umbrella")
            break;
        case actionTakeoff:
            altitudeSlider.setToMinimumTakeoff()
            altitudeSlider.visible = true
            guidedModeConfirm.confirmText = qsTr("Take off")
            break;
        case actionLand:
            guidedModeConfirm.confirmText = qsTr("Land")
            break;
        case actionRTL:
            guidedModeConfirm.confirmText = qsTr("Retrun home")
            break;
        case actionChangeAlt:
            altitudeSlider.reset()
            altitudeSlider.visible = true
            guidedModeConfirm.confirmText = qsTr("Change height")
            break;
        case actionGoto:
            guidedModeConfirm.confirmText = qsTr("Go here")
            break;
        case actionSetWaypoint:
            guidedModeConfirm.confirmText = qsTr("Change waypoint")
            break;
        case actionOrbit:
            altitudeSlider.reset()
            altitudeSlider.visible = true
            guidedModeConfirm.confirmText = qsTr("Go around")
            break;
        case actionLandAbort:
            guidedModeConfirm.confirmText = qsTr("abort landing")
            break;
        case actionResumeMission:
             guidedModeConfirm.confirmText = qsTr("Resume mission")
            break
        case actionResumeMissionReady:
             guidedModeConfirm.confirmText = qsTr("Resume mission")
            break
        case actionResumeMissionUploadFail:
             guidedModeConfirm.confirmText = qsTr("Resume FAILED")
            break
        case actionStartMission:
             guidedModeConfirm.confirmText = qsTr("Start mission")
            break
        case actionContinueMission:
             guidedModeConfirm.confirmText = qsTr("Continue mission")
            break
        case actionPause:
            altitudeSlider.reset()
             guidedModeConfirm.confirmText = qsTr("Pause")
            break
        case actionVtolTransitionToFwdFlight:
             guidedModeConfirm.confirmText = qsTr("Transition To Fw")
            break
        case actionVtolTransitionToMRFlight:
             guidedModeConfirm.confirmText = qsTr("Transition To MR")
            break
        default:
            console.warn(qsTr("Internal error: unknown actionCode"), actionCode)
            break
        }
        guidedModeBar.visible = false
        guidedModeConfirm.visible = true
    }

    function getPreferredInstrumentWidth() {
        // Don't allow instrument panel to chew more than 1/4 of full window
        var defaultWidth = ScreenTools.defaultFontPixelWidth * 30
        var maxWidth = mainWindow.width * 0.25
        return Math.min(maxWidth, defaultWidth)
    }

    function _setInstrumentWidget() {
        if(QGroundControl.corePlugin.options.instrumentWidget) {
            if(QGroundControl.corePlugin.options.instrumentWidget.source.toString().length) {
                instrumentsLoader.source = QGroundControl.corePlugin.options.instrumentWidget.source
                switch(QGroundControl.corePlugin.options.instrumentWidget.widgetPosition) {
                case CustomInstrumentWidget.POS_TOP_LEFT:
                    instrumentsLoader.state  = "topLeftMode"
                    break;
                case CustomInstrumentWidget.POS_BOTTOM_LEFT:
                    instrumentsLoader.state  = "bottomLeftMode"
                    break;
                case CustomInstrumentWidget.POS_CENTER_LEFT:
                    instrumentsLoader.state  = "centerLeftMode"
                    break;
                case CustomInstrumentWidget.POS_TOP_RIGHT:
                    instrumentsLoader.state  = "topRightMode"
                    break;
                case CustomInstrumentWidget.POS_BOTTOM_RIGHT:
                    instrumentsLoader.state  = "bottomRightMode"
                    break;
                case CustomInstrumentWidget.POS_CENTER_RIGHT:
                default:
                    instrumentsLoader.state  = "centerRightMode"
                    break;
                }
            } else {
                instrumentsLoader.source = "qrc:/qml/QGCInstrumentWidgetAlternate.qml"
            }
        } else {
            instrumentsLoader.source = ""
        }
    }

    Connections {
        target:         QGroundControl.settingsManager.appSettings.virtualJoystick
//        onValueChanged: _setInstrumentWidget()
    }

    Connections {
        target:         QGroundControl.settingsManager.appSettings.showLargeCompass
//        onValueChanged: _setInstrumentWidget()
    }

    Connections {
        target: QGroundControl.airspaceManager
        onAirspaceVisibleChanged: {
             widgetRoot.showValues = !QGroundControl.airspaceManager.airspaceVisible
        }
    }

    Component.onCompleted: {
        _setInstrumentWidget()
    }

    //-- Map warnings
    Column {
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.top:                parent.verticalCenter
        spacing:                    ScreenTools.defaultFontPixelHeight

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _activeVehicle && !_activeVehicle.coordinate.isValid && _mainIsMap
            z:                          QGroundControl.zOrderTopMost
            color:                      mapPal.text
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       qsTr("No GPS Lock for Vehicle")
        }

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _activeVehicle && _activeVehicle.prearmError
            z:                          QGroundControl.zOrderTopMost
            color:                      mapPal.text
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       _activeVehicle ? _activeVehicle.prearmError : ""
        }

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _activeVehicle && _activeVehicle.prearmError
            width:                      ScreenTools.defaultFontPixelWidth * 50
            horizontalAlignment:        Text.AlignHCenter
            wrapMode:                   Text.WordWrap
            z:                          QGroundControl.zOrderTopMost
            color:                      mapPal.text
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       "The vehicle has failed a pre-arm check. In order to arm the vehicle, resolve the failure."
        }
    }
    Column {
        id:                     instrumentsColumn
        spacing:                ScreenTools.defaultFontPixelHeight * 0.25
        anchors.top:            parent.top
        anchors.topMargin:      QGroundControl.corePlugin.options.instrumentWidget.widgetTopMargin + (ScreenTools.defaultFontPixelHeight * 0.5)
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.5
        anchors.right:          parent.right
        //-------------------------------------------------------
        // Airmap Airspace Control
        AirspaceControl {
            id:                 airspaceControl
            width:              getPreferredInstrumentWidth()
            planView:           false
            visible:            _airspaceEnabled
            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
        }
        //-------------------------------------------------------
        //-- Instrument Panel
        Loader {
            id:                         instrumentsLoader
            anchors.margins:            ScreenTools.defaultFontPixelHeight * 0.5
            property var  qgcView:      widgetRoot.qgcView
            property real maxHeight:    widgetRoot ? widgetRoot.height - instrumentsColumn.y - airspaceControl.height - (ScreenTools.defaultFontPixelHeight * 4) : 0
            states: [
                State {
                    name:   "topRightMode"
                    AnchorChanges {
                        target:                 instrumentsLoader
                        anchors.verticalCenter: undefined
                        anchors.bottom:         undefined
                        anchors.top:            _root ? _root.top : undefined
                        anchors.right:          _root ? _root.right : undefined
                        anchors.left:           undefined
                    }
                },
                State {
                    name:   "centerRightMode"
                    AnchorChanges {
                        target:                 instrumentsLoader
                        anchors.top:            undefined
                        anchors.bottom:         undefined
                        anchors.verticalCenter: _root ? _root.verticalCenter : undefined
                        anchors.right:          _root ? _root.right : undefined
                        anchors.left:           undefined
                    }
                },
                State {
                    name:   "bottomRightMode"
                    AnchorChanges {
                        target:                 instrumentsLoader
                        anchors.top:            undefined
                        anchors.verticalCenter: undefined
                        anchors.bottom:         _root ? _root.bottom : undefined
                        anchors.right:          _root ? _root.right : undefined
                        anchors.left:           undefined
                    }
                },
                State {
                    name:   "topLeftMode"
                    AnchorChanges {
                        target:                 instrumentsLoader
                        anchors.verticalCenter: undefined
                        anchors.bottom:         undefined
                        anchors.top:            _root ? _root.top : undefined
                        anchors.right:          undefined
                        anchors.left:           _root ? _root.left : undefined
                    }
                },
                State {
                    name:   "centerLeftMode"
                    AnchorChanges {
                        target:                 instrumentsLoader
                        anchors.top:            undefined
                        anchors.bottom:         undefined
                        anchors.verticalCenter: _root ? _root.verticalCenter : undefined
                        anchors.right:          undefined
                        anchors.left:           _root ? _root.left : undefined
                    }
                },
                State {
                    name:   "bottomLeftMode"
                    AnchorChanges {
                        target:                 instrumentsLoader
                        anchors.top:            undefined
                        anchors.verticalCenter: undefined
                        anchors.bottom:         _root ? _root.bottom : undefined
                        anchors.right:          undefined
                        anchors.left:           _root ? _root.left : undefined
                    }
                }
            ]
        }
    }
    //-- Instrument Panel
    QGCInstrumentWidgetBottom {
        id:                     instrumentGadget
        anchors.margins:        ScreenTools.defaultFontPixelHeight / 2
        anchors.right:          altitudeSlider.visible ? altitudeSlider.left : parent.right
        anchors.bottom:         parent.bottom
        z:                      QGroundControl.zOrderWidgets
        _qgcView:                widgetRoot.qgcView
        _maxHeight:              parent.height - (anchors.margins * 2)
    }
    //-- Guided mode buttons
    Rectangle {
        id:                         guidedModeBar
        anchors.margins:            _barMargin
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        width:                      guidedModeColumn.width  + (_margins * 2)
        height:                     guidedModeColumn.height + (_margins * 2)
        radius:                     ScreenTools.defaultFontPixelHeight * 0.25
        color:                      "transparent"
        visible:                    _activeVehicle
        z:                          QGroundControl.zOrderWidgets
        state:                      "Shown"
        states: [
            State {
                name: "Shown"
                PropertyChanges { target: showAnimation; running: true  }
                PropertyChanges { target: guidedModeHideTimer; running: true }
            },
            State {
                name: "Hidden"
                PropertyChanges { target: hideAnimation; running: true  }
            }
        ]

        PropertyAnimation {
            id:             hideAnimation
            target:         guidedModeBar
            property:       "_barMargin"
            duration:       1000
            easing.type:    Easing.InOutQuad
            from:           guidedModeBar._showMargin
            to:             guidedModeBar._hideMargin
        }

        PropertyAnimation {
            id:             showAnimation
            target:         guidedModeBar
            property:       "_barMargin"
            duration:       250
            easing.type:    Easing.InOutQuad
            from:           guidedModeBar._hideMargin
            to:             guidedModeBar._showMargin
        }

        Timer {
            id:             guidedModeHideTimer
            interval:       7000
            running:        true
            onTriggered: {
                if (ScreenTools.isShortScreen) {
                    guidedModeBar.state = "Hidden"
                }
            }
        }



        Column {
            id:                 guidedModeColumn
            anchors.margins:    _margins
            anchors.top:        parent.top
            anchors.left:       parent.left
            spacing:            _margins

            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                color:      qgcPal.mapWidgetBorderDark
                text:       qsTr("Click in map to move vehicle")
                visible:    _activeVehicle && _activeVehicle.guidedMode && _activeVehicle.flying
            }

            Row {
                spacing: _margins * 2

                RoundImageButton {
                    width:       ScreenTools.defaultFontPixelHeight*4
                    height:      width
                    anchors.verticalCenter: parent.verticalCenter
                    imageResource: "/qmlimages/PauseUav.svg"
                    text:       qsTr("Pause")
                    visible:    (_activeVehicle && _activeVehicle.armed) && _activeVehicle.pauseVehicleSupported && _activeVehicle.flying
                    onClicked:  {
                        guidedModeHideTimer.restart()
                        widgetRoot.confirmAction(widgetRoot.actionPause)
                    }
                }

                RoundImageButton {
                    width:       ScreenTools.defaultFontPixelHeight*4
                    height:      width
                    anchors.verticalCenter: parent.verticalCenter
                    imageResource: "/qmlimages/parachute.svg"
                    text:       qsTr("Stop")
                    visible:    _activeVehicle && _activeVehicle.flying && (_activeVehicle.fixedWing || _activeVehicle.vtol)
                    onClicked:  {
                        guidedModeHideTimer.restart()
                        orbitMapCircle.hide()
                        widgetRoot.confirmAction(widgetRoot.actionEmergencyStop)
                    }
                }

                RoundImageButton {
                    width:       ScreenTools.defaultFontPixelHeight*6
                    height:      width
                    showborder:  true
                    text:        (_activeVehicle && _activeVehicle.flying) ? qsTr("Continue mission"):  qsTr("Start mission")
                    imageResource:  "/res/action.svg"
                    bordercolor:    qgcPal.buttonHighlight
                    visible:    _activeVehicle
                    onClicked:  {
                         orbitMapCircle.hide()
                        widgetRoot.confirmAction(_activeVehicle.flying ? widgetRoot.actionContinueMission : widgetRoot.actionStartMission)
                    }
                }

                RoundImageButton {
                    width:       ScreenTools.defaultFontPixelHeight*4
                    height:      width
                    anchors.verticalCenter: parent.verticalCenter
                    imageResource: (_activeVehicle && _activeVehicle.flying) ?  "/qmlimages/landing.svg":  "/qmlimages/takeoff.svg"
                    text:       (_activeVehicle && _activeVehicle.flying) ?  qsTr("Land"):  qsTr("Takeoff")
                    visible:    _activeVehicle && _activeVehicle.guidedModeSupported
                    onClicked:  {
                         orbitMapCircle.hide()
                         widgetRoot.confirmAction(_activeVehicle.flying ? widgetRoot.actionLand : widgetRoot.actionTakeoff)
                    }
                }
                RoundImageButton{
                    width:       ScreenTools.defaultFontPixelHeight*4
                    height:      width
                    anchors.verticalCenter: parent.verticalCenter
                    imageResource: "/qmlimages/Returnhome.svg"
                    text:       qsTr("RTL")
                    visible:    (_activeVehicle && _activeVehicle.armed) && _activeVehicle.guidedModeSupported && _activeVehicle.flying
                    onClicked:  {
                                widgetRoot.confirmAction(widgetRoot.actionRTL)
                                orbitMapCircle.hide()
                    }

                }


                RoundImageButton{
                    width:       ScreenTools.defaultFontPixelHeight*4
                    height:      width
                    anchors.verticalCenter: parent.verticalCenter
                    imageResource: "/qmlimages/high.svg"
                    visible:    (_activeVehicle && _activeVehicle.flying) && _activeVehicle.guidedModeSupported && _activeVehicle.armed
                    onClicked:  widgetRoot.confirmAction(widgetRoot.actionChangeAlt)
                }

                QGCButton {
                    pointSize:  widgetRoot._fontPointSize
                    text:       qsTr("Orbit")
                    visible:    false
                    onClicked:  widgetRoot.confirmAction(widgetRoot.actionOrbit)
                }

                QGCButton {
                    pointSize:  widgetRoot._fontPointSize
                    text:       qsTr("Land Abort")
                    visible:    showLandAbort
                    onClicked:  widgetRoot.confirmAction(widgetRoot.actionAbort)
                }
                RoundImageButton{
                    width:       ScreenTools.defaultFontPixelHeight*4
                    height:      width
                    anchors.verticalCenter: parent.verticalCenter
                    imageResource: _activeVehicle.vtolInFwdFlight ? "/qmlimages/change_coper.svg" : "/qmlimages/change_fixwing.svg"
                    text:       qsTr("Transition")       
                    visible:    _activeVehicle ? _activeVehicle.vtol && _activeVehicle.px4Firmware : false
                    onClicked:  widgetRoot.confirmAction(_activeVehicle.vtolInFwdFlight ? widgetRoot.actionVtolTransitionToMRFlight:widgetRoot.actionVtolTransitionToFwdFlight)
                }

            } // Row
        } // Column
    } // Rectangle - Guided mode buttons

    MouseArea {
        anchors.fill:   parent
        enabled:        guidedModeConfirm.visible && ! orbitMapCircle.visible
        onClicked:      widgetRoot.rejectGuidedModeConfirm()
    }

    // Action confirmation control
    SliderSwitch {
        id:                         guidedModeConfirm
        anchors.bottomMargin:       _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        visible:                    false
        z:                          QGroundControl.zOrderWidgets
        fontPointSize:              widgetRoot._fontPointSize

        onAccept: {
            guidedModeConfirm.visible = false
            guidedModeBar.visible = true
            var altitudeChange = 0
            if (altitudeSlider.visible) {
                altitudeChange = altitudeSlider.getAltitudeChangeValue()
                altitudeSlider.visible = false
            }
            widgetRoot.actionConfirmed(widgetRoot._actionData,altitudeChange)
            guidedModeHideTimer.restart()
        }

        onReject: widgetRoot.rejectGuidedModeConfirm()
    }

    GuidedAltitudeSlider {
        id:                 altitudeSlider
        anchors.margins:    _margins
        anchors.right:      parent.right
        anchors.topMargin:  ScreenTools.toolbarHeight + _margins
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        z:                  widgetRoot.z
        radius:             ScreenTools.defaultFontPixelWidth / 2
        width:              ScreenTools.defaultFontPixelWidth * 10
        color:              qgcPal.window
        visible:            false
    }
}
