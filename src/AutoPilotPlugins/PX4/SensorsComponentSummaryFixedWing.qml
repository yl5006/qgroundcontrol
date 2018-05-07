﻿import QtQuick 2.3
import QtQuick.Controls 1.2

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

    property Fact mag0IdFact:           controller.getParameterFact(-1, "CAL_MAG0_ID")
    property Fact gyro0IdFact:          controller.getParameterFact(-1, "CAL_GYRO0_ID")
    property Fact accel0IdFact:         controller.getParameterFact(-1, "CAL_ACC0_ID")
    property Fact dpressOffFact:        controller.getParameterFact(-1, "SENS_DPRES_OFF")
    property Fact airspeedDisabledFact: controller.getParameterFact(-1, "FW_ARSP_MODE")
    property Fact airspeedBreakerFact:  controller.getParameterFact(-1, "CBRK_AIRSPD_CHK")

    property bool _airspeedVisible:     airspeedDisabledFact.value == 0 && airspeedBreakerFact.value !== 162128
    property bool _airspeedCalRequired: _airspeedVisible && dpressOffFact.value === 0

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("磁罗盘:")//qsTr("Compass:")
            valueText: mag0IdFact ? (mag0IdFact.value  === 0 ? qsTr("未校准")/*qsTr("Setup required")*/ :qsTr("已校准") /*qsTr("Ready")*/) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("角速度:")//qsTr("Gyro:")
            valueText: gyro0IdFact ? (gyro0IdFact.value === 0 ? qsTr("未校准")/*qsTr("Setup required") */: qsTr("已校准") /*qsTr("Ready")*/) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("加速度:")//qsTr("Accelerometer:")
            valueText: accel0IdFact ? (accel0IdFact.value === 0 ? qsTr("未校准")/*qsTr("Setup required")*/ : qsTr("已校准") /*qsTr("Ready")*/) : ""
        }

        VehicleSummaryRow {
            labelText:  qsTr("空速计:")//qsTr("Airspeed:")
            visible:    _airspeedVisible
            valueText: _airspeedCalRequired ? qsTr("未校准") : qsTr("已校准")
        }
    }
}
