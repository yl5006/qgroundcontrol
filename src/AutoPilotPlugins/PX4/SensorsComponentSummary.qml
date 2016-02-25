﻿import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0

/*
    IMPORTANT NOTE: Any changes made here must also be made to SensorsComponentSummary.qml
*/

FactPanel {
    id:             panel
    anchors.fill:   parent
    color:          qgcPal.windowShadeDark

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    FactPanelController { id: controller; factPanel: panel }

    property Fact mag0IdFact:   controller.getParameterFact(-1, "CAL_MAG0_ID")
    property Fact mag1IdFact:   controller.getParameterFact(-1, "CAL_MAG1_ID")
    property Fact mag2IdFact:   controller.getParameterFact(-1, "CAL_MAG2_ID")
    property Fact gyro0IdFact:  controller.getParameterFact(-1, "CAL_GYRO0_ID")
    property Fact accel0IdFact: controller.getParameterFact(-1, "CAL_ACC0_ID")

    Column {
        anchors.fill:       parent
        anchors.margins:    8

        VehicleSummaryRow {
            labelText: qsTr("磁罗盘")//"Compass:"
            valueText: mag0IdFact ? (mag0IdFact.value === 0 ? qsTr("未设置")/*"Setup required"*/ : qsTr("已校准")/*"Ready"*/) : ""
        }

        VehicleSummaryRow {
            labelText:  qsTr("磁罗盘1")//"Compass 1:"
            visible:    mag1IdFact.value !== 0
            valueText:  qsTr("已校准")//"Ready"
        }

        VehicleSummaryRow {
            labelText:  qsTr("磁罗盘2")//"Compass 2:"
            visible:    mag2IdFact.value !== 0
            valueText:  qsTr("已校准")//"Ready"
        }

        VehicleSummaryRow {
            labelText: qsTr("角速度计")//"Gyro:"
            valueText: gyro0IdFact ? (gyro0IdFact.value === 0 ? qsTr("未设置")/*"Setup required"*/ : qsTr("已校准")/*"Ready"*/) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("加速度计")//"Accelerometer:"
            valueText: accel0IdFact ? (accel0IdFact.value === 0 ? qsTr("未设置")/*"Setup required"*/ : qsTr("已校准")/*"Ready"*/) : ""
        }
    }
}
