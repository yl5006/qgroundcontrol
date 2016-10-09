import QtQuick          2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0

// Editor for Survery mission items
Rectangle {
    id:         _root
    height:     visible ? (editorColumn.height + (_margin * 2)) : 0
    width:      availableWidth
//    color:      qgcPal.windowShadeDark
    color:   Qt.rgba(0.102,0.122,0.133,0.9)
    radius:     _radius

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property real   _margin:        ScreenTools.defaultFontPixelWidth / 2
    property int    _cameraIndex:   1

    readonly property int _gridTypeManual:          0
    readonly property int _gridTypeCustomCamera:    1
    readonly property int _gridTypeCamera:          2

    Component.onCompleted: {
        console.log("gridAltitude", _currentMissionItem.gridAltitude.value)
        console.log("gridAltitudeRelative", _currentMissionItem.gridAltitudeRelative)
        console.log("gridAngle", _currentMissionItem.gridAngle.value)
        console.log("gridSpacing", _currentMissionItem.gridSpacing.value)
        console.log("turnaroundDist", _currentMissionItem.turnaroundDist.value)
        console.log("cameraTrigger", _currentMissionItem.cameraTrigger)
        console.log("cameraTriggerDistance", _currentMissionItem.cameraTriggerDistance.value)
        console.log("groundResolution", _currentMissionItem.groundResolution.value)
        console.log("frontalOverlap", _currentMissionItem.frontalOverlap.value)
        console.log("sideOverlap", _currentMissionItem.sideOverlap.value)
        console.log("cameraSensorWidth", _currentMissionItem.cameraSensorWidth.value)
        console.log("cameraSensorHeight", _currentMissionItem.cameraSensorHeight.value)
        console.log("cameraResolutionWidth", _currentMissionItem.cameraResolutionWidth.value)
        console.log("cameraResolutionHeight", _currentMissionItem.cameraResolutionHeight.value)
        console.log("cameraFocalLength", _currentMissionItem.cameraFocalLength.value)
        console.log("fixedValueIsAltitude", _currentMissionItem.fixedValueIsAltitude)
        console.log("cameraOrientationLandscape", _currentMissionItem.cameraOrientationLandscape)
        console.log("manualGrid", _currentMissionItem.manualGrid)
        console.log("camera", _currentMissionItem.camera)
    }

    ListModel {
        id: cameraModelList

        Component.onCompleted: {
            cameraModelList.setProperty(_gridTypeCustomCamera, "sensorWidth", _currentMissionItem.cameraSensorWidth.rawValue)
            cameraModelList.setProperty(_gridTypeCustomCamera, "sensorHeight", _currentMissionItem.cameraSensorHeight.rawValue)
            cameraModelList.setProperty(_gridTypeCustomCamera, "imageWidth", _currentMissionItem.cameraResolutionWidth.rawValue)
            cameraModelList.setProperty(_gridTypeCustomCamera, "imageHeight", _currentMissionItem.cameraResolutionHeight.rawValue)
            cameraModelList.setProperty(_gridTypeCustomCamera, "focalLength", _currentMissionItem.cameraFocalLength.rawValue)
        }

        ListElement {
            text:           qsTr("Manual Grid (no camera specs)")
        }
        ListElement {
            text:           qsTr("Custom Camera Grid")
        }
        ListElement {
            text:           qsTr("Sony ILCE-QX1") //http://www.sony.co.uk/electronics/interchangeable-lens-cameras/ilce-qx1-body-kit/specifications
            sensorWidth:    23.2                  //http://www.sony.com/electronics/camera-lenses/sel16f28/specifications
            sensorHeight:   15.4
            imageWidth:     5456
            imageHeight:    3632
            focalLength:    16
        }
        ListElement {
            text:           qsTr("Canon S100 PowerShot")
            sensorWidth:    7.6
            sensorHeight:   5.7
            imageWidth:     4000
            imageHeight:    3000
            focalLength:    5.2
        }
        ListElement {
            text:           qsTr("Canon SX260 HS PowerShot")
            sensorWidth:    6.17
            sensorHeight:   4.55
            imageWidth:     4000
            imageHeight:    3000
            focalLength:    4.5
        }
        ListElement {
            text:           qsTr("Canon EOS-M 22mm")
            sensorWidth:    22.3
            sensorHeight:   14.9
            imageWidth:     5184
            imageHeight:    3456
            focalLength:    22
        }
        ListElement {
            text:           qsTr("Sony a6000 16mm") //http://www.sony.co.uk/electronics/interchangeable-lens-cameras/ilce-6000-body-kit#product_details_default
            sensorWidth:    23.5
            sensorHeight:   15.6
            imageWidth:     6000
            imageHeight:    4000
            focalLength:    16
        }
    }

    function recalcFromCameraValues() {
        var focalLength = _currentMissionItem.cameraFocalLength.rawValue
        var sensorWidth = _currentMissionItem.cameraSensorWidth.rawValue
        var sensorHeight = _currentMissionItem.cameraSensorHeight.rawValue
        var imageWidth = _currentMissionItem.cameraResolutionWidth.rawValue
        var imageHeight = _currentMissionItem.cameraResolutionHeight.rawValue

        var altitude = _currentMissionItem.gridAltitude.rawValue
        var groundResolution = _currentMissionItem.groundResolution.rawValue
        var frontalOverlap = _currentMissionItem.frontalOverlap.rawValue
        var sideOverlap = _currentMissionItem.sideOverlap.rawValue

        if (focalLength <= 0 || sensorWidth <= 0 || sensorHeight <= 0 || imageWidth <= 0 || imageHeight <= 0 || groundResolution <= 0) {
            return
        }

        var imageSizeSideGround     //size in side (non flying) direction of the image on the ground
        var imageSizeFrontGround    //size in front (flying) direction of the image on the ground
        var gridSpacing
        var cameraTriggerDistance

        if (_currentMissionItem.fixedValueIsAltitude) {
            groundResolution = (altitude * sensorWidth * 100) /  (imageWidth * focalLength)
        } else {
            altitude = (imageWidth * groundResolution * focalLength) / (sensorWidth * 100)
        }

        if (cameraOrientationLandscape.checked) {
            imageSizeSideGround = (imageWidth * groundResolution) / 100
            imageSizeFrontGround = (imageHeight * groundResolution) / 100
        } else {
            imageSizeSideGround = (imageHeight * groundResolution) / 100
            imageSizeFrontGround = (imageWidth * groundResolution) / 100
        }

        gridSpacing = imageSizeSideGround * ( (100-sideOverlap) / 100 )
        cameraTriggerDistance = imageSizeFrontGround * ( (100-frontalOverlap) / 100 )

        if (_currentMissionItem.fixedValueIsAltitude) {
            _currentMissionItem.groundResolution.rawValue = groundResolution
        } else {
            _currentMissionItem.gridAltitude.rawValue = altitude
        }
        _currentMissionItem.gridSpacing.rawValue = gridSpacing
        _currentMissionItem.cameraTriggerDistance.rawValue = cameraTriggerDistance
    }

    /*
    function recalcFromMissionValues() {
        var focalLength = missionItem.cameraFocalLength.rawValue
        var sensorWidth = _currentMissionItem.cameraSensorWidth.rawValue
        var sensorHeight = _currentMissionItem.cameraSensorHeight.rawValue
        var imageWidth = _currentMissionItem.cameraResolutionWidth.rawValue
        var imageHeight = _currentMissionItem.cameraResolutionHeight.rawValue

        var altitude = _currentMissionItem.gridAltitude.rawValue
        var gridSpacing = _currentMissionItem.gridSpacing.rawValue
        var cameraTriggerDistance = _currentMissionItem.cameraTriggerDistance.rawValue

        if (focalLength <= 0.0 || sensorWidth <= 0.0 || sensorHeight <= 0.0 || imageWidth < 0 || imageHeight < 0 || altitude < 0.0 || gridSpacing < 0.0 || cameraTriggerDistance < 0.0) {
            _currentMissionItem.groundResolution.rawValue = 0
            _currentMissionItem.sideOverlap = 0
            _currentMissionItem.frontalOverlap = 0
            return
        }

        var groundResolution
        var imageSizeSideGround     //size in side (non flying) direction of the image on the ground
        var imageSizeFrontGround    //size in front (flying) direction of the image on the ground

        groundResolution = (altitude * sensorWidth * 100) / (imageWidth * focalLength)

        if (cameraOrientationLandscape.checked) {
            imageSizeSideGround = (imageWidth * gsd) / 100
            imageSizeFrontGround = (imageHeight * gsd) / 100
        } else {
            imageSizeSideGround = (imageHeight * gsd) / 100
            imageSizeFrontGround = (imageWidth * gsd) / 100
        }

        var sideOverlap = (imageSizeSideGround == 0 ? 0 : 100 - (gridSpacing*100 / imageSizeSideGround))
        var frontOverlap = (imageSizeFrontGround == 0 ? 0 : 100 - (cameraTriggerDistance*100 / imageSizeFrontGround))

        _currentMissionItem.groundResolution.rawValue = groundResolution
        _currentMissionItem.sideOverlap.rawValue = sideOverlap
        _currentMissionItem.frontalOverlap.rawValue = frontOverlap
    }
    */

    function polygonCaptureStarted() {
        _currentMissionItem.clearPolygon()
    }

    function polygonCaptureFinished(coordinates) {
        for (var i=0; i<coordinates.length; i++) {
            _currentMissionItem.addPolygonCoordinate(coordinates[i])
        }
    }

    function polygonAdjustVertex(vertexIndex, vertexCoordinate) {
        _currentMissionItem.adjustPolygonCoordinate(vertexIndex, vertexCoordinate)
    }

    function polygonAdjustStarted() { }
    function polygonAdjustFinished() { }

    property bool _noCameraValueRecalc: false   ///< Prevents uneeded recalcs

    Connections {
        target: _currentMissionItem

        onCameraValueChanged: {
            if (gridTypeCombo.currentIndex >= _gridTypeCustomCamera && !_noCameraValueRecalc) {
                recalcFromCameraValues()
            }
        }
    }

    Connections {
        target: _currentMissionItem.gridAltitude

        onValueChanged: {
            if (gridTypeCombo.currentIndex >= _gridTypeCustomCamera && _currentMissionItem.fixedValueIsAltitude && !_noCameraValueRecalc) {
                recalcFromCameraValues()
            }
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    ExclusiveGroup {
        id: cameraOrientationGroup

        onCurrentChanged: {
            if (gridTypeCombo.currentIndex >= _gridTypeCustomCamera) {
                recalcFromCameraValues()
            }
        }
    }

    ExclusiveGroup { id: fixedValueGroup }

    Column {
        id:                 editorColumn
        anchors.margins:    _margin
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        spacing:            _margin

        QGCLabel {
            anchors.left:   parent.left
            anchors.right:  parent.right
            wrapMode:       Text.WordWrap
            font.pointSize: ScreenTools.smallFontPointSize
            text:           gridTypeCombo.currentIndex == 0 ?
                                qsTr("Create a flight path which covers a polygonal area by specifying all grid parameters.") :
                                qsTr("Create a flight path which fully covers a polygonal area using camera specifications.")
        }

        QGCLabel { text: qsTr("Camera:") }

        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            height:         1
            color:          qgcPal.text
        }

        QGCComboBox {
            id:             gridTypeCombo
            anchors.left:   parent.left
            anchors.right:  parent.right
            model:          cameraModelList
            currentIndex:   -1

            Component.onCompleted: {
                if (_currentMissionItem.manualGrid) {
                    gridTypeCombo.currentIndex = _gridTypeManual
                } else {
                    var index = gridTypeCombo.find(_currentMissionItem.camera)
                    if (index == -1) {
                        console.log("Couldn't find camera", _currentMissionItem.camera)
                        gridTypeCombo.currentIndex = _gridTypeManual
                    } else {
                        gridTypeCombo.currentIndex = index
                    }
                }
            }

            onActivated: {
                if (index == _gridTypeManual) {
                    _currentMissionItem.manualGrid = true
                } else {
                    _currentMissionItem.manualGrid = false
                    _currentMissionItem.camera = gridTypeCombo.textAt(index)
                    _noCameraValueRecalc = true
                    _currentMissionItem.cameraSensorWidth.rawValue = cameraModelList.get(index).sensorWidth
                    _currentMissionItem.cameraSensorHeight.rawValue = cameraModelList.get(index).sensorHeight
                    _currentMissionItem.cameraResolutionWidth.rawValue = cameraModelList.get(index).imageWidth
                    _currentMissionItem.cameraResolutionHeight.rawValue = cameraModelList.get(index).imageHeight
                    _currentMissionItem.cameraFocalLength.rawValue = cameraModelList.get(index).focalLength
                    _noCameraValueRecalc = false
                    recalcFromCameraValues()
                }
            }
        }

        // Camera based grid ui
        Column {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        gridTypeCombo.currentIndex != _gridTypeManual

            Row {
                spacing: _margin

                QGCRadioButton {
                    id:             cameraOrientationLandscape
                    width:          _editFieldWidth
                    text:           "Landscape"
                    checked:        true
                    exclusiveGroup: cameraOrientationGroup
                }

                QGCRadioButton {
                    id:             cameraOrientationPortrait
                    text:           "Portrait"
                    exclusiveGroup: cameraOrientationGroup
                }
            }

            Column {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin
                visible:        gridTypeCombo.currentIndex == _gridTypeCustomCamera

                GridLayout {
                    columns:        3
                    columnSpacing:  _margin
                    rowSpacing:     _margin

                    property real _fieldWidth: ScreenTools.defaultFontPixelWidth * 10

                    QGCLabel { }
                    QGCLabel { text: qsTr("Width") }
                    QGCLabel { text: qsTr("Height") }

                    QGCLabel { text: qsTr("Sensor:") }
                    FactTextField {
                        Layout.preferredWidth:  parent._fieldWidth
                        fact:                   _currentMissionItem.cameraSensorWidth
                    }
                    FactTextField {
                        Layout.preferredWidth:  parent._fieldWidth
                        fact:                   _currentMissionItem.cameraSensorHeight
                    }

                    QGCLabel { text: qsTr("Image:") }
                    FactTextField {
                        Layout.preferredWidth:  parent._fieldWidth
                        fact:                   _currentMissionItem.cameraResolutionWidth
                    }
                    FactTextField {
                        Layout.preferredWidth:  parent._fieldWidth
                        fact:                   _currentMissionItem.cameraResolutionHeight
                    }
                }

                FactTextFieldRow {
                    spacing: _margin
                    fact:       _currentMissionItem.cameraFocalLength
                }
            } // Column - custom camera

            QGCLabel { text: qsTr("Image Overlap") }

            Row {
                spacing:        _margin

                Item {
                    width:  ScreenTools.defaultFontPixelWidth * 2
                    height: 1
                }

                QGCLabel {
                    anchors.baseline:   frontalOverlapField.baseline
                    text:               qsTr("Frontal:")
                }

                FactTextField {
                    id:     frontalOverlapField
                    width:  ScreenTools.defaultFontPixelWidth * 7
                    fact:   _currentMissionItem.frontalOverlap
                }

                QGCLabel {
                    anchors.baseline:   frontalOverlapField.baseline
                    text:               qsTr("Side:")
                }

                FactTextField {
                    width:  frontalOverlapField.width
                    fact:   _currentMissionItem.sideOverlap
                }
            }

            QGCLabel { text: qsTr("Grid:") }

            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         1
                color:          qgcPal.text
            }

            FactTextFieldGrid {
                anchors.left:   parent.left
                anchors.right:  parent.right
                columnSpacing:  _margin
                rowSpacing:     _margin
                factList:       [ _currentMissionItem.gridAngle, _currentMissionItem.turnaroundDist ]
            }

            QGCLabel {
                anchors.left:   parent.left
                anchors.right:  parent.right
                wrapMode:       Text.WordWrap
                font.pointSize: ScreenTools.smallFontPointSize
                text:           qsTr("Which value would you like to keep constant as you adjust other settings:")
            }

            RowLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin

                QGCRadioButton {
                    id:                 fixedAltitudeRadio
                    anchors.baseline:   gridAltitudeField.baseline
                    text:               qsTr("Altitude:")
                    checked:            _currentMissionItem.fixedValueIsAltitude
                    exclusiveGroup:     fixedValueGroup
                    onClicked:          _currentMissionItem.fixedValueIsAltitude = true
                }

                FactTextField {
                    id:                 gridAltitudeField
                    Layout.fillWidth:   true
                    fact:               _currentMissionItem.gridAltitude
                    enabled:            fixedAltitudeRadio.checked
                }
            }

            RowLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin

                QGCRadioButton {
                    id:                 fixedGroundResolutionRadio
                    anchors.baseline:   groundResolutionField.baseline
                    text:               qsTr("Ground res:")
                    checked:            !_currentMissionItem.fixedValueIsAltitude
                    exclusiveGroup:     fixedValueGroup
                    onClicked:          _currentMissionItem.fixedValueIsAltitude = false
                }

                FactTextField {
                    id:                 groundResolutionField
                    Layout.fillWidth:   true
                    fact:               _currentMissionItem.groundResolution
                    enabled:            fixedGroundResolutionRadio.checked
                }
            }
        }

        // Manual grid ui
        Column {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        gridTypeCombo.currentIndex == _gridTypeManual

            QGCLabel { text: qsTr("Grid:") }

            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         1
                color:          qgcPal.text
            }

            FactTextFieldGrid {
                anchors.left:   parent.left
                anchors.right:  parent.right
                columnSpacing:  _margin
                rowSpacing:     _margin
                factList:       [ _currentMissionItem.gridAngle, _currentMissionItem.gridSpacing, _currentMissionItem.gridAltitude, _currentMissionItem.turnaroundDist ]
            }

            QGCCheckBox {
                anchors.left:   parent.left
                text:           qsTr("Relative altitude")
                checked:        _currentMissionItem.gridAltitudeRelative
                onClicked:      _currentMissionItem.gridAltitudeRelative = checked
            }

            QGCLabel { text: qsTr("Camera:") }

            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         1
                color:          qgcPal.text
            }

            RowLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin

                QGCCheckBox {
                    id:                 cameraTrigger
                    anchors.baseline:   cameraTriggerDistanceField.baseline
                    text:               qsTr("Trigger Distance:")
                    checked:            _currentMissionItem.cameraTrigger
                    onClicked:          _currentMissionItem.cameraTrigger = checked
                }

                FactTextField {
                    id:                 cameraTriggerDistanceField
                    Layout.fillWidth:   true
                    fact:               _currentMissionItem.cameraTriggerDistance
                    enabled:            _currentMissionItem.cameraTrigger
                }
            }
        }

        QGCLabel { text: qsTr("Polygon:") }

        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            height:         1
            color:          qgcPal.text
        }

        Row {
            spacing: ScreenTools.defaultFontPixelWidth

            QGCButton {
                text:       editorMap.polygonDraw.drawingPolygon ? qsTr("Finish Draw") : qsTr("Draw")
                visible:    !editorMap.polygonDraw.adjustingPolygon
                enabled:    ((editorMap.polygonDraw.drawingPolygon && editorMap.polygonDraw.polygonReady) || !editorMap.polygonDraw.drawingPolygon)

                onClicked: {
                    if (editorMap.polygonDraw.drawingPolygon) {
                        editorMap.polygonDraw.finishCapturePolygon()
                    } else {
                        editorMap.polygonDraw.startCapturePolygon(_root)
                    }
                }
            }

            QGCButton {
                text:       editorMap.polygonDraw.adjustingPolygon ? qsTr("Finish Adjust") : qsTr("Adjust")
                visible:    _currentMissionItem.polygonPath.length > 0 && !editorMap.polygonDraw.drawingPolygon

                onClicked: {
                    if (editorMap.polygonDraw.adjustingPolygon) {
                        editorMap.polygonDraw.finishAdjustPolygon()
                    } else {
                        editorMap.polygonDraw.startAdjustPolygon(_root, _currentMissionItem.polygonPath)
                    }
                }
            }
        }

        QGCLabel { text: qsTr("Statistics:") }

        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            height:         1
            color:          qgcPal.text
        }

        Grid {
            columns: 2
            spacing: ScreenTools.defaultFontPixelWidth

            QGCLabel { text: qsTr("Survey area:") }
            QGCLabel { text: QGroundControl.squareMetersToAppSettingsAreaUnits(_currentMissionItem.coveredArea).toFixed(2) + " " + QGroundControl.appSettingsAreaUnitsString }

            QGCLabel { text: qsTr("# shots:") }
            QGCLabel { text: _currentMissionItem.cameraShots }
        }
    }
}
