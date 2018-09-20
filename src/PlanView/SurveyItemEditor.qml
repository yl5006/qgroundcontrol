import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs  1.2
import QtQuick.Extras   1.4
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.FlightMap     1.0

Rectangle {
    id:         _root
    height:     visible ? (editorColumn.height + (_margin * 2)) : 0
    width:      availableWidth
    color:      qgcPal.windowShadeDark
    radius:     _margin/2

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property real   _margin:                    ScreenTools.defaultFontPixelWidth / 2
    property real   _fieldWidth:                ScreenTools.defaultFontPixelWidth * 10.5
    property var    _cameraList:        	[ qsTr("手动扫描参数"), qsTr("自定义相机参数") ]
    property var    _vehicle:                   QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle : QGroundControl.multiVehicleManager.offlineEditingVehicle
    property real   _cameraMinTriggerInterval:  missionItem.cameraCalc.minTriggerInterval.rawValue

    function polygonCaptureStarted() {
        missionItem.mapPolygon.clear()
    }

    function polygonCaptureFinished(coordinates) {
        for (var i=0; i<coordinates.length; i++) {
            missionItem.mapPolygon.appendVertex(coordinates[i])
        }
    }

    function polygonAdjustVertex(vertexIndex, vertexCoordinate) {
        missionItem.mapPolygon.adjustVertex(vertexIndex, vertexCoordinate)
    }

    function polygonAdjustStarted() { }
    function polygonAdjustFinished() { }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

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
            text:           qsTr("WARNING: Photo interval is below minimum interval (%1 secs) supported by camera.").arg(_cameraMinTriggerInterval.toFixed(1))
            wrapMode:       Text.WordWrap
            color:          qgcPal.warningText
            visible:        missionItem.cameraShots > 0 && _cameraMinTriggerInterval !== 0 && _cameraMinTriggerInterval > missionItem.timeBetweenShots
        }

        CameraCalc {
            cameraCalc:             missionItem.cameraCalc
            vehicleFlightIsFrontal: true
            distanceToSurfaceLabel: qsTr("高度")
            frontalDistanceLabel:   qsTr("触发距离")
            sideDistanceLabel:      qsTr("行间距")
        }

        SectionHeader {
            id:     transectsHeader
            text:   qsTr("飞行区域")
        }

        GridLayout {
            id:             transectsGrid
            anchors.left:   parent.left
            anchors.right:  parent.right
            columnSpacing:  _margin
            rowSpacing:     _margin
            columns:        2
            visible:        transectsHeader.checked

            QGCLabel { text: qsTr("角度") }
            FactTextField {
                fact:                   missionItem.gridAngle
                Layout.fillWidth:       true
                onUpdated:              angleSlider.value = missionItem.gridAngle.value
            }
            QGCSlider {
                id:                     angleSlider
                minimumValue:           0
                maximumValue:           359
                stepSize:               1
                tickmarksEnabled:       false
                Layout.fillWidth:       true
                Layout.columnSpan:      2
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                onValueChanged:         missionItem.gridAngle.value = value
                Component.onCompleted:  value = missionItem.gridAngle.value
                updateValueWhileDragging: true
            }

            QGCLabel { text: qsTr("转弯距离") }
            FactTextField {
                fact:               missionItem.turnAroundDistance
                Layout.fillWidth:   true
            }

            QGCButton {
                Layout.columnSpan:  2
                text:               qsTr("旋转起始点")
                onClicked:          missionItem.rotateEntryPoint();
            }

            FactCheckBox {
                text:               qsTr("悬停 拍照")
                fact:               missionItem.hoverAndCapture
                visible:            missionItem.hoverAndCaptureAllowed
                enabled:            !missionItem.followTerrain
                Layout.columnSpan:  2
                onClicked: {
                    if (checked) {
                        missionItem.cameraTriggerInTurnAround.rawValue = false
                    }
                }
            }

            FactCheckBox {
                text:               qsTr("转90度复飞")
                fact:               missionItem.refly90Degrees
                enabled:            !missionItem.followTerrain
                Layout.columnSpan:  2
            }

            FactCheckBox {
                text:               qsTr("任何地方都拍照")
                fact:               missionItem.cameraTriggerInTurnAround
                enabled:            missionItem.hoverAndCaptureAllowed ? !missionItem.hoverAndCapture.rawValue : true
                Layout.columnSpan:  2
            }

            FactCheckBox {
                text:               qsTr("交替飞行")
                fact:               missionItem.flyAlternateTransects
                visible:            _vehicle.fixedWing || _vehicle.vtol
                Layout.columnSpan:  2
            }

            QGCCheckBox {
                id:                 relAlt
                Layout.alignment:   Qt.AlignLeft
                text:               qsTr("参考高度")
                checked:            missionItem.cameraCalc.distanceToSurfaceRelative
                enabled:            missionItem.cameraCalc.isManualCamera && !missionItem.followTerrain
                visible:            QGroundControl.corePlugin.options.showMissionAbsoluteAltitude || (!missionItem.cameraCalc.distanceToSurfaceRelative && !missionItem.followTerrain)
                Layout.columnSpan:  2
                onClicked:          missionItem.cameraCalc.distanceToSurfaceRelative = checked

                Connections {
                    target: missionItem.cameraCalc
                    onDistanceToSurfaceRelativeChanged: relAlt.checked = missionItem.cameraCalc.distanceToSurfaceRelative
                }
            }
        }

        SectionHeader {
            id:         terrainHeader
            text:       qsTr("地形")
            checked:    missionItem.followTerrain
        }

        ColumnLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        terrainHeader.checked

            QGCCheckBox {
                id:         followsTerrainCheckBox
                text:       qsTr("无人机跟随地形")
                checked:    missionItem.followTerrain
                onClicked:  missionItem.followTerrain = checked
            }

            GridLayout {
                Layout.fillWidth:   true
                columnSpacing:      _margin
                rowSpacing:         _margin
                columns:            2
                visible:            followsTerrainCheckBox.checked

                QGCLabel { text: qsTr("公差") }
                FactTextField {
                    fact:               missionItem.terrainAdjustTolerance
                    Layout.fillWidth:   true
                }

                QGCLabel { text: qsTr("最大爬升率") }
                FactTextField {
                    fact:               missionItem.terrainAdjustMaxClimbRate
                    Layout.fillWidth:   true
                }

                QGCLabel { text: qsTr("最大下降率") }
                FactTextField {
                    fact:               missionItem.terrainAdjustMaxDescentRate
                    Layout.fillWidth:   true
                }
            }
        }

        SectionHeader {
            id:     statsHeader
            text:   qsTr("统计")
        }

        TransectStyleComplexItemStats { }
    } // Column
} // Rectangle
