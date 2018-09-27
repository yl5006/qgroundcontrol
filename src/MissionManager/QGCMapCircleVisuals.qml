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
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightMap     1.0

/// QGCMapCircle map visuals
Item {
    id: _root

    property var    mapControl                                  ///< Map control to place item in
    property var    mapCircle                                   ///< QGCMapCircle object
    property bool   interactive:        mapCircle.interactive   /// true: user can manipulate polygon
    property color  interiorColor:      "transparent"
    property real   interiorOpacity:    1
    property int    borderWidth:        2
    property color  borderColor:        "orange"

    property real       _radius:        mapCircle.radius.rawValue
    property real   _circleRadius
    property bool   _editCircleRadius:          false
    property var    _circleComponent
    property var    _dragHandlesComponent

    function addVisuals() {
        if (!_circleComponent) {
            _circleComponent = circleComponent.createObject(mapControl)
            mapControl.addMapItem(_circleComponent)
        }
    }

    function removeVisuals() {
        if (_circleComponent) {
            _circleComponent.destroy()
            _circleComponent = undefined
        }
    }

    function addDragHandles() {
        if (!_dragHandlesComponent) {
            _dragHandlesComponent = dragHandlesComponent.createObject(mapControl)
        }
    }

    function removeDragHandles() {
        if (_dragHandlesComponent) {
            _dragHandlesComponent.destroy()
            _dragHandlesComponent = undefined
        }
    }

    function updateInternalComponents() {
        if (visible) {
            addVisuals()
            if (interactive) {
                addDragHandles()
            } else {
                removeDragHandles()
            }
        } else {
            removeVisuals()
            removeDragHandles()
        }
    }

    Component.onCompleted:  updateInternalComponents()
    onInteractiveChanged:   updateInternalComponents()
    onVisibleChanged:       updateInternalComponents()

    Component.onDestruction: {
        removeVisuals()
        removeDragHandles()
    }

    Component {
        id: circleComponent

        MapCircle {
            color:          interiorColor
            opacity:        interiorOpacity
            border.color:   borderColor
            border.width:   borderWidth
            center:         mapCircle.center
            radius:         mapCircle.radius.rawValue
        }
    }

    Menu {
        id: menu

        property int _removeVertexIndex

        function popUpWithIndex(curIndex) {
            _removeVertexIndex = curIndex
            menu.popup()
        }

        MenuItem {
            text:           qsTr("Set radius..." )
            onTriggered:    _editCircleRadius = true
        }

        MenuItem {
            text:           qsTr("Edit position..." )
            onTriggered:    {
                  qgcView.showDialog(editPositionDialog, qsTr("Edit position"), qgcView.showDialogDefaultWidth, StandardButton.Cancel)
            }
        }
    }

    Component {
        id: editPositionDialog
        EditPositionDialog {
            coordinate: mapCircle.center
            onCoordinateChanged:  mapCircle.center = coordinate
        }
    }
    Component {
        id: dragHandleComponent

        MapQuickItem {
            id:             mapQuickItem
            anchorPoint.x:  dragHandle.width / 2
            anchorPoint.y:  dragHandle.height / 2
            z:              QGroundControl.zOrderMapItems + 2

            sourceItem: Rectangle {
                id:         dragHandle
                width:      ScreenTools.defaultFontPixelHeight * 1.5
                height:     width
                radius:     width / 2
                color:      "white"
                opacity:    .90
            }
        }
    }

    Component {
        id: centerDragAreaComponent

        MissionItemIndicatorDrag {
            mapControl: _root.mapControl

            onItemCoordinateChanged: mapCircle.center = itemCoordinate

            onClicked: {
                menu.popUpWithIndex(0)
            }

            function setRadiusFromDialog() {
                mapCircle.radius.rawValue = Number(radiusField.text)
                _editCircleRadius = false
            }

            Rectangle {
                anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
                anchors.left:       parent.right
                width:              radiusColumn.width + ScreenTools.defaultFontPixelHeight
                height:             radiusColumn.height + ScreenTools.defaultFontPixelHeight
                color:              qgcPal.window
                border.color:       qgcPal.buttonHighlight
                visible:            _editCircleRadius

                Column {
                    id:                 radiusColumn
                    anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
                    anchors.left:       parent.left
                    anchors.top:        parent.top
                    spacing:            ScreenTools.defaultFontPixelHeight * 0.5

                    QGCLabel { text: qsTr("radius:") }

                    QGCTextField {
                        id:                 radiusField
                        text:               mapCircle.radius.rawValue.toFixed(2)
                        onEditingFinished:  setRadiusFromDialog()
                        inputMethodHints:   Qt.ImhFormattedNumbersOnly
                    }
                }

                QGCLabel {
                    anchors.right:  radiusColumn.right
                    anchors.top:    radiusColumn.top
                    text:           "X"

                    QGCMouseArea {
                        fillItem:   parent
                        onClicked:  setRadiusFromDialog()
                    }
                }
            }
        }

    }

    Component {
        id: radiusDragAreaComponent

        MissionItemIndicatorDrag {
            mapControl: _root.mapControl

            onItemCoordinateChanged: mapCircle.radius.rawValue = mapCircle.center.distanceTo(itemCoordinate)


            onClicked: {
                menu.popUpWithIndex(0)
            }
        }
    }

    Component {
        id: dragHandlesComponent

        Item {
            property var centerDragHandle
            property var centerDragArea
            property var radiusDragHandle
            property var radiusDragArea
            property var radiusDragCoord:       QtPositioning.coordinate()
            property var circleCenterCoord:     mapCircle.center
            property real circleRadius:         mapCircle.radius.rawValue

            function calcRadiusDragCoord() {
                radiusDragCoord = mapCircle.center.atDistanceAndAzimuth(circleRadius, 90)
            }

            onCircleCenterCoordChanged: calcRadiusDragCoord()
            onCircleRadiusChanged:      calcRadiusDragCoord()

            Component.onCompleted: {
                calcRadiusDragCoord()
                radiusDragHandle = dragHandleComponent.createObject(mapControl)
                radiusDragHandle.coordinate = Qt.binding(function() { return radiusDragCoord })
                mapControl.addMapItem(radiusDragHandle)
                radiusDragArea = radiusDragAreaComponent.createObject(mapControl, { "itemIndicator": radiusDragHandle, "itemCoordinate": radiusDragCoord })
                centerDragHandle = dragHandleComponent.createObject(mapControl)
                centerDragHandle.coordinate = Qt.binding(function() { return circleCenterCoord })
                mapControl.addMapItem(centerDragHandle)
                centerDragArea = centerDragAreaComponent.createObject(mapControl, { "itemIndicator": centerDragHandle, "itemCoordinate": circleCenterCoord })
            }

            Component.onDestruction: {
                centerDragHandle.destroy()
                centerDragArea.destroy()
                radiusDragHandle.destroy()
                radiusDragArea.destroy()
            }
        }
    }
}

