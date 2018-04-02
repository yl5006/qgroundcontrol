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

// Editor for Survery mission items
Rectangle {
    id:         _root
    height:     visible ? (editorColumn.height + (_margin * 2)) : 0
    width:      availableWidth
    color:      qgcPal.windowShadeDark
    radius:     _radius

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property real   _margin:        ScreenTools.defaultFontPixelWidth / 2
    property real   _fieldWidth:    ScreenTools.defaultFontPixelWidth * 10.5
    property var    _vehicle:       QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle : QGroundControl.multiVehicleManager.offlineEditingVehicle

    function polygonCaptureStarted() {
        missionItem.clearPolygon()
    }

    function polygonCaptureFinished(coordinates) {
        for (var i=0; i<coordinates.length; i++) {
            missionItem.addPolygonCoordinate(coordinates[i])
        }
    }

    function polygonAdjustVertex(vertexIndex, vertexCoordinate) {
        missionItem.adjustPolygonCoordinate(vertexIndex, vertexCoordinate)
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
            text: "WIP: Careful!"
            color:  qgcPal.warningText
        }

        QGCLabel {
            anchors.left:   parent.left
            anchors.right:  parent.right
            text:           qsTr("注意: 相机最小拍照间隔 (%1 secs) .").arg(missionItem.cameraMinTriggerInterval.toFixed(1))
            wrapMode:       Text.WordWrap
            color:          qgcPal.warningText
            visible:        missionItem.cameraShots > 0 && missionItem.cameraMinTriggerInterval !== 0 && missionItem.cameraMinTriggerInterval > missionItem.timeBetweenShots
        }

        CameraCalc {
            cameraCalc:             missionItem.cameraCalc
            vehicleFlightIsFrontal: true
            distanceToSurfaceLabel: qsTr("高度")
            frontalDistanceLabel:   qsTr("触发距离")
            sideDistanceLabel:      qsTr("间距")
        }

        SectionHeader {
            id:     corridorHeader
            text:   qsTr("带状航线")
        }

        GridLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            columnSpacing:  _margin
            rowSpacing:     _margin
            columns:        2
            visible:        corridorHeader.checked

            QGCLabel { text: qsTr("宽") }
            FactTextField {
                fact:                   missionItem.corridorWidth
                Layout.fillWidth:       true
            }

            QGCLabel { text: qsTr("转弯距离") }
            FactTextField {
                fact:                   missionItem.turnAroundDistance
                Layout.fillWidth:       true
            }

            FactCheckBox {
                text:               qsTr("转弯时也拍照")
                fact:               missionItem.cameraTriggerInTurnAround
                enabled:            missionItem.hoverAndCaptureAllowed ? !missionItem.hoverAndCapture.rawValue : true
                Layout.columnSpan:  2
            }

            QGCCheckBox {
                id:                 relAlt
                anchors.left:       parent.left
                text:               qsTr("参考高度")
                checked:            missionItem.cameraCalc.distanceToSurfaceRelative
                enabled:            missionItem.cameraCalc.isManualCamera
                Layout.columnSpan:  2
                onClicked:          missionItem.cameraCalc.distanceToSurfaceRelative = checked

                Connections {
                    target: missionItem.cameraCalc
                    onDistanceToSurfaceRelativeChanged: relAlt.checked = missionItem.cameraCalc.distanceToSurfaceRelative
                }
            }
        }

        QGCButton {
            text:       qsTr("改变起始点")
            onClicked:  missionItem.rotateEntryPoint()
        }

        SectionHeader {
            id:         terrainHeader
            text:       qsTr("Terrain")
            checked:    false
        }

        ColumnLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        terrainHeader.checked

            QGCCheckBox {
                id:         followsTerrainCheckBox
                text:       qsTr("Vehicle follows terrain")
                checked:    missionItem.followTerrain
                onClicked:  missionItem.followTerrain = checked
            }

            GridLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                columnSpacing:  _margin
                rowSpacing:     _margin
                columns:        2
                visible:        followsTerrainCheckBox.checked

                QGCLabel {
                    text: "WIP: Careful!"
                    color:  qgcPal.warningText
                    Layout.columnSpan: 2
                }

                QGCLabel { text: qsTr("Tolerance") }
                FactTextField {
                    fact:               missionItem.terrainAdjustTolerance
                    Layout.fillWidth:   true
                }

                QGCLabel { text: qsTr("Max Climb Rate") }
                FactTextField {
                    fact:               missionItem.terrainAdjustMaxClimbRate
                    Layout.fillWidth:   true
                }

                QGCLabel { text: qsTr("Max Descent Rate") }
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

        Grid {
            columns:        2
            columnSpacing:  ScreenTools.defaultFontPixelWidth
            visible:        statsHeader.checked

            QGCLabel { text: qsTr("拍照数") }
            QGCLabel { text: missionItem.cameraShots }

            QGCLabel { text: qsTr("拍照间隔") }
            QGCLabel { text: missionItem.timeBetweenShots.toFixed(1) + " " + qsTr("secs") }
        }
    } // Column
} // Rectangle
