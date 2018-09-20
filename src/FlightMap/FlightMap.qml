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

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.Controls              1.0
import QGroundControl.FlightMap             1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Vehicle               1.0
import QGroundControl.QGCPositionManager    1.0

Map {
    id: _map

    zoomLevel:                  QGroundControl.flightMapZoom
    center:                     QGroundControl.flightMapPosition
    //-- Qt 5.9 has rotation gesture enabled by default. Here we limit the possible gestures.
    gesture.acceptedGestures:   MapGestureArea.PinchGesture | MapGestureArea.PanGesture | MapGestureArea.FlickGesture
    gesture.flickDeceleration:  3000
    plugin:                     Plugin { name: "GroundStation" }

    property string mapName:                        'defaultMap'
    property bool   isSatelliteMap:                 activeMapType.name.indexOf("Satellite") > -1 || activeMapType.name.indexOf("Hybrid") > -1
    property var    gcsPosition:                    QtPositioning.coordinate()
    property bool   userPanned:                     false   ///< true: the user has manually panned the map
    property bool   allowGCSLocationCenter:         false   ///< true: map will center/zoom to gcs location one time
    property bool   allowVehicleLocationCenter:     false   ///< true: map will center/zoom to vehicle location one time
    property bool   firstGCSPositionReceived:       false   ///< true: first gcs position update was responded to
    property bool   firstVehiclePositionReceived:   false   ///< true: first vehicle position update was responded to
    property bool   planView:                       false   ///< true: map being using for Plan view, items should be draggable
    property var    qgcView

    readonly property real  maxZoomLevel: 20

    property var    _activeVehicle:                 QGroundControl.multiVehicleManager.activeVehicle
    property var    activeVehicleCoordinate:        _activeVehicle ? _activeVehicle.coordinate : QtPositioning.coordinate()
    property string polygonstr:         ""
    function setVisibleRegion(region) {
        // This works around a bug on Qt where if you set a visibleRegion and then the user moves or zooms the map
        // and then you set the same visibleRegion the map will not move/scale appropriately since it thinks there
        // is nothing to do.
        _map.visibleRegion = QtPositioning.rectangle(QtPositioning.coordinate(0, 0), QtPositioning.coordinate(0, 0))
        _map.visibleRegion = region
    }

    function _possiblyCenterToVehiclePosition() {
        if (!firstVehiclePositionReceived && allowVehicleLocationCenter && activeVehicleCoordinate.isValid) {
            firstVehiclePositionReceived = true
            center = activeVehicleCoordinate
            zoomLevel = QGroundControl.flightMapInitialZoom
        }
    }

    function centerToSpecifiedLocation() {
        qgcView.showDialog(specifyMapPositionDialog, qsTr("Specify Position"), qgcView.showDialogDefaultWidth, StandardButton.Close)

    }

    Component {
        id: specifyMapPositionDialog

        EditPositionDialog {
            coordinate:             center
            onCoordinateChanged:    center = coordinate
        }
    }

    ExclusiveGroup { id: mapTypeGroup }

    // Update ground station position
    Connections {
        target: QGroundControl.qgcPositionManger

        onLastPositionUpdated: {
            if (valid && lastPosition.latitude && Math.abs(lastPosition.latitude)  > 0.001 && lastPosition.longitude && Math.abs(lastPosition.longitude)  > 0.001) {
                gcsPosition = QtPositioning.coordinate(lastPosition.latitude,lastPosition.longitude)
                if (!firstGCSPositionReceived && !firstVehiclePositionReceived && allowGCSLocationCenter) {
                    firstGCSPositionReceived = true
                    center = gcsPosition
                    zoomLevel = QGroundControl.flightMapInitialZoom
                }
            }
        }
    }

    // We track whether the user has panned or not to correctly handle automatic map positioning
    Connections {
        target: gesture

        onPanFinished:      userPanned = true
        onFlickFinished:    userPanned = true
    }

    function updateActiveMapType() {
        var settings =  QGroundControl.settingsManager.flightMapSettings
        var fullMapName = settings.mapProvider.enumStringValue + " " + settings.mapType.enumStringValue
        for (var i = 0; i < _map.supportedMapTypes.length; i++) {
            if (fullMapName === _map.supportedMapTypes[i].name) {
                _map.activeMapType = _map.supportedMapTypes[i]
                return
            }
        }
    }

    onActiveVehicleCoordinateChanged: _possiblyCenterToVehiclePosition()

    Component.onCompleted: {
        updateActiveMapType()
        _possiblyCenterToVehiclePosition()
    }

    Connections {
        target:             QGroundControl.settingsManager.flightMapSettings.mapType
        onRawValueChanged:  updateActiveMapType()
    }

    Connections {
        target:             QGroundControl.settingsManager.flightMapSettings.mapProvider
        onRawValueChanged:  updateActiveMapType()
    }

    /// Ground Station location
    MapQuickItem {
        anchorPoint.x:  sourceItem.width / 2
        anchorPoint.y:  sourceItem.height / 2
        visible:        gcsPosition.isValid
        coordinate:     gcsPosition
/*	
        sourceItem: Image {
            source:         "/res/QGCLogoFull"
            mipmap:         true
            antialiasing:   true
            fillMode:       Image.PreserveAspectFit
            height:         ScreenTools.defaultFontPixelHeight * 1.75
            sourceSize.height: height
        }*/
        sourceItem:     MissionItemIndexLabel {
        label:          QGroundControl.appName.charAt(0)
        simpleindex:    2
        }
    }
    //---- Polygon drawing code

    property var    callbackObject ///< Callback item

    // These properties can be queried by the consumer
    property bool   drawingPolygon:     false
    property bool   adjustingPolygon:   false
    property bool   polygonReady:       _currentPolygon ? _currentPolygon.path.length > 2 : false   ///< true: enough points have been captured to create a closed polygon

    property var    _helpLabel                                  ///< Dynamically added help label component
    property var    _newPolygon                                 ///< Dynamically added polygon which represents all polygon points including the one currently being drawn
    property var    _currentPolygon                             ///< Dynamically added polygon which represents the currently completed polygon
    property var    _nextPointLine                              ///< Dynamically added line which goes from last polygon point to the new one being drawn
    property var    _mobileSegment                              ///< Dynamically added line between first and second polygon point for mobile
    property var    _mobilePoint                                ///< Dynamically added point showing first polygon point on mobile
    property var    _mouseArea                                  ///< Dynamically added MouseArea which handles all clicking and mouse movement
    property var    _vertexDragList:    [ ]                     ///< Dynamically added vertex drag points
    property bool   _mobile:            ScreenTools.isMobile

        /// Begin capturing a new polygon
    ///     polygonCaptureStarted will be signalled through callbackObject
    function startCapturePolygon(callback) {
        _map.callbackObject = callback
        _helpLabel =        helpLabelComponent.createObject     (_map)
        _newPolygon =       newPolygonComponent.createObject    (_map)
        _currentPolygon =   currentPolygonComponent.createObject(_map)
        _nextPointLine =    nextPointComponent.createObject     (_map)
        _mobileSegment =    mobileSegmentComponent.createObject (_map)
        _mobilePoint =      mobilePointComponent.createObject   (_map)
        _mouseArea =        mouseAreaComponent.createObject     (_map)

        _map.addMapItem(_newPolygon)
        _map.addMapItem(_currentPolygon)
        _map.addMapItem(_nextPointLine)
        _map.addMapItem(_mobileSegment)
        _map.addMapItem(_mobilePoint)

        drawingPolygon = true
        callbackObject.polygonCaptureStarted()
    }

    /// Finish capturing the polygon
    ///     polygonCaptureFinished will be signalled through callbackObject
    /// @return true: polygon completed, false: not enough points to complete polygon
    function finishCapturePolygon() {
        if (!polygonReady) {
            return false
        }
        var polygonPath = _currentPolygon.path
        _cancelCapturePolygon()
        callbackObject.polygonCaptureFinished(polygonPath)
        return true
    }
    /// Cancels an in progress draw or adjust
    function cancelPolygonEdit() {
        _cancelCapturePolygon()
    }

    function _cancelCapturePolygon() {
        _helpLabel.destroy()
        _newPolygon.destroy()
        _currentPolygon.destroy()
        _nextPointLine.destroy()
        _mouseArea.destroy()
        drawingPolygon = false
    }

    Component {
        id: helpLabelComponent

        QGCMapLabel {
            id:                     polygonHelp
            anchors.topMargin:      parent.height - ScreenTools.availableHeight
            anchors.top:            parent.top
            anchors.left:           parent.left
            anchors.right:          parent.right
            horizontalAlignment:    Text.AlignHCenter
            map:                    _map
            text:                   qsTr("Click to add point %1").arg(ScreenTools.isMobile || !polygonReady ? "" : qsTr("- Right Click to end polygon"))

            Connections {
                target: _map

                onDrawingPolygonChanged: {
                    if (drawingPolygon) {
                        polygonHelp.text = qsTr("Click to add point")
                    }
                    polygonHelp.visible = drawingPolygon
                }

                onPolygonReadyChanged: {
                    if (polygonReady && !ScreenTools.isMobile) {
                        polygonHelp.text = qsTr("Click to add point - Right Click to end polygon")
                    }
                }

                onAdjustingPolygonChanged: {
                    if (adjustingPolygon) {
                        polygonHelp.text = qsTr("Adjust polygon by dragging corners")
                    }
                    polygonHelp.visible = adjustingPolygon
                }
            }
        }
    }

    Component {
        id: mouseAreaComponent

        MouseArea {
            anchors.fill:       _map
            acceptedButtons:    Qt.LeftButton | Qt.RightButton
            hoverEnabled:       true
            z:                  QGroundControl.zOrderMapItems + 1

            property bool   justClicked: false

            onClicked: {
                if (mouse.button == Qt.LeftButton) {
                    justClicked = true
                    if (_newPolygon.path.length > 2) {
                        // Make sure the new line doesn't intersect the existing polygon
                        var lastSegment = _newPolygon.path.length - 2
                        var newLineA = _map.fromCoordinate(_newPolygon.path[lastSegment], false /* clipToViewPort */)
                        var newLineB = _map.fromCoordinate(_newPolygon.path[lastSegment+1], false /* clipToViewPort */)
                        for (var i=0; i<lastSegment; i++) {
                            var oldLineA = _map.fromCoordinate(_newPolygon.path[i], false /* clipToViewPort */)
                            var oldLineB = _map.fromCoordinate(_newPolygon.path[i+1], false /* clipToViewPort */)
                            if (QGroundControl.linesIntersect(newLineA, newLineB, oldLineA, oldLineB)) {
                                return;
                            }
                        }
                    }

                    var clickCoordinate = _map.toCoordinate(Qt.point(mouse.x, mouse.y), false /* clipToViewPort */)
                    var polygonPath = _newPolygon.path
                    if (polygonPath.length == 0) {
                        // Add first coordinate
                        polygonPath.push(clickCoordinate)
                    } else {
                        // Add subsequent coordinate
                        if (ScreenTools.isMobile) {
                            // Since mobile has no mouse, the onPositionChangedHandler will not fire. We have to add the coordinate
                            // here instead.
                            justClicked = false
                            polygonPath.push(clickCoordinate)
                        } else {
                            // The onPositionChanged handler for mouse movement will have already added the coordinate to the array.
                            // Just update it to the final position
                            polygonPath[_newPolygon.path.length - 1] = clickCoordinate
                        }
                    }
                    _currentPolygon.path = polygonPath
                    _newPolygon.path = polygonPath

                    if (_mobile && _currentPolygon.path.length == 1) {
                        _mobilePoint.coordinate = _currentPolygon.path[0]
                        _mobilePoint.visible = true
                    } else if (_mobile && _currentPolygon.path.length == 2) {
                        // Show initial line segment on mobile
                        _mobileSegment.path = [ _currentPolygon.path[0], _currentPolygon.path[1] ]
                        _mobileSegment.visible = true
                        _mobilePoint.visible = false
                    } else {
                        _mobileSegment.visible = false
                        _mobilePoint.visible = false
                    }
                } else if (polygonReady) {
                    finishCapturePolygon()
                }
            }

            onPositionChanged: {
                if (ScreenTools.isMobile) {
                    // We don't track mouse drag on mobile
                    return
                }
                if (_newPolygon.path.length) {
                    var dragCoordinate = _map.toCoordinate(Qt.point(mouse.x, mouse.y), false /* clipToViewPort */)
                    var polygonPath = _newPolygon.path
                    if (justClicked){
                        // Add new drag coordinate
                        polygonPath.push(dragCoordinate)
                        justClicked = false
                    }

                    // Update drag line
                    //polygonstr= "距离:"+QGroundControl.metersToAppSettingsDistanceUnits(dragCoordinate.distanceTo(polygonPath[polygonDrawerPolygon.path.length - 2])).toFixed(2)+"角度:"+((dragCoordinate.azimuthTo(polygonPath[polygonDrawerPolygon.path.length - 2])+180)%360).toFixed(1)
                    _nextPointLine.path = [ _newPolygon.path[_newPolygon.path.length - 2], dragCoordinate ]

                    polygonPath[_newPolygon.path.length - 1] = dragCoordinate
                    _newPolygon.path = polygonPath
                }
            }
        }
    }

    /// Polygon being drawn, including new point
    Component {
        id: newPolygonComponent

        MapPolygon {
            color:      "blue"
            opacity:    0.5
            visible:    path.length > 2
        }
    }

    /// Current complete polygon
    Component {
        id: currentPolygonComponent

        MapPolygon {
            color:      'green'
            opacity:    0.5
            visible:    polygonReady
        }
    }

    /// First line segment to show on mobile
    Component {
        id: mobileSegmentComponent

        MapPolyline {
            line.color: "green"
            line.width: 3
            visible:    false
        }
    }

    /// First line segment to show on mobile
    Component {
        id: mobilePointComponent

        MapQuickItem {
            anchorPoint.x:  rect.width / 2
            anchorPoint.y:  rect.height / 2
            visible:        false

            sourceItem: Rectangle {
                id:     rect
                width:  ScreenTools.defaultFontPixelHeight
                height: width
                color:  "green"
            }
        }
    }

    /// Next line for polygon
    Component {
        id: nextPointComponent

        MapPolyline {
            line.color: "green"
            line.width: 3
        }
    }
} // Map
