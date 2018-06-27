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

import QGroundControl                           1.0
import QGroundControl.ScreenTools               1.0
import QGroundControl.Controls                  1.0
import QGroundControl.Palette                   1.0
import QGroundControl.Vehicle                   1.0
import QGroundControl.FlightMap                 1.0

Item {
    id: _root

    property var    qgcView
    property bool   useLightColors
    property var    missionController

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _isSatellite:           _mainIsMap ? (_flightMap ? _flightMap.isSatelliteMap : true) : true
    property bool   _lightWidgetBorders:    _isSatellite

    readonly property real _margins:        ScreenTools.defaultFontPixelHeight * 0.5
    readonly property real _toolButtonTopMargin:    parent.height - ScreenTools.availableHeight + (ScreenTools.defaultFontPixelHeight / 2)

    QGCMapPalette { id: mapPal; lightColors: useLightColors }
    QGCPalette    { id: qgcPal }

    property real _fontPointSize: ScreenTools.isMobile ? ScreenTools.largeFontPointSize : ScreenTools.defaultFontPointSize
    property bool showGotoLocation:     _activeVehicle && _activeVehicle.guidedMode && _activeVehicle.flying

    readonly property int confirmHome:                  1
    readonly property int confirmLand:                  2
    readonly property int confirmTakeoff:               3
    readonly property int confirmArm:                   4
    readonly property int confirmDisarm:                5
    readonly property int confirmEmergencyStop:         6
    readonly property int confirmChangeAlt:             7
    readonly property int confirmGoTo:                  8
    readonly property int confirmSetWaypoint:           9
    readonly property int confirmOrbit:                 10
    readonly property int confirmAbort:                 11
    readonly property int confirmStartMission:          12
    readonly property int confirmContinueMission:       13
    readonly property int confirmResumeMission:         14
    readonly property int confirmResumeMissionReady:    15
    readonly property int confirmPause:                 16

    property int    confirmActionCode
    property var    _actionData
    property real   _showMargin:    _margins
    property real   _hideMargin:    _margins - guidedModeBar.height
    property real   _barMargin:     _showMargin

    function actionConfirmed(actionData) {
        switch (confirmActionCode) {
        case confirmHome:
            _activeVehicle.guidedModeRTL()
            break;
        case confirmLand:
            _activeVehicle.guidedModeLand()
            break;
        case confirmTakeoff:
            var altitude1 = altitudeSlider.getValue()
            if (!isNaN(altitude1)) {
                _activeVehicle.guidedModeTakeoff(altitude1)
            }
            break;
        case confirmArm:
            _activeVehicle.armed = true
            break;
        case confirmDisarm:
            _activeVehicle.armed = false
            break;
        case confirmEmergencyStop:
            _activeVehicle.emergencyStop()
            break;
        case confirmChangeAlt:
            var altitude2 = altitudeSlider.getValue()
            if (!isNaN(altitude2)) {
                _activeVehicle.guidedModeChangeAltitude(altitude2)
            }
            break;
        case confirmGoTo:
            _activeVehicle.guidedModeGotoLocation(_flightMap._gotoHereCoordinate)
            break;
        case confirmSetWaypoint:
            _activeVehicle.setCurrentMissionSequence(actionData)
            break;
        case confirmOrbit:
            //-- All parameters controlled by RC
            _activeVehicle.guidedModeOrbit()
            //-- Center on current flight map position and orbit with a 50m radius (velocity/direction controlled by the RC)
            //_activeVehicle.guidedModeOrbit(QGroundControl.flightMapPosition, 50.0)
            break;
        case confirmAbort:
            _activeVehicle.abortLanding(50)     // hardcoded value for climbOutAltitude that is currently ignored
            break;
        case confirmResumeMission:
            missionController.resumeMission(missionController.resumeMissionIndex)
            break
        case confirmResumeMissionReady:
            _activeVehicle.startMission()
            break
        case confirmStartMission:
        case confirmContinueMission:
            _activeVehicle.startMission()
            break
        case confirmPause:
            _activeVehicle.pauseVehicle()
            break
        default:
            console.warn(qsTr("Internal error: unknown confirmActionCode"), confirmActionCode)
        }
    }

    function rejectGuidedModeConfirm() {
        guidedModeConfirm.visible = false
        guidedModeBar.visible = true
        altitudeSlider.visible = false
        _flightMap._gotoHereCoordinate = QtPositioning.coordinate()
        guidedModeHideTimer.restart()
    }

    function confirmAction(actionCode,actionData) {
        guidedModeHideTimer.stop()
        confirmActionCode = actionCode
        _actionData = actionData
        switch (confirmActionCode) {
        case confirmArm:
            guidedModeConfirm.confirmText = qsTr("解锁")
            break;
        case confirmDisarm:
            guidedModeConfirm.confirmText = qsTr("加锁")
            break;
        case confirmEmergencyStop:
            guidedModeConfirm.confirmText = qsTr("!电机加锁，开伞")
            break;
        case confirmTakeoff:
            altitudeSlider.visible = true
            altitudeSlider.setInitialValueMeters(3)
            guidedModeConfirm.confirmText = qsTr("起飞")
            break;
        case confirmLand:
            guidedModeConfirm.confirmText = qsTr("降落")
            break;
        case confirmHome:
            guidedModeConfirm.confirmText = qsTr("返航")
            break;
        case confirmChangeAlt:
            altitudeSlider.visible = true
            altitudeSlider.setInitialValueAppSettingsDistanceUnits(_activeVehicle.altitudeRelative.value)
            guidedModeConfirm.confirmText = qsTr("改变高度")
            break;
        case confirmGoTo:
            guidedModeConfirm.confirmText = qsTr("移动至引导点")
            break;
        case confirmSetWaypoint:
            guidedModeConfirm.confirmText = qsTr("改变飞行航点")
            break;
        case confirmOrbit:
            guidedModeConfirm.confirmText = qsTr("enter orbit mode")
            break;
        case confirmAbort:
            guidedModeConfirm.confirmText = qsTr("abort landing")
            break;
        case confirmResumeMission:
             guidedModeConfirm.confirmText = qsTr("恢复任务")
            break
        case confirmResumeMissionReady:
             guidedModeConfirm.confirmText = qsTr("恢复任务")
            break
        case confirmStartMission:
             guidedModeConfirm.confirmText = qsTr("开始任务")
            break
        case confirmContinueMission:
             guidedModeConfirm.confirmText = qsTr("继续任务")
            break
        case confirmPause:
             guidedModeConfirm.confirmText = qsTr("暂停(悬停或盘旋)")
           break
        }
        guidedModeBar.visible = false
        guidedModeConfirm.visible = true
    }

    function getPreferredInstrumentWidth() {
        if(ScreenTools.isMobile) {
            return mainWindow.width * 0.15
        } else if(ScreenTools.isHugeScreen) {
            return mainWindow.width * 0.11
        }
        return ScreenTools.defaultFontPixelWidth * 30
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
            text:                       qsTr("GPS未锁定")//"No GPS Lock for Vehicle"
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

    //-- Instrument Panel
    Loader {
        id:                     instrumentsLoader
        anchors.margins:        ScreenTools.defaultFontPixelHeight / 2
        anchors.right:          parent.right
        z:                      QGroundControl.zOrderWidgets
        property var  qgcView:  _root.qgcView
        property real maxHeight:parent.height - (anchors.margins * 2)
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
    //-- Instrument Panel
    QGCInstrumentWidgetBottom {
        id:                     instrumentGadget
        anchors.margins:        ScreenTools.defaultFontPixelHeight / 2
        anchors.right:          altitudeSlider.visible ? altitudeSlider.left : parent.right
        anchors.bottom:         parent.bottom
        z:                      QGroundControl.zOrderWidgets
        _qgcView:                _root.qgcView
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
                text:       qsTr("点击地图引导飞行")//"Click in map to move vehicle"
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
                        _root.confirmAction(_root.confirmPause)
                    }
                }

                RoundImageButton {
                    width:       ScreenTools.defaultFontPixelHeight*4
                    height:      width
                    anchors.verticalCenter: parent.verticalCenter
                    imageResource: "/qmlimages/parachute.svg"
                    text:       qsTr("Stop")
                    visible:    _activeVehicle && _activeVehicle.flying && _activeVehicle.fixedWing
                    onClicked:  {
                        guidedModeHideTimer.restart()
                        _root.confirmAction(_root.confirmEmergencyStop)
                    }
                }

                RoundImageButton {
                    width:       ScreenTools.defaultFontPixelHeight*6
                    height:      width
                    showborder:  true
                    text:        (_activeVehicle && _activeVehicle.flying) ? qsTr("继续任务"):  qsTr("开始任务")
                    imageResource:  "/res/action.svg"
                    bordercolor:    qgcPal.buttonHighlight
                    visible:    _activeVehicle
                    onClicked:  _root.confirmAction(_activeVehicle.flying ? _root.confirmContinueMission : _root.confirmStartMission)
                }

                RoundImageButton {
                    width:       ScreenTools.defaultFontPixelHeight*4
                    height:      width
                    anchors.verticalCenter: parent.verticalCenter
                    imageResource: (_activeVehicle && _activeVehicle.flying) ?  "/qmlimages/landing.svg":  "/qmlimages/takeoff.svg"
                    text:       (_activeVehicle && _activeVehicle.flying) ?  qsTr("Land"):  qsTr("Takeoff")
                    visible:    _activeVehicle && _activeVehicle.guidedModeSupported
                    onClicked:  _root.confirmAction(_activeVehicle.flying ? _root.confirmLand : _root.confirmTakeoff)
                }
                RoundImageButton{
                    width:       ScreenTools.defaultFontPixelHeight*4
                    height:      width
                    anchors.verticalCenter: parent.verticalCenter
                    imageResource: "/qmlimages/Returnhome.svg"
                    text:       qsTr("RTL")
                    visible:    (_activeVehicle && _activeVehicle.armed) && _activeVehicle.guidedModeSupported && _activeVehicle.flying
                    onClicked:  _root.confirmAction(_root.confirmHome)
                }


                QGCButton {
                    pointSize:  _root._fontPointSize
                    text:       qsTr("改变高度")
                    anchors.verticalCenter: parent.verticalCenter
                    visible:    (_activeVehicle && _activeVehicle.flying) && _activeVehicle.guidedModeSupported && _activeVehicle.armed
                    onClicked:  _root.confirmAction(_root.confirmChangeAlt)
                }

                QGCButton {
                    pointSize:  _root._fontPointSize
                    text:       qsTr("Orbit")
                    visible:    false//(_activeVehicle && _activeVehicle.flying) && _activeVehicle.orbitModeSupported && _activeVehicle.armed
                    onClicked:  _root.confirmAction(_root.confirmOrbit)
                }

                QGCButton {
                    pointSize:  _root._fontPointSize
                    text:       qsTr("Abort")
                    visible:    false//_activeVehicle && _activeVehicle.flying && _activeVehicle.fixedWing
                    onClicked:  _root.confirmAction(_root.confirmAbort)
                }

            } // Row
        } // Column
    } // Rectangle - Guided mode buttons

    MouseArea {
        anchors.fill:   parent
        enabled:        guidedModeConfirm.visible
        onClicked:      _root.rejectGuidedModeConfirm()
    }

    // Action confirmation control
    SliderSwitch {
        id:                         guidedModeConfirm
        anchors.bottomMargin:       _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        visible:                    false
        z:                          QGroundControl.zOrderWidgets
        fontPointSize:              _root._fontPointSize

        onAccept: {
            guidedModeConfirm.visible = false
            guidedModeBar.visible = true
            _root.actionConfirmed(_root._actionData)
            altitudeSlider.visible = false
            guidedModeHideTimer.restart()
        }

        onReject: _root.rejectGuidedModeConfirm()
    }

    //-- Altitude slider
    Rectangle {
        id:                 altitudeSlider
        anchors.margins:    _margins
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        color:              qgcPal.window
        width:              ScreenTools.defaultFontPixelWidth * 10
        opacity:            0.8
        visible:            false

        function setInitialValueMeters(meters) {
            altSlider.value = QGroundControl.metersToAppSettingsDistanceUnits(meters)
        }

        function setInitialValueAppSettingsDistanceUnits(height) {
            altSlider.value = height
        }

        /// Returns NaN for bad value
        function getValue() {
            var value =  parseFloat(altField.text)
            if (!isNaN(value)) {
                return QGroundControl.appSettingsDistanceUnitsToMeters(value);
            } else {
                return value;
            }
        }

        Column {
            id:                 headerColumn
            anchors.margins:    _margins
            anchors.top:        parent.top
            anchors.left:       parent.left
            anchors.right:      parent.right

            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("高度参考")
            }

            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: QGroundControl.appSettingsDistanceUnitsString
            }

            QGCTextField {
                id:             altField
                anchors.left:   parent.left
                anchors.right:  parent.right
                text:           altSlider.value.toFixed(1)
            }
        }

        Slider {
            id:                 altSlider
            anchors.margins:    _margins
            anchors.top:        headerColumn.bottom
            anchors.bottom:     parent.bottom
            anchors.left:       parent.left
            anchors.right:      parent.right
            orientation:        Qt.Vertical
            minimumValue:       QGroundControl.metersToAppSettingsDistanceUnits(0)
            maximumValue:       QGroundControl.metersToAppSettingsDistanceUnits((_activeVehicle && _activeVehicle.flying) ? Math.round((_activeVehicle.altitudeRelative.value + 100) / 100) * 100 : 10)
        }
    }
}
