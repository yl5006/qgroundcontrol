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
    planView:                   false

    property alias  scaleState: mapScale.state

    // The following properties must be set by the consumer
    property var    planMasterController
    property var    rightPanelWidth
    property var    qgcView                             ///< QGCView control which contains this map
    property var    multiVehicleView                    ///< true: multi-vehicle view, false: single vehicle view

    property rect   centerViewport:             Qt.rect(0, 0, width, height)

    property var    _planMasterController:      planMasterController
    property var    _missionController:         _planMasterController.missionController
    property var    _geoFenceController:        _planMasterController.geoFenceController
    property var    _rallyPointController:      _planMasterController.rallyPointController
    property var    _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle
    property var    _activeVehicleCoordinate:   _activeVehicle ? _activeVehicle.coordinate : QtPositioning.coordinate()
    property real   _toolButtonTopMargin:       parent.height - ScreenTools.availableHeight + (ScreenTools.defaultFontPixelHeight / 2)

    property bool   _disableVehicleTracking:    false
    property bool   _keepVehicleCentered:       _mainIsMap ? false : true

    // Track last known map position and zoom from Fly view in settings
    onZoomLevelChanged: QGroundControl.flightMapZoom = zoomLevel
    onCenterChanged:    QGroundControl.flightMapPosition = center

    // When the user pans the map we stop responding to vehicle coordinate updates until the panRecenterTimer fires
    onUserPannedChanged: {
        if (userPanned) {
            console.log("user panned")
            userPanned = false
            _disableVehicleTracking = true
            panRecenterTimer.restart()
        }
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
        var toolStripRightEdge =  0;//mapFromItem(toolStrip, toolStrip.x, 0).x + toolStrip.width
        var instrumentsWidth = 0
        if (QGroundControl.corePlugin.options.instrumentWidget && QGroundControl.corePlugin.options.instrumentWidget.widgetPosition === CustomInstrumentWidget.POS_TOP_RIGHT) {
            // Assume standard instruments
            instrumentsWidth = flightWidgets.getPreferredInstrumentWidth()
        }
        var centerViewport = Qt.rect(toolStripRightEdge, 0, width - toolStripRightEdge - instrumentsWidth, height)
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
        target: _missionController

        onNewItemsFromVehicle: {
            var visualItems = _missionController.visualItems
            if (visualItems && visualItems.count !== 1) {
                mapFitFunctions.fitMapViewportToMissionItems()
                firstVehiclePositionReceived = true
            }
        }
    }

    ExclusiveGroup {
        id: _mapTypeButtonsExclusiveGroup
    }

    MapFitFunctions {
        id:                         mapFitFunctions // The name for this id cannot be changed without breaking references outside of this code. Beware!
        map:                        _flightMap
        usePlannedHomePosition:     false
        planMasterController:       _planMasterController

        property real leftToolWidth: 0//   toolStrip.x + toolStrip.width
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
            geoFenceController:     _geoFenceController
            missionController:      _missionController
            rallyPointController:   _rallyPointController
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
            map:            flightMap
            size:           _mainIsMap ? ScreenTools.defaultFontPixelHeight * 2 : ScreenTools.defaultFontPixelHeight
            z:              QGroundControl.zOrderVehicles
        }
    }

    // Add ADSB vehicles to the map
    MapItemView {
        model: _activeVehicle ? _activeVehicle.adsbVehicles : 0

        property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

        delegate: VehicleMapItem {
            coordinate:     object.coordinate
            altitude:       object.altitude
            callsign:       object.callsign
            heading:        object.heading
            map:            flightMap
            z:              QGroundControl.zOrderVehicles
        }
    }
    // Add the items associated with each vehicles flight plan to the map
    Repeater {
        model: QGroundControl.multiVehicleManager.vehicles

        PlanMapItems {
            map:                flightMap
            largeMapView:       _mainIsMap
            masterController:   masterController
            isActiveVehicle:    _vehicle.active

            property var _vehicle: object

            PlanMasterController {
                id: masterController
                Component.onCompleted: startStaticActiveVehicle(object)
            }
        }
    }

    // Allow custom builds to add map items
    CustomMapItems {
        map:            flightMap
        largeMapView:   _mainIsMap
    }

    GeoFenceMapVisuals {
        map:                    flightMap
        myGeoFenceController:   _geoFenceController
        interactive:            false
        planView:               false
        homePosition:           _activeVehicle && _activeVehicle.homePosition.isValid ? _activeVehicle.homePosition :  QtPositioning.coordinate()
    }

    // Rally points on map
    MapItemView {
        model: _rallyPointController.points

        delegate: MapQuickItem {
            id:             itemIndicator
            anchorPoint.x:  sourceItem.anchorPointX
            anchorPoint.y:  sourceItem.anchorPointY * 2
            coordinate:     object.coordinate
            z:              QGroundControl.zOrderMapItems

            sourceItem: MissionItemIndexLabel {
                id:         itemIndexLabel
                label:      qsTr("R", "rally point map item label")
                simpleindex:   1
            }
        }
    }

    // Camera trigger points
    MapItemView {
        model: _activeVehicle ? _activeVehicle.cameraTriggerPoints : 0

        delegate: CameraTriggerIndicator {
            coordinate:     object.coordinate
            z:              QGroundControl.zOrderTopMost
        }
    }
    Connections {
        target: QGroundControl.multiVehicleManager.activeVehicle
        onLastcameracoordinateChanged: {
            cameratrig.visible =true
            resetTimer.start()
        }
    }
    CameraTriggerIndicator {
         id:             cameratrig
         visible:       _activeVehicle
         coordinate:     _activeVehicle.lastcameracoordinate
         z:              QGroundControl.zOrderTopMost
         Timer {
             id:             resetTimer
             interval:       1000
             onTriggered: {
                 cameratrig.visible  = false
             }
         }
    }

    MapQuickItem {
        id:             gotoLocationItem
        visible:        false
        z:              QGroundControl.zOrderMapItems
        anchorPoint.x:  sourceItem.anchorPointX
        anchorPoint.y:  sourceItem.anchorPointY*2

        sourceItem: MissionItemIndexLabel {
            checked:    true
            index:      -1
            label:      qsTr("G", "Goto here waypoint")
            simpleindex:   1
        }

        function show(coord) {
            gotoLocationItem.coordinate = coord
            gotoLocationItem.visible = true
        }

        function hide() {
            gotoLocationItem.visible = false
        }
    }

    QGCMapCircleVisuals {
        id:         orbitMapCircle
        mapControl: parent
        mapCircle:  _mapCircle
        visible:    false

        property alias center:  _mapCircle.center

        readonly property real defaultRadius: 30

        function show(coord) {
            _mapCircle.radius.rawValue = defaultRadius
            orbitMapCircle.center = coord
            orbitMapCircle.visible = true
        }

        function hide() {
            orbitMapCircle.visible = false
        }

        function radius() {
            return _mapCircle.radius.rawValue
        }

        Component.onCompleted: flightWidgets.orbitMapCircle = orbitMapCircle

        QGCMapCircle {
            id:                 _mapCircle
            interactive:        true
            radius.rawValue:    30
        }
    }

    // Handle guided mode clicks
    MouseArea {
        anchors.fill: parent

        Menu {
            id: clickMenu

            property var coord

            MenuItem {
                text:           qsTr("到这里")
                visible:        flightWidgets.showGotoLocation

                onTriggered: {
                    gotoLocationItem.show(clickMenu.coord)
                    orbitMapCircle.hide()
                    flightWidgets.confirmAction(flightWidgets.actionGoto, clickMenu.coord)
                }
            }

            MenuItem {
                text:           qsTr("绕圈")
                visible:        flightWidgets.showOrbit

                onTriggered: {
                    orbitMapCircle.show(clickMenu.coord)
                    console.log(_mapCircle.radius.rawValue)
                    gotoLocationItem.hide()
                    flightWidgets.confirmAction(flightWidgets.actionOrbit, clickMenu.coord)
                }
            }
        }

        onClicked: {
            if (flightWidgets.guidedUIVisible || (!flightWidgets.showGotoLocation && !flightWidgets.showOrbit)) {
                return
            }            
            orbitMapCircle.hide()
            gotoLocationItem.hide()
            var clickCoord = flightMap.toCoordinate(Qt.point(mouse.x, mouse.y), false /* clipToViewPort */)
            if (flightWidgets.showGotoLocation && flightWidgets.showOrbit) {
                clickMenu.coord = clickCoord
                clickMenu.popup()
            } else if (flightWidgets.showGotoLocation) {
                gotoLocationItem.show(clickCoord)
                flightWidgets.confirmAction(flightWidgets.actionGoto, clickCoord)
            } else if (guidedActionsController.showOrbit) {
                orbitMapCircle.show(clickCoord)
                flightWidgets.confirmAction(flightWidgets.actionOrbit, clickCoord)
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
