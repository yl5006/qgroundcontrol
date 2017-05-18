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
import QtQuick.Dialogs  1.2
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Mavlink       1.0
import QGroundControl.Controllers   1.0

/// Mission Editor

QGCView {
    id:         _qgcView
    viewPanel:  panel
    z:          QGroundControl.zOrderTopMost

    readonly property int       _decimalPlaces:         8
    readonly property real      _horizontalMargin:      ScreenTools.defaultFontPixelWidth  / 2
    readonly property real      _margin:                ScreenTools.defaultFontPixelHeight * 0.5
    readonly property var       _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    readonly property real      _PointFieldWidth:       ScreenTools.defaultFontPixelWidth * 11
    readonly property real      _rightPanelWidth:       Math.min(parent.width / 3, ScreenTools.defaultFontPixelWidth * 35)
    readonly property real      _toolButtonTopMargin:   parent.height - ScreenTools.availableHeight + (ScreenTools.defaultFontPixelHeight / 2)
    readonly property var       _defaultVehicleCoordinate:   QtPositioning.coordinate(37.803784, -122.462276)

    property var    _planMasterController:      masterController
    property var    _missionController:         _planMasterController.missionController
    property var    _geoFenceController:        _planMasterController.geoFenceController
    property var    _rallyPointController:      _planMasterController.rallyPointController
    property var    _visualItems:               _missionController.visualItems
    property var    _currentMissionItem
    property int    _currentMissionIndex:       0
    property bool   _lightWidgetBorders:        editorMap.isSatelliteMap
    property bool   _addWaypointOnClick:        false
    property bool   _singleComplexItem:         _missionController.complexMissionItemNames.length === 1
    property real   _toolbarHeight:             _qgcView.height - ScreenTools.availableHeight
    property int    _editingLayer:              _layerMission
    property string   _file:                ""
    readonly property int       _layerMission:              1
    readonly property int       _layerGeoFence:             2
    readonly property int       _layerRallyPoints:          3
    readonly property string    _armedVehicleUploadPrompt:  qsTr("Vehicle is currently armed. Do you want to upload the mission to the vehicle?")
    property var coordinateruler1   :               editorMap.center
    property var coordinateruler2   :               editorMap.center
    property bool firstpoint        :               false
    property Fact _mapType:                         QGroundControl.settingsManager.flightMapSettings.mapType
    Component.onCompleted: {
//        toolbar.planMasterController =  Qt.binding(function () { return _planMasterController })
//        toolbar.currentMissionItem =    Qt.binding(function () { return _currentMissionItem })
    }

    function addComplexItem(complexItemName) {
        var coordinate = editorMap.center
        coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
        coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
        coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)
        insertComplexMissionItem(complexItemName, coordinate, _missionController.visualItems.count)
    }

    function insertComplexMissionItem(complexItemName, coordinate, index) {
        var sequenceNumber = _missionController.insertComplexMissionItem(complexItemName, coordinate, index)
        setCurrentItem(sequenceNumber, true)
    }

    property bool _firstMissionLoadComplete:    false
    property bool _firstFenceLoadComplete:      false
    property bool _firstRallyLoadComplete:      false
    property bool _firstLoadComplete:           false

    MapFitFunctions {
        id:                         mapFitFunctions
        map:                        editorMap
        usePlannedHomePosition:     true
        planMasterController:       _planMasterController
    }

    Connections {
        target: QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude

        onRawValueChanged: {
            if (_visualItems.count > 1) {
                _qgcView.showDialog(applyNewAltitude, qsTr("修改高度"), showDialogDefaultWidth, StandardButton.Yes | StandardButton.No)
            }
        }
    }

    Component {
        id: applyNewAltitude

        QGCViewMessage {
            message:    qsTr("你以改变任务默认高度. 你希望改变当前任务所有高度吗?")

            function accept() {
                hideDialog()
                _missionController.applyDefaultMissionAltitude()
            }
        }
    }

    Component {
        id: activeMissionUploadDialogComponent

        QGCViewDialog {
            height:   ScreenTools.defaultFontPixelHeight*10
            Column {
                anchors.fill:   parent
                spacing:        ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       qsTr("你的飞机正在执行任务. 上传或修改任务会暂停飞机.")
                }

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       qsTr("当任务上传成功后， 你可以选择当前航点继续任务.")
                }

                QGCButton {
                    text:       qsTr("暂停任务后上传")
                    onClicked: {
                        _activeVehicle.flightMode = _activeVehicle.pauseFlightMode
                        _planMasterController.sendToVehicle()
                        hideDialog()
                    }
                }
            }
        }
    }

    PlanElemementMasterController {
        id: masterController

        property var nameFilters: [ qsTr("Mission Files (*.%1)").arg(missionController.fileExtension) , qsTr("text Files (*.txt)"), qsTr("All Files (*.*)") ]
        Component.onCompleted: {
            start(true /* editMode */)
            setCurrentItem(0, true)
        }

        function upload() {
            if (_activeVehicle && _activeVehicle.armed && _activeVehicle.flightMode === _activeVehicle.missionFlightMode) {
                _qgcView.showDialog(activeMissionUploadDialogComponent, qsTr("任务上传"), _qgcView.showDialogDefaultWidth, StandardButton.Cancel)
            } else {
                sendToVehicle()
            }
        }

        function loadFromSelectedFile() {
            fileDialog.title =          qsTr("Select Plan File")
            fileDialog.selectExisting = true
            fileDialog.nameFilters =    masterController.loadNameFilters
            fileDialog.openForLoad()
        }

        function saveToSelectedFile() {
            fileDialog.title =          qsTr("Save Plan")
            fileDialog.selectExisting = false
            fileDialog.nameFilters =    masterController.saveNameFilters
            fileDialog.openForSave()
        }

        function fitViewportToItems() {
            mapFitFunctions.fitMapViewportToMissionItems()
        }
    }

    Connections {
        target: _missionController

        onNewItemsFromVehicle: {
            if (_visualItems && _visualItems.count != 1) {
                mapFitFunctions.fitMapViewportToMissionItems()
            }
            setCurrentItem(0, true)
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    ExclusiveGroup {
        id: _mapTypeButtonsExclusiveGroup
    }

    ExclusiveGroup {
        id: _dropButtonsExclusiveGroup
    }

    /// Sets a new current mission item
    ///     @param sequenceNumber - index for new item, -1 to clear current item
    function setCurrentItem(sequenceNumber, force) {
        if (force || sequenceNumber !== _currentMissionIndex) {
            _currentMissionItem = undefined
            _currentMissionIndex = -1
            for (var i=0; i<_visualItems.count; i++) {
                var visualItem = _visualItems.get(i)
                if (visualItem.sequenceNumber == sequenceNumber) {
                    _currentMissionItem = visualItem
                    _currentMissionItem.isCurrentItem = true
                    _currentMissionIndex = sequenceNumber
                } else {
                    visualItem.isCurrentItem = false
                }
            }
        }
    }

    /// Inserts a new simple mission item
    ///     @param coordinate Location to insert item
    ///     @param index Insert item at this index
    function insertSimpleMissionItem(coordinate, index) {
        var sequenceNumber = _missionController.insertSimpleMissionItem(coordinate, index)
        setCurrentItem(sequenceNumber, true)
    }

    property int _moveDialogMissionItemIndex

    QGCFileDialog {
        id:             fileDialog
        qgcView:        _qgcView
        folder:         QGroundControl.settingsManager.appSettings.missionSavePath
        fileExtension:  QGroundControl.settingsManager.appSettings.planFileExtension
        fileExtension2: QGroundControl.settingsManager.appSettings.missionFileExtension

        onAcceptedForSave: {
            masterController.saveToFile(file)
            close()
        }

        onAcceptedForLoad: {
            if(file.match(".mission")||file.match(".plan"))
            {
            masterController.loadFromFile(file)
            masterController.fitViewportToItems()
            setCurrentItem(0, true)
            close()
            }
            if(file.match(".txt"))
            {
            _file=file
            qgcView.showDialog(loadandgenerateDialog, qsTr(""), qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
            }
        }
    }
    Component {
        id: loadandgenerateDialog

        QGCViewDialog {
            width:          ScreenTools.defaultFontPixelHeight*10
            height:         ScreenTools.defaultFontPixelHeight*12
            function accept() {
                console.log(_file)
                _missionController.loadFromTxtFile(_file,Number(wayangle.text),Number(wayspace.text),Number(addalt.text),Number(waynum.text),camer.checked,relalt.checked)
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

    Component {
        id: moveDialog

        QGCViewDialog {
            function accept() {
                var toIndex = toCombo.currentIndex

                if (toIndex == 0) {
                    toIndex = 1
                }
                _missionController.moveMissionItem(_moveDialogMissionItemIndex, toIndex)
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
        anchors.fill:   parent

        FlightMap {
            id:                         editorMap
            anchors.fill:               parent
            mapName:                    "MissionEditor"
            allowGCSLocationCenter:     true
            allowVehicleLocationCenter: true
            planView:                   true

            // This is the center rectangle of the map which is not obscured by tools
            property rect centerViewport: Qt.rect(_leftToolWidth, _toolbarHeight, editorMap.width - _leftToolWidth - _rightPanelWidth, editorMap.height - _statusHeight - _toolbarHeight)

            property real _leftToolWidth:   0//toolStrip.x + toolStrip.width
            property real _statusHeight:    0//waypointValuesDisplay.visible ? editorMap.height - waypointValuesDisplay.y : 0

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
                acceptedButtons:    Qt.LeftButton | Qt.RightButton
                hoverEnabled:       true
                onClicked: {
                    //-- Don't pay attention to items beneath the toolbar.
                    var topLimit = parent.height - ScreenTools.availableHeight
                    if(mouse.y < topLimit) {
                        return
                    }

                    var coordinate = editorMap.toCoordinate(Qt.point(mouse.x, mouse.y), false /* clipToViewPort */)
                    coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
                    coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
                    coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)

                    switch (_editingLayer) {
                    case _layerMission:
                        if (_addWaypointOnClick) {
                            insertSimpleMissionItem(coordinate, _missionController.visualItems.count)
                        }
                        else if(ruler.checked)
                        {
                            if (mouse.button == Qt.LeftButton){
                                coordinateruler1 = coordinate
                                firstpoint=true
                            }
                            else
                            {
                                firstpoint=false
                            }
                        }
                        break
                    case _layerRallyPoints:
                        if (_rallyPointController.rallyPointsSupported) {
                            _rallyPointController.addPoint(coordinate)
                        }
                        break
                    }
                }
                onPositionChanged:{
                    if(firstpoint&&ruler.checked)
                    {
                        var coordinate = editorMap.toCoordinate(Qt.point(mouse.x, mouse.y), false /* clipToViewPort */)
                        coordinateruler2 = coordinate
                    }
                }

            }

            // Add the mission item visuals to the map
            Repeater {
                model: _editingLayer == _layerMission ? _missionController.visualItems : undefined

                delegate: MissionItemMapVisual {
                    map:        editorMap
                    onClicked:  setCurrentItem(sequenceNumber, false)
                    visible:    _editingLayer == _layerMission
                }
            }

            // Add lines between waypoints
            MissionLineView {
                model: _editingLayer == _layerMission ? _missionController.waypointLines : undefined
            }
           // Add lines between jumpwaypoints
            MissionLineView {
                model: _editingLayer == _layerMission ? _missionController.jumpwaypointLines : undefined
           }

           MapPolyline {
                        line.width: 3
                        line.color: qgcPal.warningText
                        visible:    ruler.checked
                        z:          QGroundControl.zOrderTrajectoryLines
                        path: [
                            coordinateruler1,
                            coordinateruler2,
                        ]
           }
            // Add the vehicles to the map
            MapItemView {
                model: QGroundControl.multiVehicleManager.vehicles
                delegate:
                    VehicleMapItem {
                    vehicle:        object
                    coordinate:     object.coordinate
                    isSatellite:    editorMap.isSatelliteMap
                    size:           ScreenTools.defaultFontPixelHeight * 2
                    z:              QGroundControl.zOrderMapItems - 1
                }
            }

            GeoFenceMapVisuals {
                map:                    editorMap
                myGeoFenceController:   _geoFenceController
                interactive:            _editingLayer == _layerGeoFence
                homePosition:           _missionController.plannedHomePosition
                planView:               true
            }

            RallyPointMapVisuals {
                map:                    editorMap
                myRallyPointController: _rallyPointController
                interactive:            _editingLayer == _layerRallyPoints
                planView:               true
            }
/*
            ToolStrip {
                id:                 toolStrip
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                anchors.left:       parent.left
                anchors.topMargin:  _toolButtonTopMargin
                anchors.top:        parent.top
                color:              qgcPal.window
                title:              qsTr("Plan")
                z:                  QGroundControl.zOrderWidgets
                showAlternateIcon:  [ false, false, masterController.dirty, false, false, false ]
                rotateImage:        [ false, false, masterController.syncInProgress, false, false, false ]
                animateImage:       [ false, false, masterController.dirty, false, false, false ]
                buttonEnabled:      [ true, true, !masterController.syncInProgress, true, true, true ]
                buttonVisible:      [ true, true, true, true, _showZoom, _showZoom ]
                maxHeight:          mapScale.y - toolStrip.y

                property bool _showZoom: !ScreenTools.isMobile

                model: [
                    {
                        name:       "Waypoint",
                        iconSource: "/qmlimages/MapAddMission.svg",
                        toggle:     true
                    },
                    {
                        name:               _singleComplexItem ? _missionController.complexMissionItemNames[0] : "Pattern",
                        iconSource:         "/qmlimages/MapDrawShape.svg",
                        dropPanelComponent: _singleComplexItem ? undefined : patternDropPanel
                    },
                    {
                        name:                   "Sync",
                        iconSource:             "/qmlimages/MapSync.svg",
                        alternateIconSource:    "/qmlimages/MapSyncChanged.svg",
                        dropPanelComponent:     syncDropPanel
                    },
                    {
                        name:               "Center",
                        iconSource:         "/qmlimages/MapCenter.svg",
                        dropPanelComponent: centerMapDropPanel
                    },
                    {
                        name:               "In",
                        iconSource:         "/qmlimages/ZoomPlus.svg"
                    },
                    {
                        name:               "Out",
                        iconSource:         "/qmlimages/ZoomMinus.svg"
                    }
                ]

                onClicked: {
                    switch (index) {
                    case 0:
                        _addWaypointOnClick = checked
                        break
                    case 1:
                        if (_singleComplexItem) {
                            addComplexItem(_missionController.complexMissionItemNames[0])
                        }
                        break
                    case 4:
                        editorMap.zoomLevel += 0.5
                        break
                    case 5:
                        editorMap.zoomLevel -= 0.5
                        break
                    }
                }
            }
*/
            // Mission Item Editor
            Item {
                id:                 missionItemIndex//missionItemEditor
                height:             _PointFieldWidth+ScreenTools.defaultFontPixelWidth//mainWindow.availableHeight/5  //change by yaoling
                anchors.bottom:     parent.bottom
                anchors.horizontalCenter:           parent.horizontalCenter
                width:          mainWindow.availableWidth*0.9   //change by yaoling
                z:              QGroundControl.zOrderTopMost
                visible:            _editingLayer == _layerMission

                QGCListView {
                    id:             missionItemEditorListView
                    anchors.fill:    parent
                    spacing:        _margin / 2
                    orientation:    ListView.Horizontal
                    model:          _missionController.visualItems
                    cacheBuffer:    width * 2
                    clip:           true
                    currentIndex:   _currentMissionIndex
                    highlightMoveDuration: 250

                    delegate: MissionItemIndex {
     //                   map:            editorMap
                        missionItem:    object
                        width:          _PointFieldWidth
                        readOnly:       false
                        //rootQgcView:    _qgcView

                        onClicked:  setCurrentItem(object.sequenceNumber)

//                        onRemove: {
//                            var removeIndex = index
//                            itemDragger.clearItem()
//                            missionController.removeMissionItem(removeIndex)
//                            if (removeIndex >= missionController.visualItems.count) {
//                                removeIndex--
//                            }
//                            setCurrentItem(removeIndex)
//                        }

//                        onInsert: insertSimpleMissionItem(editorMap.center, index)
                    }
                } // QGCListView
            } // Item - Mission Item editor



            Image {
                id:                     allsetimg
                anchors.verticalCenter: missionItemIndex.verticalCenter
                anchors.right:          parent.right
                anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
                height:                 _PointFieldWidth.width/2
                fillMode: Image.TileVertically
                width:                  allsetimg.height
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
            SetmissionItemDialog
            {
                id:                     setmissionItem
                anchors.top:            parent.top
                anchors.topMargin:      ScreenTools.toolbarHeight*1.8 + ScreenTools.defaultFontPixelWidth
                anchors.right:          parent.right
                anchors.rightMargin:    ScreenTools.defaultFontPixelHeight+_rightPanelWidth
                z:                      QGroundControl.zOrderTopMost
            }
            SetCircleItemDialog
            {
                id:                     setCircleItem
                anchors.top:            setmissionItem.visible?setmissionItem.bottom:parent.top
                anchors.topMargin:      setmissionItem.visible?ScreenTools.defaultFontPixelWidth:ScreenTools.toolbarHeight*1.8 + ScreenTools.defaultFontPixelWidth
                anchors.right:          parent.right
                anchors.rightMargin:    ScreenTools.defaultFontPixelHeight+_rightPanelWidth
                z:                      QGroundControl.zOrderTopMost
            }

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
                    onClicked:  {
                        _addWaypointOnClick = checked
                        ruler.checked=false
                    }
                }
                Rectangle {
                    height:     parent.height*0.8
                    width:      1
                    color:      "grey"
                }
                DropButton {
                    id:             setMissionItemsButton
                    buttonImage:    "/qmlimages/relwaypoint.svg"
                    lightBorders:   _lightWidgetBorders
                    dropDirection:  dropDown
                    exclusiveGroup: _dropButtonsExclusiveGroup
                    dropDownComponent: Component {
                        Column {
                            spacing: ScreenTools.defaultFontPixelWidth
                            SubMenuButton {
                                imageResource:      "/qmlimages/nextwaypoint.svg"
                                Layout.fillWidth:   true
                                text:               qsTr("相对航点")//"Send to vehicle"
                                onClicked:  {
                                    setMissionItemsButton.hideDropDown()
                                    setmissionItem.visible=true//qgcView.showDialog(setmissionItemDialog, qsTr(""), qgcView.showDialogDefaultWidth*0.6, StandardButton.Cancel)
                                }
                            }
                            SubMenuButton {
                                imageResource:      "/qmlimages/circlepoint.svg"
                                Layout.fillWidth:   true
                                text:               qsTr("圆形航线")//"Send to vehicle"
                                onClicked:  {
                                    setMissionItemsButton.hideDropDown()
                                    setCircleItem.visible=true
                                    //qgcView.showDialog(setCircleItemDialog, qsTr(""), qgcView.showDialogDefaultWidth*0.6, StandardButton.Cancel)
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
                DropButton{//DropButton
                    id:                 addShapeButton
                    dropDirection:      dropDown
                    buttonImage:        "/qmlimages/MapDrawShape.svg"
                    lightBorders:       _lightWidgetBorders
                    visible:            _editingLayer == _layerMission
                    exclusiveGroup:     _dropButtonsExclusiveGroup
                    dropDownComponent:  patternDropPanel
          /*
                    onClicked: {
                        var coordinate = editorMap.center
                        coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
                        coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
                        coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)
                        var sequenceNumber = missionController.insertComplexMissionItem("Survey", coordinate, missionController.visualItems.count)
                        setCurrentItem(sequenceNumber)
                        checked = false
                        addMissionItemsButton.checked = false
                        _addWaypointOnClick = false
                    }
          */
                }
                Rectangle {
                    height:     parent.height*0.8
                    width:      1
                    color:      "grey"
                }
                DropButton {
                    id:                 syncButton
                    dropDirection:      dropDown
                    exclusiveGroup:    _dropButtonsExclusiveGroup
                    buttonImage:      "/qmlimages/MapSync.svg"//_syncDropDownController.dirty ? "/qmlimages/MapSyncChanged.svg" : "/qmlimages/MapSync.svg"
                    imgcolor:           masterController.dirty ? "red":"White"
                    viewportMargins:    ScreenTools.defaultFontPixelWidth / 2
                    dropDownComponent:  syncDropPanel//syncDropDownComponent
                    enabled:            !masterController.syncInProgress
                    rotateImage:        masterController.syncInProgress
                    lightBorders:       _lightWidgetBorders
                }
                Rectangle {
                    height:     parent.height*0.8
                    width:      1
                    color:      "grey"
                }
                DropButton {
                    id:             dropPanel
                    buttonImage:    "/qmlimages/MapCenter.svg"
                    lightBorders:   _lightWidgetBorders
                    dropDirection:  dropDown
                    dropDownComponent: centerMapDropPanel
                    exclusiveGroup:    _dropButtonsExclusiveGroup
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
                    lightBorders:       _lightWidgetBorders
                    exclusiveGroup:    _dropButtonsExclusiveGroup
                    dropDownComponent: Component {
                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth
                            Repeater {
                                id:   mapTypes
                                model: _mapType.enumValues
                                RoundImageButton {
                                    width:          ScreenTools.defaultFontPixelHeight*3
                                    height:         width
                                    exclusiveGroup: _mapTypeButtonsExclusiveGroup
                                    checked:        _mapType.value == _mapType.enumValues[index]
                                    imageResource:  index==0?"/qmlimages/map_street.svg":index==1?"/qmlimages/map_gps.svg" :"/qmlimages/map_terrain.svg"
                                    bordercolor:    qgcPal.buttonHighlight
                                    showcheckcolor: true
                                    onClicked: {
                                        _mapType.value = _mapType.enumValues[index]
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
                RoundButton {
                    id:             ruler
                    buttonImage:    "/qmlimages/ruler.svg"
                    lightBorders:   _lightWidgetBorders
                    onClicked:  {
                        addMissionItemsButton.checked = false
                        _addWaypointOnClick = false
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
                    lightBorders:       _lightWidgetBorders
                    exclusiveGroup:     _dropButtonsExclusiveGroup
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
                    visible:            !ScreenTools.isTinyScreen && !ScreenTools.isShortScreen
                    buttonImage:        "/qmlimages/ZoomMinus.svg"
                    lightBorders:       _lightWidgetBorders
                    exclusiveGroup:     _dropButtonsExclusiveGroup
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
            QGCLabel {
                anchors.topMargin:    ScreenTools.defaultFontPixelHeight
                anchors.top:          toolColumn.bottom
                anchors.horizontalCenter:   toolColumn.horizontalCenter
                visible:            ruler.checked
                text:               "距离:"+coordinateruler1.distanceTo(coordinateruler2).toFixed(1)+"m 角度:"+Math.round(coordinateruler1.azimuthTo(coordinateruler2))
                color:              qgcPal.warningText
            }
        } // FlightMap

        // Right pane for mission editing controls
        Rectangle {
            id:                 rightPanel
            anchors.bottom:     parent.bottom
            anchors.right:      parent.right
            height:             ScreenTools.availableHeight
            width:              _rightPanelWidth
            color:              qgcPal.window
            opacity:            0
        }

        Item {
            anchors.fill:   rightPanel

            // Plan Element selector (Mission/Fence/Rally)
            Row {
                id:                 planElementSelectorRow
                anchors.topMargin:  Math.round(ScreenTools.defaultFontPixelHeight / 3)
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.right
                spacing:            _horizontalMargin
                visible:            QGroundControl.corePlugin.options.enablePlanViewSelector

                readonly property real _buttonRadius: ScreenTools.defaultFontPixelHeight * 0.75

                ExclusiveGroup {
                    id: planElementSelectorGroup
                    onCurrentChanged: {
                        switch (current) {
                        case planElementMission:
                            _editingLayer = _layerMission
                            break
                        case planElementGeoFence:
                            _editingLayer = _layerGeoFence
                            break
                        case planElementRallyPoints:
                            _editingLayer = _layerRallyPoints
                            break
                        }
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

            MissionAllItemIndicator {
                id:              allIndicator
                anchors.right:   parent.right
                anchors.top:     parent.top
                anchors.rightMargin: _margin*2
                width:               _rightPanelWidth
                missionController:   _missionController
                visible:       _editingLayer == _layerMission
                z:              QGroundControl.zOrderTopMost+1
            }
            Item {
                anchors.right:       parent.right
                anchors.top:         allIndicator.bottom
                anchors.topMargin:   _margin
                anchors.bottom:      parent.bottom
                anchors.bottomMargin:_PointFieldWidth+ScreenTools.defaultFontPixelWidth*2
                anchors.rightMargin: _margin
                width:               _rightPanelWidth-_margin
                z:                   QGroundControl.zOrderTopMost+1
                visible:             _editingLayer == _layerMission

                QGCListView {
                    id:             indexIndicatorListView
                    anchors.fill:    parent
                    orientation:    ListView.Vertical
                    model:          _missionController.visualItems
                    cacheBuffer:    Math.max(height * 2, 0)
                    clip:           true
                    currentIndex:   _currentMissionIndex
                    highlightMoveDuration: 250

                    delegate: MissionIndexIndicator {
                        map:                editorMap
                        masterController:   _planMasterController
                        missionItem:        object
                        readOnly:           false
                        visible:            object.isCurrentItem
                        rootQgcView:        _qgcView
                        onRemove: {
                            var removeIndex = index
                            _missionController.removeMissionItem(removeIndex)
                            if (removeIndex >= _missionController.visualItems.count) {
                                removeIndex--
                            }
                            _currentMissionIndex = -1
                            rootQgcView.setCurrentItem(removeIndex, true)
                        }

                        onInsert: {
                            var coordinate =object.coordinate
                            var sequenceNumber = _missionController.insertSimpleMissionItem(coordinate.atDistanceAndAzimuth(4*Math.pow(2,21-editorMap.zoomLevel),270), index)
                            setCurrentItem(object.sequenceNumber)
                        }
                    }
                }
            }
            // GeoFence Editor
            GeoFenceEditor {
                anchors.topMargin:      ScreenTools.defaultFontPixelHeight / 2
                anchors.top:            planElementSelectorRow.bottom
                anchors.left:           parent.left
                anchors.right:          parent.right
                availableHeight:        ScreenTools.availableHeight
                myGeoFenceController:   _geoFenceController
                flightMap:              editorMap
                visible:                _editingLayer == _layerGeoFence
            }

            // Rally Point Editor

            RallyPointEditorHeader {
                id:                 rallyPointHeader
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight / 2
                anchors.top:        planElementSelectorRow.bottom
                anchors.left:       parent.left
                anchors.right:      parent.right
                visible:            _editingLayer == _layerRallyPoints
                controller:         _rallyPointController
            }

            RallyPointItemEditor {
                id:                 rallyPointEditor
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight / 2
                anchors.top:        rallyPointHeader.bottom
                anchors.left:       parent.left
                anchors.right:      parent.right
                visible:            _editingLayer == _layerRallyPoints && _rallyPointController.points.count
                rallyPoint:         _rallyPointController.currentRallyPoint
                controller:         _rallyPointController
            }
        } // Right panel
/*
        MapScale {
            id:                 mapScale
            anchors.margins:    ScreenTools.defaultFontPixelHeight * (0.66)
            anchors.bottom:     waypointValuesDisplay.visible ? waypointValuesDisplay.top : parent.bottom
            anchors.left:       parent.left
            mapControl:         editorMap
            visible:            !ScreenTools.isTinyScreen
        }

        MissionItemStatus {
            id:                 waypointValuesDisplay
            anchors.margins:    ScreenTools.defaultFontPixelWidth
            anchors.left:       parent.left
            anchors.right:      rightPanel.left
            anchors.bottom:     parent.bottom
            missionItems:       _missionController.visualItems
            visible:            _editingLayer === _layerMission && !ScreenTools.isShortScreen
        }
*/
    } // QGCViewPanel
    Component {
        id: syncLoadFromVehicleOverwrite
        QGCViewMessage {
            id:         syncLoadFromVehicleCheck
            message:   qsTr("你有未保存或发送任务. 从飞机载入会丢失，确认载入?")
            function accept() {
                hideDialog()
                masterController.loadFromVehicle()
            }
        }
    }

    Component {
        id: syncLoadFromFileOverwrite
        QGCViewMessage {
            id:         syncLoadFromVehicleCheck
            message:   qsTr("你有未保存或发送任务. 从文件载入会丢失，确认载入?")
            function accept() {
                hideDialog()
                masterController.loadFromSelectedFile()
            }
        }
    }

    Component {
        id: removeAllPromptDialog
        QGCViewMessage {
            message: qsTr("确认删除所有航点?") +
                     (_planMasterController.offline ? "" : qsTr("This will also remove all items from the vehicle."))
            function accept() {
                if (_planMasterController.offline) {
                    masterController.removeAll()
                } else {
                    masterController.removeAllFromVehicle()
                }
                hideDialog()
            }
        }
    }

    //- ToolStrip DropPanel Components

    Component {
        id: centerMapDropPanel

        CenterMapDropPanel {
            map:            editorMap
            fitFunctions:   mapFitFunctions
        }
    }

    Component {
        id: patternDropPanel

        ColumnLayout {
            spacing:    ScreenTools.defaultFontPixelWidth * 0.5

//            QGCLabel { text: qsTr("Create complex pattern:") }

            Repeater {
                model: _missionController.complexMissionItemNames

                SubMenuButton {
                    imageResource:      "/qmlimages/MapDrawShape.svg"
                    text:               modelData
                    Layout.fillWidth:   true

                    onClicked: {
                        addComplexItem(modelData)
                        addShapeButton.hideDropDown()
                        ruler.checked=false
                    }
                }
            }
        } // Column
    }

    Component {
        id: syncDropPanel

        Column {
            id:         columnHolder
            property string _overwriteText: (_editingLayer == _layerMission) ? qsTr("覆盖任务")/*qsTr("Mission overwrite")*/ : qsTr("GeoFence overwrite")
            anchors.margins:    _margin

            SubMenuButton {
                imageResource:      "/qmlimages/sendvehicle.svg"
                visible:            masterController.offline && !masterController.syncInProgress
                Layout.fillWidth:   true
                text:               qsTr("生成任务")//"Send to vehicle"
                onClicked:  {
                    syncButton.hideDropDown()
                    _missionController.applyoffboardmission()
                }
            }
            SubMenuButton {
                imageResource:      "/qmlimages/sendvehicle.svg"
                enabled:             !masterController.offline && !masterController.syncInProgress
                Layout.fillWidth:   true
                text:               qsTr("发送任务..")//"Send to vehicle"
                onClicked:  {
                    syncButton.hideDropDown()
                    masterController.upload()
                }
            }
            Rectangle {
                height:     1
                width:      parent.width
                color:      "grey"
            }

            SubMenuButton {
                imageResource:      "/qmlimages/loadvehicle.svg"
                enabled:           !masterController.offline && !masterController.syncInProgress
                Layout.fillWidth:   true
                text:                qsTr("载入任务..")//"Load from vehicle"
                onClicked:  {
                    syncButton.hideDropDown()
                        if (masterController.dirty) {
                        _qgcView.showDialog(syncLoadFromVehicleOverwrite, columnHolder._overwriteText, qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                    } else {
                            masterController.loadFromVehicle()
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
                enabled:            !masterController.syncInProgress
                Layout.fillWidth:   true
                text:                qsTr("存储到文件")//"Save to file..."
                onClicked:  {
                    syncButton.hideDropDown()
                    masterController.saveToSelectedFile()
                }
            }
            Rectangle {
                height:     1
                width:      parent.width
                color:     "grey"
            }
            SubMenuButton {
                imageResource:      "/qmlimages/loadfromfile.svg"
                enabled:            !masterController.syncInProgress
                Layout.fillWidth:   true
                text:               qsTr("从文件载入")//"Load from file..."
                onClicked:  {
                    syncButton.hideDropDown()
                    if (masterController.dirty) {
                        _qgcView.showDialog(syncLoadFromFileOverwrite, columnHolder._overwriteText, qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                    } else {
                        masterController.loadFromSelectedFile()
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
                    _qgcView.showDialog(removeAllPromptDialog, qsTr("删除所有航点")/*qsTr("Remove all")*/, qgcView.showDialogDefaultWidth, StandardButton.Yes | StandardButton.No)
                }
            }
        }
    }
} // QGCVIew
