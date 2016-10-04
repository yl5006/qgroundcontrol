/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.4
import QtQuick.Controls 1.3
import QtQuick.Dialogs  1.2
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Mavlink       1.0
import QGroundControl.Controllers   1.0

/// Mission Editor

QGCView {
    id:         qgcView
    viewPanel:  panel

    // zOrder comes from the Loader in MainWindow.qml
    z: QGroundControl.zOrderTopMost

    readonly property int       _decimalPlaces:         8
    readonly property real      _horizontalMargin:      ScreenTools.defaultFontPixelWidth  / 2
    readonly property real      _margin:                ScreenTools.defaultFontPixelHeight * 0.5
    readonly property var       _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    readonly property real      _PointFieldWidth:       ScreenTools.defaultFontPixelWidth * 11
    readonly property real      _rightPanelWidth:       Math.min(parent.width / 3, ScreenTools.defaultFontPixelWidth * 35)
    readonly property real      _rightPanelOpacity:     0.8
    readonly property int       _toolButtonCount:       6
    readonly property real      _toolButtonTopMargin:   parent.height - ScreenTools.availableHeight + (ScreenTools.defaultFontPixelHeight / 2)
    readonly property var       _defaultVehicleCoordinate:   QtPositioning.coordinate(37.803784, -122.462276)


    property var    _visualItems:           missionController.visualItems
    property var    _currentMissionItem
    property int    _currentMissionIndex:   0
    property bool   _firstVehiclePosition:  true
    property var    activeVehiclePosition:  _activeVehicle ? _activeVehicle.coordinate : QtPositioning.coordinate()
    property bool   _lightWidgetBorders:    editorMap.isSatelliteMap
    /// The controller which should be called for load/save, send to/from vehicle calls
    property var _syncDropDownController: missionController
    readonly property int _layerMission:        1
    readonly property int _layerGeoFence:       2
    property int _editingLayer: _layerMission

    onActiveVehiclePositionChanged: updateMapToVehiclePosition()

    Connections {
        target: QGroundControl.multiVehicleManager

        onActiveVehicleChanged: {
            // When the active vehicle changes we need to allow the first vehicle position to move the map again
            _firstVehiclePosition = true
            updateMapToVehiclePosition()
        }
    }

    function updateMapToVehiclePosition() {
        if (_activeVehicle && _activeVehicle.coordinateValid && _activeVehicle.coordinate.isValid && _firstVehiclePosition) {
            _firstVehiclePosition = false
            editorMap.center = _activeVehicle.coordinate
        }
    }

    function normalizeLat(lat) {
        // Normalize latitude to range: 0 to 180, S to N
        return lat + 90.0
    }

    function normalizeLon(lon) {
        // Normalize longitude to range: 0 to 360, W to E
        return lon  + 180.0
    }

    /// Fix the map viewport to the current mission items.
    function fitViewportToMissionItems() {
        if (_visualItems.count == 1) {
            editorMap.center = _visualItems.get(0).coordinate
        } else {
            var missionItem = _visualItems.get(0)
            var north = normalizeLat(missionItem.coordinate.latitude)
            var south = north
            var east = normalizeLon(missionItem.coordinate.longitude)
            var west = east

            for (var i=1; i<_visualItems.count; i++) {
                missionItem = _visualItems.get(i)

                if (missionItem.specifiesCoordinate && !missionItem.isStandaloneCoordinate) {
                    var lat = normalizeLat(missionItem.coordinate.latitude)
                    var lon = normalizeLon(missionItem.coordinate.longitude)

                    north = Math.max(north, lat)
                    south = Math.min(south, lat)
                    east = Math.max(east, lon)
                    west = Math.min(west, lon)
                }
            }
            editorMap.visibleRegion = QtPositioning.rectangle(QtPositioning.coordinate(north - 90.0, west - 180.0), QtPositioning.coordinate(south - 90.0, east - 180.0))
        }
    }

    MissionController {
        id: missionController

        Component.onCompleted: {
            start(true /* editMode */)
            setCurrentItem(0)
        }

        function loadFromSelectedFile() {
            if (ScreenTools.isMobile) {
                qgcView.showDialog(mobileFilePicker, qsTr("Select Mission File"), qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
            } else {
                missionController.loadFromFilePicker()
                fitViewportToMissionItems()
                _currentMissionItem = _visualItems.get(0)
            }
        }

        function saveToSelectedFile() {
            if (ScreenTools.isMobile) {
                qgcView.showDialog(mobileFileSaver, qsTr("Save Mission File"), qgcView.showDialogDefaultWidth, StandardButton.Save | StandardButton.Cancel)
            } else {
                missionController.saveToFilePicker()
            }
        }

        onVisualItemsChanged: {
            itemDragger.clearItem()
        }

        onNewItemsFromVehicle: {
            fitViewportToMissionItems()
            setCurrentItem(0)
        }
    }

    GeoFenceController {
        id: geoFenceController

        Component.onCompleted: start(true /* editMode */)

        onFenceSupportedChanged: {
            if (!fenceSupported && _editingLayer == _layerGeoFence) {
                _editingLayer = _layerMission
            }
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    ExclusiveGroup {
        id: _mapTypeButtonsExclusiveGroup
    }

    ExclusiveGroup {
        id: _dropButtonsExclusiveGroup
    }

    function setCurrentItem(sequenceNumber) {
        editorMap.polygonDraw.cancelPolygonEdit()
        _currentMissionItem = undefined
        for (var i=0; i<_visualItems.count; i++) {
            var visualItem = _visualItems.get(i)
            if (visualItem.sequenceNumber == sequenceNumber) {
                _currentMissionItem = visualItem
                _currentMissionItem.isCurrentItem = true
                _currentMissionIndex = i
            } else {
                visualItem.isCurrentItem = false
            }
        }
    }

    property int _moveDialogMissionItemIndex

    Component {
        id: mobileFilePicker

        QGCMobileFileDialog {
            openDialog:     true
            fileExtension:  QGroundControl.missionFileExtension

            onFilenameReturned: _syncDropDownController.loadFromfile(filename)
        }
    }

    Component {
        id: mobileFileSaver

        QGCMobileFileDialog {
            openDialog:     false
            fileExtension:  QGroundControl.missionFileExtension
            onFilenameReturned: _syncDropDownController.saveToFile()
        }
    }

    Component {
        id: moveDialog

        QGCViewDialog {
            function accept() {
                var toIndex = toCombo.currentIndex

                if (toIndex == 0) {
                    toIndex = 1
                }
                missionController.moveMissionItem(_moveDialogMissionItemIndex, toIndex)
                hideDialog()
            }

            Column {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    wrapMode:       Text.WordWrap
                    text:           qsTr("Move the selected mission item to the be after following mission item:")
                }

                QGCComboBox {
                    id:             toCombo
                    model:          _visualItems.count
                    currentIndex:   _moveDialogMissionItemIndex
                }
            }
        }
    }

    QGCViewPanel {
        id:             panel
        height:         ScreenTools.availableHeight
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right

        Item {
            anchors.fill: parent

            FlightMap {
                id:             editorMap
                height:         qgcView.height
                anchors.bottom: parent.bottom
                anchors.left:   parent.left
                anchors.right:  parent.right
                mapName:        "MissionEditor"


                readonly property real animationDuration: 500

                // Initial map position duplicates Fly view position
                Component.onCompleted: editorMap.center = QGroundControl.flightMapPosition

                Behavior on zoomLevel {
                    NumberAnimation {
                        duration:       editorMap.animationDuration
                        easing.type:    Easing.InOutQuad
                    }
                }

                QGCMapPalette { id: mapPal; lightColors: editorMap.isSatelliteMap }

                MouseArea {
                    //-- It's a whole lot faster to just fill parent and deal with top offset below
                    //   than computing the coordinate offset.
                    anchors.fill: parent
                    onClicked: {
                        //-- Don't pay attention to items beneath the toolbar.
                        var topLimit = parent.height - ScreenTools.availableHeight
                        if(mouse.y < topLimit) {
                            return
                        }

                        var coordinate = editorMap.toCoordinate(Qt.point(mouse.x, mouse.y))
                        coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
                        coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
                        coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)

                        switch (_editingLayer) {
                        case _layerMission:
                            if (addMissionItemsButton.checked) {
                                var sequenceNumber = missionController.insertSimpleMissionItem(coordinate, missionController.visualItems.count)
                                setCurrentItem(sequenceNumber)
                            }
                            break
                        case _layerGeoFence:
                            geoFenceController.breachReturnPoint = coordinate
                            break
                        }
                    }
                }

                // We use this item to support dragging since dragging a MapQuickItem just doesn't seem to work
                Rectangle {
                    id:             itemDragger
                    x:              missionItemIndicator ? (missionItemIndicator.x + missionItemIndicator.anchorPoint.x - (itemDragger.width / 2)) : 100
                    y:              missionItemIndicator ? (missionItemIndicator.y + missionItemIndicator.anchorPoint.y/2 - (itemDragger.height / 2)) : 100
                    width:          ScreenTools.defaultFontPixelHeight * 3
                    height:         ScreenTools.defaultFontPixelHeight * 3
                    color:          "transparent"
                    visible:        false
                    z:              QGroundControl.zOrderMapItems + 1    // Above item icons

                    property var    missionItem
                    property var    missionItemIndicator
                    property bool   preventCoordinateBindingLoop: false

                    onXChanged: liveDrag()
                    onYChanged: liveDrag()

                    function liveDrag() {
                        if (!itemDragger.preventCoordinateBindingLoop && Drag.active) {
                            //                          var point = Qt.point(itemDragger.x + (itemDragger.width  / 2), itemDragger.y + (itemDragger.height/2))
                            var point = Qt.point(itemDragger.x + (itemDragger.width  / 2), itemDragger.y + (itemDragger.height))
                            var coordinate = editorMap.toCoordinate(point)
                            coordinate.altitude = itemDragger.missionItem.coordinate.altitude
                            itemDragger.preventCoordinateBindingLoop = true
                            itemDragger.missionItem.coordinate = coordinate
                            itemDragger.preventCoordinateBindingLoop = false
                        }
                    }

                    function clearItem() {
                        itemDragger.visible = false
                        itemDragger.missionItem = undefined
                        itemDragger.missionItemIndicator = undefined
                    }

                    Drag.active:    itemDrag.drag.active
                    Drag.hotSpot.x: width  / 2
                    Drag.hotSpot.y: height / 2

                    MouseArea {
                        id:             itemDrag
                        anchors.fill:   parent
                        drag.target:    parent
                        drag.minimumX:  0
                        drag.minimumY:  0
                        drag.maximumX:  itemDragger.parent.width - parent.width
                        drag.maximumY:  itemDragger.parent.height - parent.height
                    }
                }

                // Add the complex mission item polygon to the map
                MapItemView {
                    model: _editingLayer == _layerMission ? missionController.complexVisualItems : undefined

                    delegate: MapPolygon {
                        color:      'green'
                        path:       object.polygonPath
                        opacity:    0.5
                    }
                }

                // Add the complex mission item grid to the map
                MapItemView {
                    model: _editingLayer == _layerMission ? missionController.complexVisualItems : undefined

                    delegate: MapPolyline {
                        line.color: "white"
                        line.width: 2
                        path:       object.gridPoints
                    }
                }

                // Add the complex mission item exit coordinates
                MapItemView {
                    model: _editingLayer == _layerMission ? missionController.complexVisualItems : undefined
                    delegate:   exitCoordinateComponent
                }

                Component {
                    id: exitCoordinateComponent

                    MissionItemIndicator {
                        coordinate:     object.exitCoordinate
                        z:              QGroundControl.zOrderMapItems
                        missionItem:    object
                        sequenceNumber: object.lastSequenceNumber
                        visible:        object.specifiesCoordinate
                    }
                }

                // Add the simple mission items to the map
                MapItemView {
                    model:      _editingLayer == _layerMission ? missionController.visualItems : undefined
                    delegate:   missionItemComponent
                }

                Component {
                    id: missionItemComponent

                    MissionItemIndicator {
                        id:             itemIndicator
                        coordinate:     object.coordinate
                        visible:        object.specifiesCoordinate
                        z:              QGroundControl.zOrderMapItems
                        missionItem:    object
                        sequenceNumber: object.sequenceNumber

                        //-- If you don't want to allow selecting items beneath the
                        //   toolbar, the code below has to check and see if mouse.y
                        //   is greater than (map.height - ScreenTools.availableHeight)
                        onClicked: setCurrentItem(object.sequenceNumber)

                        function updateItemIndicator() {
                            if (object.isCurrentItem && itemIndicator.visible && object.specifiesCoordinate && object.isSimpleItem) {
                                // Setup our drag item
                                itemDragger.visible = true
                                itemDragger.missionItem = Qt.binding(function() { return object })
                                itemDragger.missionItemIndicator = Qt.binding(function() { return itemIndicator })
                            }
                        }

                        Connections {
                            target: object

                            onIsCurrentItemChanged:         updateItemIndicator()
                            onSpecifiesCoordinateChanged:   updateItemIndicator()
                        }

                        // These are the non-coordinate child mission items attached to this item
                        Row {
                            anchors.top:    parent.top
                            anchors.left:   parent.right

                            Repeater {
                                model: object.childItems

                                delegate:   MissionItemIndexLabel{
                                    label:          object.abbreviation
                                    isCurrentItem:  object.isCurrentItem
                                    z:              2

                                    onClicked: setCurrentItem(object.sequenceNumber)
                                }
                            }
                        }
                    }
                }

                // Add lines between waypoints
                MissionLineView {
                    model:      _editingLayer == _layerMission ? missionController.waypointLines : undefined
                }


                // Add the vehicles to the map
                MapItemView {
                    model: QGroundControl.multiVehicleManager.vehicles
                    delegate:
                        VehicleMapItem {
                        vehicle:        object
                        coordinate:     object.coordinate
                        isSatellite:    editorMap.isSatelliteMap
                        size:           ScreenTools.defaultFontPixelHeight * 5
                        z:              QGroundControl.zOrderMapItems - 1
                    }
                }

                // Mission/GeoFence selector
                Item {
                    id:                 planElementSelector
                    anchors.topMargin:  parent.height - ScreenTools.availableHeight + _margin
                    anchors.top:        parent.top
                    anchors.leftMargin: parent.width - _rightPanelWidth
                    anchors.left:       parent.left
                    width:              planElementSelectorRow.width
                    height:             geoFenceController.fenceSupported ? planElementSelectorRow.height : 0
                    visible:            false//geoFenceController.fenceSupported

                    ExclusiveGroup {
                        id: planElementSelectorGroup
                        onCurrentChanged: {
                            var layerIsMission = current == planElementMission
                            _editingLayer = layerIsMission ? _layerMission : _layerGeoFence
                            _syncDropDownController = layerIsMission ? missionController : geoFenceController
                        }
                    }

                    Row {
                        id:     planElementSelectorRow
                        spacing: _horizontalMargin

                        QGCRadioButton {
                            id:             planElementMission
                            text:           qsTr("Mission")
                            checked:        true
                            exclusiveGroup: planElementSelectorGroup
                            color:          mapPal.text
                        }

                        QGCRadioButton {
                            id:             planElementGeoFence
                            text:           qsTr("GeoFence")
                            exclusiveGroup: planElementSelectorGroup
                            color:          mapPal.text
                        }
                    }
                }

                // Mission Item Editor
                Item {
                    id:             missionItemIndex//missionItemEditor
                    height:         _PointFieldWidth+ScreenTools.defaultFontPixelWidth//mainWindow.availableHeight/5  //change by yaoling
                    anchors.bottom:  parent.bottom
                    anchors.horizontalCenter:           parent.horizontalCenter
                    //                  width:          _rightPanelWidth
                    width:          mainWindow.availableWidth*0.9   //change by yaoling
                    opacity:        _rightPanelOpacity
                    z:              QGroundControl.zOrderTopMost
                    visible:        _editingLayer == _layerMission

                    MouseArea {
                        // This MouseArea prevents the Map below it from getting Mouse events. Without this
                        // things like mousewheel will scroll the Flickable and then scroll the map as well.
                        anchors.fill:       editorListView
                        onWheel:            wheel.accepted = true
                    }

                    ListView {
                        id:             editorListView
                        anchors.left:   parent.left
                        anchors.top:    parent.top
                        height:         parent.height
                        width:          parent.width   //add yaoling
                        spacing:        _margin / 2
                        //                      orientation:    ListView.Vertical   //change by yaoling
                        orientation:    ListView.Horizontal
                        model:          missionController.visualItems
                        cacheBuffer:    width*2//height * 2
                        clip:           true
                        currentIndex:   _currentMissionIndex
                        highlightMoveDuration: 250
                        delegate:       MissionItemIndex{//MissionItemIndex {//MissionItemEditor {
                            missionItem:    object
                            width:          _PointFieldWidth//_PointFieldWidth//_rightPanelWidth//parent.width
                            readOnly:       false

                            onClicked:  setCurrentItem(object.sequenceNumber)

                            //                            onRemove: {
                            //                               itemDragger.clearItem()
                            //                                missionController.removeMissionItem(index)
                            //                                editorMap.polygonDraw.cancelPolygonEdit()
                            //                            }

                            //                            onInsert: {
                            //                                var sequenceNumber = missionController.insertSimpleMissionItem(editorMap.center, insertAfterIndex)
                            //                                setCurrentItem(sequenceNumber)
                            //                           }

                            //                            onMoveHomeToMapCenter: _visualItems.get(0).coordinate = editorMap.center
                        }
                    } // ListView
                } // Item - Mission Item editor

                // GeoFence Editor
                Loader {
                    anchors.topMargin:  _margin
                    anchors.top:        planElementSelector.bottom
                    anchors.right:      parent.right
                    opacity:            _rightPanelOpacity
                    z:                  QGroundControl.zOrderTopMost
                    source:             _editingLayer == _layerGeoFence ? "qrc:/qml/GeoFenceEditor.qml" : ""

                    property real availableWidth:   _rightPanelWidth
                    property real availableHeight:  ScreenTools.availableHeight
                }

                // GeoFence polygon
                MapPolygon {
                    border.color:   "#80FF0000"
                    border.width:   3
                    path:           geoFenceController.polygonSupported ? geoFenceController.polygon.path : undefined
                }

                // GeoFence circle
                MapCircle {
                    border.color:   "#80FF0000"
                    border.width:   3
                    center:         missionController.plannedHomePosition
                    radius:         geoFenceController.circleSupported ? geoFenceController.circleRadius : 0
                }

                // GeoFence circle
                MapCircle {
                    border.color:   "#80FF0000"
                    border.width:   3
                    center:         missionController.plannedHomePosition
                    radius:         geoFenceController.circleSupported ? geoFenceController.circleRadius : 0
                }

                // GeoFence breach return point
                MapQuickItem {
                    anchorPoint:    Qt.point(sourceItem.width / 2, sourceItem.height / 2)
                    coordinate:     geoFenceController.breachReturnPoint
                    visible:        geoFenceController.breachReturnSupported
                    sourceItem:     MissionItemIndexLabel { label: "F" }
                }

                //-- Dismiss Drop Down (if any)
                MouseArea {
                    anchors.fill:   parent
                    enabled:        _dropButtonsExclusiveGroup.current != null
                    onClicked: {
                        if(_dropButtonsExclusiveGroup.current)
                            _dropButtonsExclusiveGroup.current.checked = false
                        _dropButtonsExclusiveGroup.current = null
                    }
                }
                //-- horizontal Tool Buttons
                Row {
                    id:                 toolColumn
                    anchors.topMargin:  ScreenTools.isShortScreen ? _toolButtonTopMargin+_toolButtonTopMargin : ScreenTools.defaultFontPixelHeight / 2+_toolButtonTopMargin
                    anchors.top:        parent.top//ScreenTools.isShortScreen ? parent.top : planLabel.bottom
                    anchors.horizontalCenter:   parent.horizontalCenter
                    z:                  QGroundControl.zOrderWidgets
                    RoundButton {
                        id:             addMissionItemsButton
                        buttonImage:    "/qmlimages/MapAddMission.svg"
                        lightBorders:   _lightWidgetBorders
                        visible:        _editingLayer == _layerMission
                    }
                    Rectangle {
                        height:     parent.height*0.8
                        width:      1
                        color:      "grey"
                    }
                    RoundButton {
                        id:             addShapeButton
                        buttonImage:    "/qmlimages/MapDrawShape.svg"
                        lightBorders:   _lightWidgetBorders
                        visible:        _editingLayer == _layerMission

                        onClicked: {
                            var coordinate = editorMap.center
                            coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
                            coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
                            coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)
                            var sequenceNumber = missionController.insertComplexMissionItem(coordinate, missionController.visualItems.count)
                            setCurrentItem(sequenceNumber)
                            checked = false
                            addMissionItemsButton.checked = false
                        }
                    }
                    Rectangle {
                        height:     parent.height*0.8
                        width:      1
                        color:      "grey"
                    }
                    DropButton {
                        id:                 syncButton
                        dropDirection:      dropDown
                        buttonImage:      "/qmlimages/MapSync.svg"//_syncDropDownController.dirty ? "/qmlimages/MapSyncChanged.svg" : "/qmlimages/MapSync.svg"
                        imgcolor:           _syncDropDownController.dirty ? "red":"White"
                        viewportMargins:    ScreenTools.defaultFontPixelWidth / 2
                        exclusiveGroup:     _dropButtonsExclusiveGroup
                        dropDownComponent:  syncDropDownComponent
                        enabled:            !_syncDropDownController.syncInProgress
                        rotateImage:        _syncDropDownController.syncInProgress
                        lightBorders:       _lightWidgetBorders
                    }
                    Rectangle {
                        height:     parent.height*0.8
                        width:      1
                        color:      "grey"
                    }
                    DropButton {
                        id:                 centerMapButton
                        dropDirection:      dropDown
                        buttonImage:        "/qmlimages/MapCenter.svg"
                        viewportMargins:    ScreenTools.defaultFontPixelWidth / 2
                        exclusiveGroup:     _dropButtonsExclusiveGroup
                        lightBorders:       _lightWidgetBorders

                        dropDownComponent: Component {
                            //                            Column {
                            //                                spacing: ScreenTools.defaultFontPixelWidth * 0.5
                            //                                QGCLabel { text: qsTr("中心位置") }// "Center map:" }
                            Row {
                                spacing: ScreenTools.defaultFontPixelWidth*0.5
                                RoundImageButton {
                                    width:          ScreenTools.defaultFontPixelHeight*3
                                    height:         width
                                    exclusiveGroup: _mapTypeButtonsExclusiveGroup
                                    imageResource:  "/qmlimages/map_home.svg"
                                    // showborder:     true
                                    bordercolor:    qgcPal.text
                                    onClicked: {
                                        centerMapButton.hideDropDown()
                                        editorMap.center = controller.visualItems.get(0).coordinate
                                    }
                                }
                                Rectangle {
                                    anchors.verticalCenter:         parent.verticalCenter
                                    height:     parent.height*0.8
                                    width:      1
                                    color:      "grey"
                                }
                                RoundImageButton {
                                    width:          ScreenTools.defaultFontPixelHeight*3
                                    height:         width
                                    imageResource:  "/qmlimages/map_mission.svg"
                                    //    showborder:     true
                                    bordercolor:    qgcPal.text
                                    onClicked: {
                                        centerMapButton.hideDropDown()
                                        fitViewportToMissionItems()
                                    }
                                }
                                Rectangle {
                                    anchors.verticalCenter:         parent.verticalCenter
                                    height:     parent.height*0.8
                                    width:      1
                                    color:      "grey"
                                }
                                RoundImageButton {
                                    width:          ScreenTools.defaultFontPixelHeight*3
                                    height:         width
                                    imageResource:  "/qmlimages/map_plane.svg"
                                    //    showborder:     true
                                    bordercolor:    qgcPal.text
                                    enabled:    activeVehicle && activeVehicle.latitude != 0 && activeVehicle.longitude != 0
                                    property var activeVehicle: _activeVehicle
                                    onClicked: {
                                        centerMapButton.hideDropDown()
                                        editorMap.center = activeVehicle.coordinate
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
                    DropButton {
                        id:                 mapTypeButton
                        dropDirection:      dropDown
                        buttonImage:        "/qmlimages/MapType.svg"
                        viewportMargins:    ScreenTools.defaultFontPixelWidth / 2
                        exclusiveGroup:     _dropButtonsExclusiveGroup
                        lightBorders:       _lightWidgetBorders

                        dropDownComponent: Component {
                            //                            Rectangle {
                            //                                  height:     ScreenTools.defaultFontPixelHeight*2
                            //                                  width:      parent.width*0.7
                            //                                  color:      "grey"
                            //                                  anchors.centerIn: parent
                            //                                }
                            Row {
                                spacing: ScreenTools.defaultFontPixelWidth
                                Repeater {
                                    model: QGroundControl.flightMapSettings.mapTypes
                                    RoundImageButton {
                                        width:          ScreenTools.defaultFontPixelHeight*3
                                        height:         width
                                        exclusiveGroup: _mapTypeButtonsExclusiveGroup
                                        checked:        QGroundControl.flightMapSettings.mapType === QGroundControl.flightMapSettings.mapTypes[index]
                                        imageResource:  index==0?"/qmlimages/map_street.svg":index==1?"/qmlimages/map_gps.svg" :"/qmlimages/map_terrain.svg"
                                        bordercolor:    qgcPal.buttonHighlight
                                        showcheckcolor: true
                                        onClicked: {
                                            QGroundControl.flightMapSettings.mapType = QGroundControl.flightMapSettings.mapTypes[index]
                                            checked = true
                                            mapTypeButton.hideDropDown()
                                        }
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
                        id:             mapZoomPlus
                        visible:        !ScreenTools.isTinyScreen && !ScreenTools.isShortScreen
                        buttonImage:    "/qmlimages/ZoomPlus.svg"
                        lightBorders:   _lightWidgetBorders

                        onClicked: {
                            if(editorMap)
                                editorMap.zoomLevel += 0.5
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
                        id:             mapZoomMinus
                        visible:        !ScreenTools.isTinyScreen && !ScreenTools.isShortScreen
                        buttonImage:    "/qmlimages/ZoomMinus.svg"
                        lightBorders:   _lightWidgetBorders
                        onClicked: {
                            if(editorMap)
                                editorMap.zoomLevel -= 0.5
                            checked = false
                        }
                    }
                }

                MapScale {
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    anchors.left:       toolColumn.right
                    anchors.verticalCenter:         toolColumn.verticalCenter
                    z:                  QGroundControl.zOrderWidgets
                    mapControl:         editorMap
                    visible:            !ScreenTools.isTinyScreen

                }
                MissionItemIndexIndicator {
                    id:              indexIndicator
                    anchors.right:   parent.right
                    anchors.top:     parent.top
                    anchors.topMargin:     ScreenTools.isShortScreen ? _toolButtonTopMargin+_toolButtonTopMargin : ScreenTools.defaultFontPixelHeight / 2+_toolButtonTopMargin
                    anchors.rightMargin:   _margin*2
                    width:               _rightPanelWidth
                    currentMissionItem:  _currentMissionItem
                    missionItems:        missionController.visualItems
                    missionDistance:     missionController.missionDistance
                    missionMaxTelemetry: missionController.missionMaxTelemetry
                    cruiseDistance:      missionController.cruiseDistance
                    hoverDistance:       missionController.hoverDistance
                    qgcView:        qgcView
                    readOnly:       false
                    visible:        _editingLayer == _layerMission
                    z:              QGroundControl.zOrderTopMost+100
                    onRemove: {
                        itemDragger.clearItem()
                        missionController.removeMissionItem(_currentMissionItem.sequenceNumber)
                        setCurrentItem(_currentMissionItem.sequenceNumber-1)
                        editorMap.polygonDraw.cancelPolygonEdit()
                    }

                    onInsert: {
                        var sequenceNumber = missionController.insertSimpleMissionItem(editorMap.center, _currentMissionItem.sequenceNumber)
                        setCurrentItem(sequenceNumber)
                    }
                    onMoveHomeToMapCenter: _visualItems.get(0).coordinate = editorMap.center
                }
                //change by yaoling do not use this
//                MissionItemStatus {
//                    id:                     waypointValuesDisplay
//                    anchors.margins:        ScreenTools.defaultFontPixelWidth
//                    anchors.left:           parent.left
//                    anchors.bottom:         parent.bottom
//                    z:                      QGroundControl.zOrderTopMost
//                    currentMissionItem:     _currentMissionItem
//                    missionItems:           missionController.visualItems
//                    expandedWidth:          missionItemEditor.x - (ScreenTools.defaultFontPixelWidth * 2)
//                    missionDistance:        missionController.missionDistance
//                    missionMaxTelemetry:    missionController.missionMaxTelemetry
//                    cruiseDistance:         missionController.cruiseDistance
//                    hoverDistance:          missionController.hoverDistance
//                    visible:                _editingLayer == _layerMission && !ScreenTools.isShortScreen
//                }
            } // Item - split view container
        } // QGCViewPanel

        Component {
            id: syncLoadFromVehicleOverwrite
            QGCViewMessage {
                id:         syncLoadFromVehicleCheck
                message:   qsTr("你有未保存或未发送的任务,从飞机载入任务会丢失这些修改，你确认从飞机载入飞行任务?")//"You have unsaved/unsent mission changes. Loading the mission from the Vehicle will lose these changes. Are you sure you want to load the mission from the Vehicle?"
                function accept() {
                    hideDialog()
                    _syncDropDownController.loadFromVehicle()
                }
            }
        }

        Component {
            id: syncLoadFromFileOverwrite
            QGCViewMessage {
                id:         syncLoadFromVehicleCheck
                message:   qsTr("你有未保存的飞行计划，载入任务会丢失改计划，确认从文件载入？")//qsTr("You have unsaved/unsent mission changes. Loading a mission from a file will lose these changes. Are you sure you want to load a mission from a file?")
                function accept() {
                    hideDialog()
                    _syncDropDownController.loadFromSelectedFile()
                }
            }
        }

        Component {
            id: removeAllPromptDialog
            QGCViewMessage {
                message: qsTr("确认删除所有任务点?")//"Are you sure you want to delete all mission items?"
                function accept() {
                    itemDragger.clearItem()
                    _syncDropDownController.removeAll()
                    hideDialog()
                }
            }
        }

        Component {
            id: syncDropDownComponent
            Column {
                property string _overwriteText: (_editingLayer == _layerMission) ? qsTr("覆盖任务")/*qsTr("Mission overwrite")*/ : qsTr("GeoFence overwrite")
                id:                 sendSaveGrid
                anchors.margins:    _margin

                SubMenuButton {
                    imageResource:      "/qmlimages/sendvehicle.svg"
                    enabled:             _activeVehicle && !_syncDropDownController.syncInProgress
                    Layout.fillWidth:   true
                    text:               qsTr("发送任务..")//"Send to vehicle"
                    onClicked:  {
                        syncButton.hideDropDown()
                        _syncDropDownController.sendToVehicle()
                    }
                }
                Rectangle {
                    height:     1
                    width:      parent.width
                    color:      "grey"
                }

                SubMenuButton {
                    imageResource:      "/qmlimages/loadvehicle.svg"
                    enabled:           _activeVehicle && !_syncDropDownController.syncInProgress
                    Layout.fillWidth:   true
                    text:                qsTr("载入任务..")//"Load from vehicle"
                    onClicked:  {
                        syncButton.hideDropDown()
                        if (_syncDropDownController.dirty) {
                            qgcView.showDialog(syncLoadFromVehicleOverwrite, sendSaveGrid._overwriteText, qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                        } else {
                            _syncDropDownController.loadFromVehicle()
                        }
                    }
                }
                Rectangle {
                    height:     1
                    width:      parent.width
                    color:      "grey"
                }
                SubMenuButton {
                    imageResource:      "/qmlimages/savetofile.svg"
                    enabled:            !_syncDropDownController.syncInProgress
                    Layout.fillWidth:   true
                    text:                qsTr("存储到文件")//"Save to file..."
                    onClicked:  {
                        syncButton.hideDropDown()
                        _syncDropDownController.saveToSelectedFile()
                    }
                }
                Rectangle {
                    height:     1
                    width:      parent.width
                    color:     "grey"
                }
                SubMenuButton {
                    imageResource:      "/qmlimages/loadfromfile.svg"
                    enabled:            !_syncDropDownController.syncInProgress
                    Layout.fillWidth:   true
                    text:               qsTr("从文件载入")//"Load from file..."
                    onClicked:  {
                        syncButton.hideDropDown()
                        if (_syncDropDownController.dirty) {
                            qgcView.showDialog(syncLoadFromFileOverwrite, sendSaveGrid._overwriteText, qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                        } else {
                            _syncDropDownController.loadFromSelectedFile()
                        }
                    }
                }
                Rectangle {
                    height:     1
                    width:      parent.width
                    color:      "grey"
                }
                SubMenuButton {
                    imageResource:      "/qmlimages/clearmission.svg"
                    Layout.fillWidth:   true
                    text:               qsTr("删除所有航点")//"Remove all"
                    onClicked:  {
                        syncButton.hideDropDown()
                        _syncDropDownController.removeAll()
                        qgcView.showDialog(removeAllPromptDialog, qsTr("删除所有航点")/*qsTr("Remove all")*/, qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.No)
                    }
                }
            }
        }
    }
} // QGCVIew
