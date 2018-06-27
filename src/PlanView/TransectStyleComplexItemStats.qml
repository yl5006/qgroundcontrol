import QtQuick          2.3
import QtQuick.Controls 1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0

// Statistics section for TransectStyleComplexItems
Grid {
    // The following properties must be available up the hierarchy chain
    //property var    missionItem       ///< Mission Item for editor

    anchors.left:   parent.left
    anchors.right:  parent.right
    columns:        2
    columnSpacing:  ScreenTools.defaultFontPixelWidth
    visible:        statsHeader.checked

    QGCLabel { text: qsTr("扫描面积") }
    QGCLabel { text: QGroundControl.squareMetersToAppSettingsAreaUnits(missionItem.coveredArea).toFixed(2) + " " + QGroundControl.appSettingsAreaUnitsString }

    QGCLabel { text: qsTr("拍照数") }
    QGCLabel { text: missionItem.cameraShots }

    QGCLabel { text: qsTr("拍照间隔") }
    QGCLabel { text: missionItem.timeBetweenShots.toFixed(1) + " " + qsTr("s") }

    QGCLabel { text: qsTr("触发距离") }
    QGCLabel { text: missionItem.cameraCalc.adjustedFootprintFrontal.valueString + " " + missionItem.cameraCalc.adjustedFootprintFrontal.units }
}
