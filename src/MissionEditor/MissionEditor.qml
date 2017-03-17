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
    readonly property real      _rightPanelWidth:       Math.min(parent.width / 3, ScreenTools.defaultFontPixelWidth * 30)
    readonly property real      _rightPanelOpacity:     1
    readonly property int       _toolButtonCount:       6
    readonly property real      _toolButtonTopMargin:   parent.height - ScreenTools.availableHeight + (ScreenTools.defaultFontPixelHeight / 2)
    readonly property var       _defaultVehicleCoordinate:   QtPositioning.coordinate(37.803784, -122.462276)

    property var    _visualItems:           missionController.visualItems
    property var    _currentMissionItem
    property int    _currentMissionIndex:   0
    property bool   _firstVehiclePosition:  true
    property var    activeVehiclePosition:  _activeVehicle ? _activeVehicle.coordinate : QtPositioning.coordinate()
    property bool   _lightWidgetBorders:    editorMap.isSatelliteMap
    property bool   _addWaypointOnClick:    false

    /// The controller which should be called for load/save, send to/from vehicle calls
    property var _syncDropDownController: missionController

    readonly property int _layerMission:        1
    readonly property int _layerGeoFence:       2
    readonly property int _layerRallyPoints:    3
    property int _editingLayer: _layerMission

    property string   _filename:  ""
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

    property bool _firstMissionLoadComplete:    false
    property bool _firstFenceLoadComplete:      false
    property bool _firstRallyLoadComplete:      false
    property bool _firstLoadComplete:           false

    function checkFirstLoadComplete() {
        if (!_firstLoadComplete && _firstMissionLoadComplete && _firstRallyLoadComplete && _firstFenceLoadComplete) {
            _firstLoadComplete = true
            mapFitFunctions.fitMapViewportToAllItems()
        }
    }

    MapFitFunctions {
        id:                         mapFitFunctions
        map:                        editorMap
        mapFitViewport:             Qt.rect(leftToolWidth, toolbarHeight, editorMap.width - leftToolWidth - rightPanelWidth, editorMap.height - toolbarHeight)
        usePlannedHomePosition:     true
        mapGeoFenceController:      geoFenceController
        mapMissionController:       missionController
        mapRallyPointController:    rallyPointController

        property real toolbarHeight:    qgcView.height - ScreenTools.availableHeight
        property real rightPanelWidth:  _rightPanelWidth
        property real leftToolWidth:    0//toolStrip.x + toolStrip.width
    }

    MissionController {
        id: missionController

        Component.onCompleted: {
            start(true /* editMode */)
            setCurrentItem(0)
        }

        function loadFromSelectedFile() {
            if (ScreenTools.isMobile) {
                qgcView.showDialog(mobileFilePicker, qsTr("选择任务文件"), qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
            } else {
                _filename=missionController.getFromFilePicker()
                if(_filename.match(".mission"))
                {
                    missionController.loadFromFile(_filename)
                    mapFitFunctions.fitMapViewportToMissionItems()
                    _currentMissionItem = _visualItems.get(0)
                }
                else if(_filename.match(".txt"))
                {
                    qgcView.showDialog(loadandgenerateDialog, qsTr(""), qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                }
            }
        }

        function saveToSelectedFile() {
            if (ScreenTools.isMobile) {
                qgcView.showDialog(mobileFileSaver, qsTr("Save Mission File"), qgcView.showDialogDefaultWidth, StandardButton.Save | StandardButton.Cancel)
            } else {
                missionController.saveToFilePicker()
            }
        }

        function fitViewportToItems() {
            mapFitFunctions.fitMapViewportToMissionItems()
        }

        onVisualItemsChanged: {
            itemDragger.clearItem()
        }

        onNewItemsFromVehicle: {
            mapFitFunctions.fitMapViewportToMissionItems()
            setCurrentItem(0)
            _firstMissionLoadComplete = true
            checkFirstLoadComplete()
        }
    }

    GeoFenceController {
        id: geoFenceController

        Component.onCompleted: start(true /* editMode */)

        function saveToSelectedFile() {
            if (ScreenTools.isMobile) {
                qgcView.showDialog(mobileFileSaver, qsTr("Save Fence File"), qgcView.showDialogDefaultWidth, StandardButton.Save | StandardButton.Cancel)
            } else {
                geoFenceController.saveToFilePicker()
            }
        }

        function loadFromSelectedFile() {
            if (ScreenTools.isMobile) {
                qgcView.showDialog(mobileFilePicker, qsTr("Select Fence File"), qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
            } else {
                geoFenceController.loadFromFilePicker()
                mapFitFunctions.fitMapViewportToFenceItems()
            }
        }

        function validateBreachReturn() {
            if (geoFenceController.polygon.path.length > 0) {
                if (!geoFenceController.polygon.containsCoordinate(geoFenceController.breachReturnPoint)) {
                    geoFenceController.breachReturnPoint = geoFenceController.polygon.center()
                }
                if (!geoFenceController.polygon.containsCoordinate(geoFenceController.breachReturnPoint)) {
                    geoFenceController.breachReturnPoint = geoFenceController.polygon.path[0]
                }
            }
        }

        function fitViewportToItems() {
            mapFitFunctions.fitMapViewportToFenceItems()
        }

        onLoadComplete: {
            _firstFenceLoadComplete = true
            switch (_syncDropDownController) {
            case geoFenceController:
                mapFitFunctions.fitMapViewportToFenceItems()
                break
            case missionController:
                checkFirstLoadComplete()
                break
            }
        }
    }

    RallyPointController {
        id: rallyPointController

        onCurrentRallyPointChanged: {
            if (_editingLayer == _layerRallyPoints && !currentRallyPoint) {
                itemDragger.visible = false
                itemDragger.coordinateItem = undefined
                itemDragger.mapCoordinateIndicator = undefined
            }
        }

        Component.onCompleted: start(true /* editMode */)

        function saveToSelectedFile() {
            if (ScreenTools.isMobile) {
                qgcView.showDialog(mobileFileSaver, qsTr("Save Rally Point File"), qgcView.showDialogDefaultWidth, StandardButton.Save | StandardButton.Cancel)
            } else {
                rallyPointController.saveToFilePicker()
            }
        }

        function loadFromSelectedFile() {
            if (ScreenTools.isMobile) {
                qgcView.showDialog(mobileFilePicker, qsTr("Select Rally Point File"), qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
            } else {
                rallyPointController.loadFromFilePicker()
                mapFitFunctions.fitMapViewportToRallyItems()
            }
        }

        function fitViewportToItems() {
            mapFitFunctions.fitMapViewportToRallyItems()
        }

        onLoadComplete: {
            _firstRallyLoadComplete = true
            switch (_syncDropDownController) {
            case rallyPointController:
                mapFitFunctions.fitMapViewportToRallyItems()
                break
            case missionController:
                checkFirstLoadComplete()
                break
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
        //     _currentMissionItem = undefined
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

        QGCMobileFileOpenDialog {
            fileExtension: _syncDropDownController.fileExtension
            onFilenameReturned: {
                _syncDropDownController.loadFromFile(filename)
                _syncDropDownController.fitViewportToItems()
            }
        }
    }

    Component {
        id: mobileFileSaver

        QGCMobileFileSaveDialog {
            fileExtension:      _syncDropDownController.fileExtension
            onFilenameReturned: _syncDropDownController.saveToFile(filename)
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
                            if (geoFenceController.breachReturnEnabled) {
                                geoFenceController.breachReturnPoint = coordinate
                                geoFenceController.validateBreachReturn()
                            }
                            break
                        case _layerRallyPoints:
                            if (rallyPointController.rallyPointsSupported) {
                                rallyPointController.addPoint(coordinate)
                            }
                            break
                        }
                    }
                }

                // We use this item to support dragging since dragging a MapQuickItem just doesn't seem to work
                Rectangle {
                    id:             itemDragger
                    x:              mapCoordinateIndicator ? (mapCoordinateIndicator.x + mapCoordinateIndicator.anchorPoint.x - (itemDragger.width / 2)) : 100
                    y:              mapCoordinateIndicator ? (mapCoordinateIndicator.y + mapCoordinateIndicator.anchorPoint.y/2 - (itemDragger.height / 2)) : 100
                    width:          ScreenTools.defaultFontPixelHeight * 3  //2
                    height:         ScreenTools.defaultFontPixelHeight * 3  //2
                    color:          "transparent"
                    visible:        false
                    z:              QGroundControl.zOrderMapItems + 1    // Above item icons

                    property var    coordinateItem
                    property var    mapCoordinateIndicator
                    property bool   preventCoordinateBindingLoop: false

                    onXChanged: liveDrag()
                    onYChanged: liveDrag()

                    function liveDrag() {
                        if (!itemDragger.preventCoordinateBindingLoop && Drag.active) {
                            //                            var point = Qt.point(itemDragger.x + (itemDragger.width  / 2), itemDragger.y + (itemDragger.height / 2))
                            var point = Qt.point(itemDragger.x + (itemDragger.width  / 2), itemDragger.y + (itemDragger.height))
                            var coordinate = editorMap.toCoordinate(point)
                            coordinate.altitude = itemDragger.coordinateItem.coordinate.altitude
                            itemDragger.preventCoordinateBindingLoop = true
                            itemDragger.coordinateItem.coordinate = coordinate
                            itemDragger.preventCoordinateBindingLoop = false
                        }
                    }

                    function clearItem() {
                        itemDragger.visible = false
                        itemDragger.coordinateItem = undefined
                        itemDragger.mapCoordinateIndicator = undefined
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

                // Add the complex mission item to the map
                Repeater {
                    model: missionController.complexVisualItems

                    delegate: ComplexMissionItem {
                        map: editorMap
                    }
                }

                // Add the simple mission items to the map
                MapItemView {
                    model:      missionController.visualItems
                    delegate:   missionItemComponent
                }

                Component {
                    id: missionItemComponent

                    MissionItemIndicator {
                        id:             itemIndicator
                        coordinate:     object.coordinate
                        visible:        object.isSimpleItem && object.specifiesCoordinate
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
                                itemDragger.coordinateItem = Qt.binding(function() { return object })
                                itemDragger.mapCoordinateIndicator = Qt.binding(function() { return itemIndicator })
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
                                model: object.isSimpleItem ? object.childItems : 0

                                delegate: MissionItemIndexLabel {
                                    label:      object.abbreviation
                                    checked:    object.isCurrentItem
                                    z:          2

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

                // Add lines between waypoints
                MissionLineView {
                    model:      _editingLayer == _layerMission ? missionController.jumpwaypointLines : undefined
                }

//                Repeater {
//                    model:          missionController.visualItems
//                    delegate: MapCircle {
//                        border.color:   "#80FF0000"
//                        border.width:   3
//                        center:         modelData.coordinate
//                        radius:         75
//                        z:              QGroundControl.zOrderMapItems
//                        visible:        modelData.command == 31
//                    }
//                }

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

                // Plan Element selector (Mission/Fence/Rally)
                Row {
                    id:                 planElementSelectorRow
                    anchors.topMargin:  parent.height - ScreenTools.availableHeight + _margin
                    anchors.top:        parent.top
                    anchors.leftMargin: parent.width - _rightPanelWidth
                    anchors.left:       parent.left
                    spacing:            _horizontalMargin
                    visible:            QGroundControl.corePlugin.options.enablePlanViewSelector

                    readonly property real _buttonRadius: ScreenTools.defaultFontPixelHeight * 0.75

                    ExclusiveGroup {
                        id: planElementSelectorGroup
                        onCurrentChanged: {
                            switch (current) {
                            case planElementMission:
                                _editingLayer = _layerMission
                                _syncDropDownController = missionController
                                break
                            case planElementGeoFence:
                                _editingLayer = _layerGeoFence
                                _syncDropDownController = geoFenceController
                                break
                            case planElementRallyPoints:
                                _editingLayer = _layerRallyPoints
                                _syncDropDownController = rallyPointController
                                break
                            }
                            _syncDropDownController.fitViewportToItems()
                        }
                    }

                    QGCRadioButton {
                        id:             planElementMission
                        exclusiveGroup: planElementSelectorGroup
                        text:           qsTr("Mission")
                        checked:        true
                        color:          mapPal.text
                        textStyle:      Text.Outline
                        textStyleColor: mapPal.textOutline
                    }

                    Item { height: 1; width: 1 }

                    QGCRadioButton {
                        id:             planElementGeoFence
                        exclusiveGroup: planElementSelectorGroup
                        text:           qsTr("Fence")
                        color:          mapPal.text
                        textStyle:      Text.Outline
                        textStyleColor: mapPal.textOutline
                    }

                    Item { height: 1; width: 1 }

                    QGCRadioButton {
                        id:             planElementRallyPoints
                        exclusiveGroup: planElementSelectorGroup
                        text:           qsTr("Rally")
                        color:          mapPal.text
                        textStyle:      Text.Outline
                        textStyleColor: mapPal.textOutline
                    }
                } // Row - Plan Element Selector

                // Mission Item Editor
                Item {
                    id:             missionItemIndex//missionItemEditor
                    height:         _PointFieldWidth+ScreenTools.defaultFontPixelWidth//mainWindow.availableHeight/5  //change by yaoling
                    //                    anchors.top:        planElementSelectorRow.visible ? planElementSelectorRow.bottom : planElementSelectorRow.top
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
                        anchors.fill:       missionItemEditorListView
                        onWheel:            wheel.accepted = true
                    }

                    QGCListView {
                        id:             missionItemEditorListView
                        anchors.left:   parent.left
                        //                       anchors.right:  parent.right
                        anchors.top:    parent.top
                        height:         parent.height
                        width:          parent.width   //add yaoling
                        spacing:        _margin / 2
                        //                      orientation:    ListView.Vertical   //change by yaoling
                        orientation:    ListView.Horizontal
                        model:          missionController.visualItems
                        cacheBuffer:    height * 2
                        clip:           true
                        currentIndex:   _currentMissionIndex
                        highlightMoveDuration: 250
                        delegate:       MissionItemIndex{//MissionItemEditor {
                            missionItem:    object
                            width:          _PointFieldWidth//parent.width
                            readOnly:       false

                            onClicked:  setCurrentItem(object.sequenceNumber)

                            //                            onRemove: {
                            //                                itemDragger.clearItem()
                            //                                missionController.removeMissionItem(index)
                            //                                editorMap.polygonDraw.cancelPolygonEdit()
                            //                            }

                            //                            onInsert: {
                            //                                var sequenceNumber = missionController.insertSimpleMissionItem(editorMap.center, index)
                            //                                setCurrentItem(sequenceNumber)
                            //                            }

                            //                            onMoveHomeToMapCenter: _visualItems.get(0).coordinate = editorMap.center
                        }
                    } // QGCListView
                } // Item - Mission Item editor
                Image {
                    id:                     allsetimg
                    anchors.verticalCenter: missionItemIndex.verticalCenter
                    anchors.right:          parent.right
                    anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
                    height:                 _PointFieldWidth.width/2
                    width:                  height
                    smooth:                 true
                    source:                 "/res/gear-black.svg"
                    z:              QGroundControl.zOrderTopMost
                    MouseArea {
                        anchors.fill:       parent
                        onClicked: {
                            setimg.visible=!setimg.visible
                        }
                    }
                }

                SetMutipMissionItem
                {
                    id:                     setimg
                    anchors.centerIn:       parent
                    missionItems:           _visualItems
                    z:                      QGroundControl.zOrderTopMost
                    visible:                false
                }


                // GeoFence Editor
                Loader {
                    anchors.topMargin:  _margin
                    anchors.top:        planElementSelectorRow.bottom
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
                    path:           geoFenceController.polygon.path
                    z:              QGroundControl.zOrderMapItems
                    visible:        geoFenceController.polygonEnabled
                }

                // GeoFence circle
                MapCircle {
                    border.color:   "#80FF0000"
                    border.width:   3
                    center:         missionController.plannedHomePosition
                    radius:         geoFenceController.circleRadius
                    z:              QGroundControl.zOrderMapItems
                    visible:        geoFenceController.circleEnabled
                }

                // GeoFence breach return point
                MapQuickItem {
                    anchorPoint:    Qt.point(sourceItem.width / 2, sourceItem.height / 2)
                    coordinate:     geoFenceController.breachReturnPoint
                    visible:        geoFenceController.breachReturnEnabled
                    sourceItem:     MissionItemIndexLabel {
                        label: "F"
                        simple:  true
                    }
                    z:              QGroundControl.zOrderMapItems
                }

                // Rally Point Editor

                RallyPointEditorHeader {
                    id:                 rallyPointHeader
                    anchors.topMargin:  _margin
                    anchors.top:        planElementSelectorRow.bottom
                    anchors.right:      parent.right
                    width:              _rightPanelWidth
                    opacity:            _rightPanelOpacity
                    z:                  QGroundControl.zOrderTopMost
                    visible:            _editingLayer == _layerRallyPoints
                    controller:         rallyPointController
                }

                RallyPointItemEditor {
                    id:                 rallyPointEditor
                    anchors.topMargin:  _margin
                    anchors.top:        rallyPointHeader.bottom
                    anchors.right:      parent.right
                    width:              _rightPanelWidth
                    opacity:            _rightPanelOpacity
                    z:                  QGroundControl.zOrderTopMost
                    visible:            _editingLayer == _layerRallyPoints && rallyPointController.points.count
                    rallyPoint:         rallyPointController.currentRallyPoint
                    controller:         rallyPointController
                }

                // Rally points on map

                MapItemView {
                    model: rallyPointController.points

                    delegate: MapQuickItem {
                        id:             itemIndicator
                        anchorPoint:    Qt.point(sourceItem.width / 2, sourceItem.height / 2)
                        coordinate:     object.coordinate
                        z:              QGroundControl.zOrderMapItems

                        sourceItem: MissionItemIndexLabel {
                            id:         itemIndexLabel
                            label:      qsTr("R", "rally point map item label")
                            checked:    _editingLayer == _layerRallyPoints ? object == rallyPointController.currentRallyPoint : false
                            simple:     true
                            onClicked: rallyPointController.currentRallyPoint = object

                            onCheckedChanged: {
                                if (checked) {
                                    // Setup our drag item
                                    itemDragger.visible = true
                                    itemDragger.coordinateItem = Qt.binding(function() { return object })
                                    itemDragger.mapCoordinateIndicator = Qt.binding(function() { return itemIndicator })
                                }
                            }
                        }
                    }
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
                /*
                QGCMapLabel {
                    id:                         planLabel
                    map:                        editorMap
                    text:                       qsTr("Plan")
                    visible:                    !ScreenTools.isShortScreen
                    anchors.topMargin:          _toolButtonTopMargin
                    anchors.horizontalCenter:   addMissionItemsButton.horizontalCenter
                    anchors.top:                parent.top
                }
*/
                // IMPORTANT NOTE: Drop Buttons must be parented directly to the map. If they are placed in a Column for example the drop control positioning
                // will not work correctly.
                //-- horizontal Tool Buttons
                Row {
                    id:                 toolColumn
                    anchors.topMargin:  ScreenTools.toolbarHeight*1.8 + ScreenTools.defaultFontPixelWidth
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
                    RoundButton{//DropButton
                        id:             addShapeButton
           //             dropDirection:      dropDown
                        buttonImage:    "/qmlimages/MapDrawShape.svg"
                        lightBorders:   _lightWidgetBorders
                        visible:        _editingLayer == _layerMission
                        onClicked: {
                            var coordinate = editorMap.center
                            coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
                            coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
                            coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)
                            var sequenceNumber = missionController.insertComplexMissionItem("Survey", coordinate, missionController.visualItems.count)
                            setCurrentItem(sequenceNumber)
                            checked = false
                            addMissionItemsButton.checked = false
                        }
//                        dropDownComponent: Component {
//                            Column {
//                                spacing: ScreenTools.defaultFontPixelWidth
//                                Repeater {
//                                    model: missionController.complexMissionItemNames

//                                    QGCButton {
//                                        text:               modelData
//                                        Layout.fillWidth:   true

//                                        onClicked: {
//                                            var coordinate = editorMap.center
//                                            coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
//                                            coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
//                                            coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)
//                                            var sequenceNumber = missionController.insertComplexMissionItem(modelData, coordinate, missionController.visualItems.count)
//                                            setCurrentItem(sequenceNumber)
//                                            addShapeButton.hideDropDown()
//                                        }
//                                    }
//                                }
//                            }
//                        }
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
                        dropDownComponent:  syncDropPanel//syncDropDownComponent
                        enabled:            !_syncDropDownController.syncInProgress
                        rotateImage:        _syncDropDownController.syncInProgress
                        lightBorders:       _lightWidgetBorders
                    }
                    Rectangle {
                        height:     parent.height*0.8
                        width:      1
                        color:      "grey"
                    }
                    CenterMapDropButton {
                        id:                     centerMapButton
                        exclusiveGroup:         _dropButtonsExclusiveGroup
                        map:                    editorMap
                        mapFitViewport:         Qt.rect(leftToolWidth, toolbarHeight, editorMap.width - leftToolWidth - rightPanelWidth, editorMap.height - toolbarHeight)
                        usePlannedHomePosition: true
                        geoFenceController:     geoFenceController
                        missionController:      missionController
                        rallyPointController:   rallyPointController

                        property real toolbarHeight:    qgcView.height - ScreenTools.availableHeight
                        property real rightPanelWidth:  _rightPanelWidth
                        property real leftToolWidth:    centerMapButton.x + centerMapButton.width
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
                        id:                 mapZoomPlus
//                        anchors.topMargin:  ScreenTools.defaultFontPixelHeight
//                        anchors.top:        mapTypeButton.bottom
//                        anchors.left:       mapTypeButton.left
                        visible:            !ScreenTools.isTinyScreen && !ScreenTools.isShortScreen
                        buttonImage:        "/qmlimages/ZoomPlus.svg"
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
                        id:                 mapZoomMinus
//                        anchors.topMargin:  ScreenTools.defaultFontPixelHeight
//                        anchors.top:        mapZoomPlus.bottom
//                        anchors.left:       mapZoomPlus.left
                        visible:            !ScreenTools.isTinyScreen && !ScreenTools.isShortScreen
                        buttonImage:        "/qmlimages/ZoomMinus.svg"
                        lightBorders:       _lightWidgetBorders
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
                    mapControl:         editorMap
                    visible:            !ScreenTools.isTinyScreen

                }

                MissionItemIndexIndicator {
                    id:              indexIndicator
                    anchors.right:   parent.right
                    anchors.top:     parent.top
                    anchors.topMargin:     ScreenTools.toolbarHeight*1.8 + ScreenTools.defaultFontPixelWidth
                    anchors.rightMargin:   _margin*2
                    width:               _rightPanelWidth
                    currentMissionItem:  _currentMissionItem
                    missionItems:        missionController.visualItems
                    missionDistance:     missionController.missionDistance
                    missionTime:         missionController.missionTime
                    missionMaxTelemetry: missionController.missionMaxTelemetry
                    qgcView:        qgcView
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
                height:     ScreenTools.defaultFontPixelHeight*5
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
                height:     ScreenTools.defaultFontPixelHeight*5
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
                height:     ScreenTools.defaultFontPixelHeight*5
                message: qsTr("确认删除所有任务点?")//"Are you sure you want to delete all mission items?"
                function accept() {
                    itemDragger.clearItem()
                    _syncDropDownController.removeAll()
                    hideDialog()
                }
            }
        }

        //- ToolStrip DropPanel Components

        Component {
            id: syncDropPanel

            Column {
                id:         columnHolder
                property string _overwriteText: (_editingLayer == _layerMission) ? qsTr("覆盖任务")/*qsTr("Mission overwrite")*/ : qsTr("GeoFence overwrite")
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
                            qgcView.showDialog(syncLoadFromVehicleOverwrite, columnHolder._overwriteText, qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
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
                            qgcView.showDialog(syncLoadFromFileOverwrite, columnHolder._overwriteText, qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
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
                        qgcView.showDialog(removeAllPromptDialog, qsTr("删除所有航点")/*qsTr("Remove all")*/, qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.No)
                    }
                }
            }
        }
        Component {
            id: centerMapDropPanel

            CenterMapDropPanel {
                map:            editorMap
                fitFunctions:   mapFitFunctions
            }
        }
        Component {
            id: mapTypeDropPanel

            Column {
                spacing: _margin

                QGCLabel { text: qsTr("Map type:") }
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth
                    Repeater {
                        model: QGroundControl.flightMapSettings.mapTypes

                        QGCButton {
                            checkable:      true
                            checked:        QGroundControl.flightMapSettings.mapType === text
                            text:           modelData
                            exclusiveGroup: _mapTypeButtonsExclusiveGroup

                            onClicked: {
                                QGroundControl.flightMapSettings.mapType = text
                                syncButton.hideDropDown()
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: patternDropPanel

            ColumnLayout {
                spacing:    ScreenTools.defaultFontPixelWidth * 0.5

                QGCLabel { text: qsTr("Create complex pattern:") }

                Repeater {
                    model: missionController.complexMissionItemNames

                    QGCButton {
                        text:               modelData
                        Layout.fillWidth:   true

                        onClicked: {
                            var coordinate = editorMap.center
                            coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
                            coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
                            coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)
                            var sequenceNumber = missionController.insertComplexMissionItem(modelData, coordinate, missionController.visualItems.count)
                            setCurrentItem(sequenceNumber)
                            syncButton.hideDropDown()
                        }
                    }
                }
            }
        }
        Component {
            id: loadandgenerateDialog

            QGCViewDialog {
                width:          ScreenTools.defaultFontPixelHeight*10
                height:         ScreenTools.defaultFontPixelHeight*12
                function accept() {
                    //   var toIndex = toCombo.currentIndex
                    missionController.loadFromTxtFile(_filename,Number(wayangle.text),Number(wayspace.text),Number(addalt.text),Number(waynum.text),camer.checked,relalt.checked)
                    hideDialog()
                }
                Rectangle {
                    id:                         title
                    anchors.top:                parent.top
                    anchors.topMargin:          -ScreenTools.defaultFontPixelHeight*2
                    anchors.horizontalCenter:   parent.horizontalCenter
                    width:                      parent.width
                    height:                     ScreenTools.defaultFontPixelHeight*4
                    color:                      "transparent"
                    QGCCircleProgress{
                        id:                     circle
                        anchors.left:           parent.left
                        anchors.top:            parent.top
                        anchors.leftMargin:     ScreenTools.defaultFontPixelHeight*3
                        width:                  ScreenTools.defaultFontPixelHeight*3
                        value:                  0
                    }
                    QGCColoredImage {
                        id:                     img
                        height:                 ScreenTools.defaultFontPixelHeight*1.5
                        width:                  height
                        sourceSize.width: width
                        source:     "/qmlimages/loadfromfile.svg"
                        fillMode:   Image.PreserveAspectFit
                        color:      qgcPal.text
                        anchors.horizontalCenter:circle.horizontalCenter
                        anchors.verticalCenter: circle.verticalCenter
                    }
                    QGCLabel {
                        id:             idset
                        anchors.left:   img.left
                        anchors.leftMargin: ScreenTools.defaultFontPixelHeight*3
                        text:           qsTr("生成航线参数")//"safe"
                        font.pointSize: ScreenTools.mediumFontPointSize
                        font.bold:              true
                        color:          qgcPal.text
                        anchors.verticalCenter: img.verticalCenter
                    }
                    Image {
                        source:    "/qmlimages/title.svg"
                        width:      idset.width+ScreenTools.defaultFontPixelHeight*3
                        height:     ScreenTools.defaultFontPixelHeight*1.5
                        anchors.verticalCenter: circle.verticalCenter
                        anchors.left:          circle.right
                        //                fillMode: Image.PreserveAspectFit
                    }
                }
                Column {
                    anchors.top:                title.bottom
                    anchors.horizontalCenter:   parent.horizontalCenter
                    width:          parent.width*0.8
                    spacing:        ScreenTools.defaultFontPixelHeight
                    Row {
                        spacing:    ScreenTools.defaultFontPixelHeight*2
                        Row {
                            spacing:    ScreenTools.defaultFontPixelHeight
                            QGCLabel {
                                anchors.baseline:   wayangle.baseline
                                text:               qsTr("偏移角度:")
                                width:              ScreenTools.defaultFontPixelHeight*5
                            }
                            QGCTextField {
                                id:                 wayangle
                                width:              ScreenTools.defaultFontPixelHeight*5
                                validator:          DoubleValidator {bottom: 0; top: 360;}
                                inputMethodHints:   Qt.ImhDigitsOnly
                                text:               "90"
                            }
                            QGCLabel {
                                text:               qsTr("度")
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelHeight
                            QGCLabel {
                                anchors.baseline:   wayspace.baseline
                                text:               qsTr("偏移距离:")
                                width:              ScreenTools.defaultFontPixelHeight*5
                            }
                            QGCTextField {
                                id:                 wayspace
                                width:              ScreenTools.defaultFontPixelHeight*5
                                validator:          DoubleValidator {bottom: 0; top: 5000;}
                                inputMethodHints:   Qt.ImhDigitsOnly
                                text:               "0.0"
                            }
                            QGCLabel {
                                text:               qsTr("米")
                            }
                        }
                    }
                    Row {
                        spacing: ScreenTools.defaultFontPixelHeight*2
                        anchors.horizontalCenter: parent.horizontalCenter
                        ExclusiveGroup { id: modeGroup }

                        QGCRadioButton {
                            id:             relalt
                            exclusiveGroup: modeGroup
                            text:           qsTr("相对高度")//"Mode 1"
                            checked:        true
                        }

                        QGCRadioButton {
                            exclusiveGroup: modeGroup
                            text:           qsTr("海拔高度")//"Mode 2"
                        }
                    }
                    //                FactTextFieldGrid {
                    //                    width:          ScreenTools.defaultFontPixelHeight*12
                    //                    columnSpacing:  _margin
                    //                    rowSpacing:     _margin
                    //                    showHelpdig:    false
                    //                    factList:       [ missionController.genoffsetAngle, missionController.genoffsetSpacing ]
                    //                }
                    Row {
                        spacing:    ScreenTools.defaultFontPixelHeight
                        QGCLabel {
                            anchors.baseline:   addalt.baseline
                            text:               qsTr("增加高度:")
                            width:              ScreenTools.defaultFontPixelHeight*5
                        }
                        QGCTextField {
                            id:                 addalt
                            width:              ScreenTools.defaultFontPixelHeight*5
                            validator:          DoubleValidator {bottom: 0; top: 5000;}
                            inputMethodHints:   Qt.ImhDigitsOnly
                            text:               "0.0"
                        }
                        QGCLabel {
                            text:               qsTr("米")
                        }
                    }
                    QGCCheckBox {
                        id:         camer
                        text:       qsTr("是否拍照:")//qsTr("Enable Flow Control")
                    }

                    Row {
                        spacing:    ScreenTools.defaultFontPixelHeight
                        QGCLabel {
                            anchors.baseline:   waynum.baseline
                            text:               qsTr("路径条数:")
                            width:              ScreenTools.defaultFontPixelHeight*5
                        }
                        QGCTextField {
                            id:                 waynum
                            width:              ScreenTools.defaultFontPixelHeight*5
                            validator:          IntValidator {bottom: 1; top: 5;}
                            inputMethodHints:   Qt.ImhDigitsOnly
                            text:               "1"
                        }
                    }
                }
            }
        }
    }
} // QGCVIew
