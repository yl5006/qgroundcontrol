﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.3
import QtQuick.Controls 1.2
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Dialogs  1.2

import QGroundControl               1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controllers   1.0
import QGroundControl.FactSystem    1.0

FlightMap {
    id:                         flightMap
    anchors.fill:               parent
    mapName:                    _mapName
    allowGCSLocationCenter:     !userPanned
    allowVehicleLocationCenter: !_keepVehicleCentered

    property alias  scaleState: mapScale.state

    property var    missionController
    property var    guidedActionsController
    property var    flightWidgets
    property var    rightPanelWidth
    property var    qgcView                             ///< QGCView control which contains this map

    property var    _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle
    property var    _activeVehicleCoordinate:   _activeVehicle ? _activeVehicle.coordinate : QtPositioning.coordinate()
    property var    _gotoHereCoordinate:        QtPositioning.coordinate()
    property real   _toolButtonTopMargin:       parent.height - ScreenTools.availableHeight + (ScreenTools.defaultFontPixelHeight / 2)

    property bool   _disableVehicleTracking:    false
    property bool   _keepVehicleCentered:       _mainIsMap ? false : true

    // Track last known map position and zoom from Fly view in settings
    onZoomLevelChanged: QGroundControl.flightMapZoom = zoomLevel
    onCenterChanged:    QGroundControl.flightMapPosition = center

    // When the user pans the map we stop responding to vehicle coordinate updates until the panRecenterTimer fires
    onUserPannedChanged: {
        _disableVehicleTracking = true
        panRecenterTimer.start()
    }

    function pointInRect(point, rect) {
        return point.x > rect.x &&
                point.x < rect.x + rect.width &&
                point.y > rect.y &&
                point.y < rect.y + rect.height;
    }

    property real _animatedLatitudeStart
    property real _animatedLatitudeStop
    property real _animatedLongitudeStart
    property real _animatedLongitudeStop
    property real animatedLatitude
    property real animatedLongitude

    onAnimatedLatitudeChanged: flightMap.center = QtPositioning.coordinate(animatedLatitude, animatedLongitude)
    onAnimatedLongitudeChanged: flightMap.center = QtPositioning.coordinate(animatedLatitude, animatedLongitude)

    NumberAnimation on animatedLatitude { id: animateLat; from: _animatedLatitudeStart; to: _animatedLatitudeStop; duration: 1000 }
    NumberAnimation on animatedLongitude { id: animateLong; from: _animatedLongitudeStart; to: _animatedLongitudeStop; duration: 1000 }

    function animatedMapRecenter(fromCoord, toCoord) {
        _animatedLatitudeStart = fromCoord.latitude
        _animatedLongitudeStart = fromCoord.longitude
        _animatedLatitudeStop = toCoord.latitude
        _animatedLongitudeStop = toCoord.longitude
        animateLat.start()
        animateLong.start()
    }

    function recenterNeeded() {
        var vehiclePoint = flightMap.fromCoordinate(_activeVehicleCoordinate, false /* clipToViewport */)
        var centerViewport = Qt.rect(0, 0, width, height)
        return !pointInRect(vehiclePoint, centerViewport)
    }

    function updateMapToVehiclePosition() {
        // We let FlightMap handle first vehicle position
        if (firstVehiclePositionReceived && _activeVehicleCoordinate.isValid && !_disableVehicleTracking) {
            if (_keepVehicleCentered) {
                flightMap.center = _activeVehicleCoordinate
            } else {
                if (firstVehiclePositionReceived && recenterNeeded()) {
                    animatedMapRecenter(flightMap.center, _activeVehicleCoordinate)
                }
            }
        }
    }

    Timer {
        id:         panRecenterTimer
        interval:   10000
        running:    false

        onTriggered: {
            _disableVehicleTracking = false
            updateMapToVehiclePosition()
        }
    }

    Timer {
        interval:       500
        running:        true
        repeat:         true
        onTriggered:    updateMapToVehiclePosition()
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }
    QGCMapPalette { id: mapPal; lightColors: isSatelliteMap }

    Connections {
        target: missionController

        onNewItemsFromVehicle: {
            var visualItems = missionController.visualItems
            if (visualItems && visualItems.count != 1) {
                mapFitFunctions.fitMapViewportToMissionItems()
                firstVehiclePositionReceived = true
            }
        }
    }

    GeoFenceController {
        id: geoFenceController
        Component.onCompleted: start(false /* editMode */)
    }

    RallyPointController {
        id: rallyPointController
        Component.onCompleted: start(false /* editMode */)
    }

    // The following code is used to track vehicle states such that we prompt to remove mission from vehicle when mission completes

    property bool vehicleArmed:                 _activeVehicle ? _activeVehicle.armed : false
    property bool vehicleWasArmed:              false
    property bool vehicleInMissionFlightMode:   _activeVehicle ? (_activeVehicle.flightMode === _activeVehicle.missionFlightMode) : false
    property bool promptForMissionRemove:       false

    onVehicleArmedChanged: {
        if (vehicleArmed) {
            if (!promptForMissionRemove) {
                promptForMissionRemove = vehicleInMissionFlightMode
                vehicleWasArmed = true
            }
        } else {
            if (promptForMissionRemove && (missionController.containsItems || geoFenceController.containsItems || rallyPointController.containsItems)) {
                qgcView.showDialog(removeMissionDialogComponent, qsTr("Flight complete"), showDialogDefaultWidth, StandardButton.No | StandardButton.Yes)
            }
            promptForMissionRemove = false
        }
    }

    onVehicleInMissionFlightModeChanged: {
        if (!promptForMissionRemove && vehicleArmed) {
            promptForMissionRemove = true
        }
    }

    Component {
        id: removeMissionDialogComponent

        QGCViewMessage {
            message: qsTr("Do you want to remove the mission from the vehicle?")

            function accept() {
                missionController.removeAllFromVehicle()
                geoFenceController.removeAllFromVehicle()
                rallyPointController.removeAllFromVehicle()
                hideDialog()

            }
        }
    }

    MapFitFunctions {
        id:                         mapFitFunctions
        map:                        _flightMap
        usePlannedHomePosition:     false
        mapMissionController:      missionController
        mapGeoFenceController:     geoFenceController
        mapRallyPointController:   rallyPointController

        property real leftToolWidth: 0//   toolStrip.x + toolStrip.width
    }

    ExclusiveGroup {
        id: _mapTypeButtonsExclusiveGroup
    }
    ExclusiveGroup {
        id: dropButtonsExclusiveGroup
    }
    //--Tool Buttons
    Row {
        id:                 toolColumn
        anchors.topMargin:  ScreenTools.toolbarHeight*1.8 + ScreenTools.defaultFontPixelWidth
        anchors.top:        parent.top
        anchors.horizontalCenter:   parent.horizontalCenter
        visible:            _mainIsMap
        z:                  QGroundControl.zOrderWidgets
        //-- Map Center Control
        CenterMapDropButton {
            id:                     centerMapDropButton
            z:                      QGroundControl.zOrderWidgets
            exclusiveGroup:         dropButtonsExclusiveGroup
            map:                    _flightMap
            mapFitViewport:         Qt.rect(leftToolWidth, _toolButtonTopMargin, flightMap.width - leftToolWidth - rightPanelWidth, flightMap.height - _toolButtonTopMargin)
            usePlannedHomePosition: false
            geoFenceController:     geoFenceController
            missionController:      missionController
            rallyPointController:   rallyPointController
            showFollowVehicle:      true
            followVehicle:          _keepVehicleCentered
            onFollowVehicleChanged: _keepVehicleCentered = followVehicle

            property real leftToolWidth:    centerMapDropButton.x + centerMapDropButton.width
        }


        Rectangle {
            height:     parent.height*0.8
            width:      1
            color:      "grey"
        }
        //-- Map Type Control
        DropButton {
            id:                 mapTypeButton
            dropDirection:      dropDown
            buttonImage:        "/qmlimages/MapType.svg"
            viewportMargins:    ScreenTools.defaultFontPixelWidth / 2
            exclusiveGroup:     dropButtonsExclusiveGroup
            z:                  QGroundControl.zOrderWidgets
            lightBorders:       isSatelliteMap
            visible:            false
            dropDownComponent: Component {
                Column {
                    spacing: ScreenTools.defaultFontPixelWidth


                    Row {
                        spacing: ScreenTools.defaultFontPixelWidth
                        Repeater {
                            model: QGroundControl.settingsManager.flightMapSettings.mapType.enumStrings
                            RoundImageButton {
                                width:          ScreenTools.defaultFontPixelHeight*3
                                height:         width
                                exclusiveGroup: _mapTypeButtonsExclusiveGroup
                                checked:        QGroundControl.settingsManager.flightMapSettings.mapType.value == index
                                imageResource:  index==0?"/qmlimages/map_street.svg":index==1?"/qmlimages/map_gps.svg" :"/qmlimages/map_terrain.svg"
                                bordercolor:    qgcPal.buttonHighlight
                                showcheckcolor: true
                                onClicked: {
                                    QGroundControl.settingsManager.flightMapSettings.mapType.value = index
                                    checked = true
                                    mapTypeButton.hideDropDown()
                                }
                            }
                        }
                    }
                    SubMenuButton {
                        imageResource:      "/qmlimages/clearmission.svg"
                        enabled:    QGroundControl.multiVehicleManager.activeVehicle
                        text:               qsTr("清除飞行路线")//qsTr("Clear Flight Trails")
                        onClicked:  {
                            QGroundControl.multiVehicleManager.activeVehicle.clearTrajectoryPoints()
                            dropButtonsExclusiveGroup.current = null
                        }
                    }
                }
            }
        }
        Rectangle {
            height:     parent.height*0.8
            width:      1
            color:      "grey"
        }
        //-- Zoom Map In
        RoundButton {
            id:                 mapZoomPlus
            visible:            !ScreenTools.isTinyScreen && _mainIsMap
            buttonImage:        "/qmlimages/ZoomPlus.svg"
            exclusiveGroup:     dropButtonsExclusiveGroup
            lightBorders:       isSatelliteMap
            onClicked: {
                if(_flightMap)
                    _flightMap.zoomLevel += 0.5
                checked = false
            }
        }
        Rectangle {
            height:     parent.height*0.8
            width:      1
            color:      "grey"
        }
        //-- Zoom Map Out
        RoundButton {
            id:                 mapZoomMinus
            visible:            !ScreenTools.isTinyScreen && _mainIsMap
            buttonImage:        "/qmlimages/ZoomMinus.svg"
            exclusiveGroup:     dropButtonsExclusiveGroup
            lightBorders:       isSatelliteMap
            onClicked: {
                if(_flightMap)
                    _flightMap.zoomLevel -= 0.5
                checked = false
            }
        }
        Rectangle {
            height:     parent.height*0.8
            width:      1
            color:      "grey"
        }
        //-- 声音
        RoundButton {
            id:                 voice
            buttonImage:        checked ? "/qmlimages/novoice.svg":"/qmlimages/voice.svg"
            lightBorders:       isSatelliteMap
            property Fact _audioMuted: QGroundControl.settingsManager.appSettings.audioMuted
            checked:      _audioMuted.value==1
            onClicked: {
                _audioMuted.value = checked ? 1 : 0
            }
        }
        Rectangle {
            height:     parent.height*0.8
            width:      1
            color:      "grey"
        }
        //-- 虚拟遥控
        RoundButton {
            id:                 yaokong
            buttonImage:        "/qmlimages/yaokong.svg"
            lightBorders:       isSatelliteMap
            property Fact       _virtualJoystick: QGroundControl.settingsManager.appSettings.virtualJoystick
            checked: _virtualJoystick ?
                         (_virtualJoystick.typeIsBool ?
                              (_virtualJoystick.value === true ? Qt.Checked : Qt.Unchecked) :
                              (_virtualJoystick.value === 1 ? Qt.Checked : Qt.Unchecked)) :
                         Qt.Unchecked
            onClicked: {
                _virtualJoystick.value = checked ? 1 : 0
            }
        }
    }




    // Add trajectory points to the map
    MapItemView {
        model: _mainIsMap ? _activeVehicle ? _activeVehicle.trajectoryPoints : 0 : 0

        delegate: MapPolyline {
            line.width: 3
            line.color: "red"
            z:          QGroundControl.zOrderTrajectoryLines
            path: [
                object.coordinate1,
                object.coordinate2,
            ]
        }
    }

    // Add the vehicles to the map
    MapItemView {
        model: QGroundControl.multiVehicleManager.vehicles

        delegate: VehicleMapItem {
            vehicle:        object
            coordinate:     object.coordinate
            isSatellite:    flightMap.isSatelliteMap
            size:           _mainIsMap ? ScreenTools.defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight
            z:              QGroundControl.zOrderVehicles
        }
    }

    // Add the mission item visuals to the map
    Repeater {
        model: _mainIsMap ? missionController.visualItems : 0

        delegate: MissionItemMapVisual {
            map:        flightMap
            onClicked:  guidedActionsController.confirmAction(guidedActionsController.actionSetWaypoint, object.sequenceNumber)
        }
    }

    // Add lines between waypoints
    MissionLineView {
        model:  _mainIsMap ? missionController.waypointLines : 0
    }
    // Add lines between waypoints
    MissionLineView {
        model: _mainIsMap ? missionController.jumpwaypointLines : 0
    }


    GeoFenceMapVisuals {
        map:                    flightMap
        myGeoFenceController:   geoFenceController
        interactive:            false
        homePosition:           _activeVehicle && _activeVehicle.homePosition.isValid ? _activeVehicle.homePosition : undefined
    }

    // Rally points on map
    MapItemView {
        model: rallyPointController.points

        delegate: MapQuickItem {
            id:             itemIndicator
            anchorPoint.x:  sourceItem.anchorPointX
            anchorPoint.y:  sourceItem.anchorPointY
            coordinate:     object.coordinate
            z:              QGroundControl.zOrderMapItems

            sourceItem: MissionItemIndexLabel {
                id:         itemIndexLabel
                label:      qsTr("R", "rally point map item label")
                simpleindex:   1
            }
        }
    }

    // GoTo here waypoint
    MapQuickItem {
        coordinate:     _gotoHereCoordinate
        visible:        _activeVehicle && _activeVehicle.guidedMode && _gotoHereCoordinate.isValid
        z:              QGroundControl.zOrderMapItems
        anchorPoint.x:  sourceItem.anchorPointX
        anchorPoint.y:  sourceItem.anchorPointY

        sourceItem: MissionItemIndexLabel {
            checked: true
            label:   qsTr("G", "Goto here waypoint") // second string is translator's hint.
            simpleindex:   1
        }
    }

    // Handle guided mode clicks
    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (guidedActionsController.showGotoLocation) {
                _gotoHereCoordinate = flightMap.toCoordinate(Qt.point(mouse.x, mouse.y), false /* clipToViewPort */)
                guidedActionsController.confirmAction(guidedActionsController.actionGoto, _gotoHereCoordinate)
            }
        }
    }

    MapScale {
        id:                     mapScale
        anchors.verticalCenter:         toolColumn.verticalCenter
        anchors.leftMargin:     ScreenTools.defaultFontPixelHeight*2
        anchors.left:           toolColumn.right
        mapControl:             flightMap
        visible:                !ScreenTools.isTinyScreen
        state:                  "bottomMode"
        states: [
            State {
                name:   "topMode"
                AnchorChanges {
                }
            },
            State {
                name:   "bottomMode"
                AnchorChanges {
                }
            }
        ]
    }

}
