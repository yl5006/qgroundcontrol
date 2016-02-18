import QtQuick 2.2
import QtQuick.Controls 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0

FactPanel {
    id:             panel
    anchors.fill:   parent
    color:          qgcPal.windowShadeDark

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    FactPanelController { id: controller; factPanel: panel }

    property Fact returnAltFact:    controller.getParameterFact(-1, "RTL_RETURN_ALT")
    property Fact descendAltFact:   controller.getParameterFact(-1, "RTL_DESCEND_ALT")
    property Fact landDelayFact:    controller.getParameterFact(-1, "RTL_LAND_DELAY")
    property Fact commDLLossFact:   controller.getParameterFact(-1, "COM_DL_LOSS_EN")
    property Fact commRCLossFact:   controller.getParameterFact(-1, "COM_RC_LOSS_T")

    Column {
        anchors.fill:       parent
        anchors.margins:    8

        VehicleSummaryRow {
            labelText: qsTr("返航最低高度")//"RTL min alt:"
            valueText: returnAltFact ? returnAltFact.valueString : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("返航home点高度")//"RTL home alt:"
            valueText: descendAltFact ? descendAltFact.valueString : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("返航悬停等待")//"RTL loiter delay:"
            valueText: landDelayFact ? (landDelayFact.value < 0 ? qsTr("未使能")/*"Disabled"*/ : landDelayFact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("数据链丢失返航")//"Telemetry loss RTL:"
            valueText: commDLLossFact ? (commDLLossFact.value != -1 ? qsTr("未使能")/*"Disabled"*/ : commDLLossFact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("遥控丢失时间返航")//"RC loss RTL (seconds):"
            valueText: commRCLossFact ? commRCLossFact.valueString : ""
        }
    }
}
