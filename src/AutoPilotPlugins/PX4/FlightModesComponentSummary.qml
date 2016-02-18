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

    property Fact modeSwFact:   controller.getParameterFact(-1, "RC_MAP_MODE_SW")
    property Fact posCtlSwFact: controller.getParameterFact(-1, "RC_MAP_POSCTL_SW")
    property Fact loiterSwFact: controller.getParameterFact(-1, "RC_MAP_LOITER_SW")
    property Fact returnSwFact: controller.getParameterFact(-1, "RC_MAP_RETURN_SW")

    Column {
        anchors.fill:       parent
        anchors.margins:    8

        VehicleSummaryRow {
            labelText: qsTr("模式切换开关")//"Mode switch:"
            valueText: modeSwFact ? (modeSwFact.value === 0 ? qsTr("未设置")/*"Setup required"*/ : modeSwFact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("位置控制开关")//"Position Ctl switch:"
            valueText: posCtlSwFact ? (posCtlSwFact.value === 0 ? qsTr("未使能")/*"Disabled"*/ : posCtlSwFact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("悬停开关")//"Loiter switch:"
            valueText: loiterSwFact ? (loiterSwFact.value === 0 ? qsTr("未使能")/*"Disabled"*/ : loiterSwFact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("返航开关")//"Return switch:"
            valueText: returnSwFact ? (returnSwFact.value === 0 ? qsTr("未使能")/*"Disabled"*/ : returnSwFact.valueString) : ""
        }
    }
}
