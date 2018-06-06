import QtQuick 2.3
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

    property Fact   returnAltFact:      controller.getParameterFact(-1, "RTL_RETURN_ALT")
    property Fact   _descendAltFact:    controller.getParameterFact(-1, "RTL_DESCEND_ALT")
    property Fact   landDelayFact:      controller.getParameterFact(-1, "RTL_LAND_DELAY")
    property Fact   commRCLossFact:     controller.getParameterFact(-1, "COM_RC_LOSS_T")
    property Fact   lowBattAction:      controller.getParameterFact(-1, "COM_LOW_BAT_ACT")
    property Fact   rcLossAction:       controller.getParameterFact(-1, "NAV_RCL_ACT")
    property Fact   dataLossAction:     controller.getParameterFact(-1, "NAV_DLL_ACT")
    property Fact   _rtlLandDelayFact:  controller.getParameterFact(-1, "RTL_LAND_DELAY")
    property int    _rtlLandDelayValue: _rtlLandDelayFact.value

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("低电压保护")
            valueText: lowBattAction ? lowBattAction.enumStringValue : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("遥控丢失保护")
            valueText: rcLossAction ? rcLossAction.enumStringValue : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("遥控丢失时间")
            valueText: commRCLossFact ? commRCLossFact.valueString + " " + commRCLossFact.units : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("数据链丢失保护")
            valueText: dataLossAction ? dataLossAction.enumStringValue : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("返航高度")
            valueText: returnAltFact ? returnAltFact.valueString + " " + returnAltFact.units : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("返航后")
            valueText: _rtlLandDelayValue === 0 ?
                           qsTr("立即降落") :
                           (_rtlLandDelayValue < 0 ?
                                qsTr("悬停(盘旋)") :
                                qsTr("等待一定时间后降落"))

        }

        VehicleSummaryRow {
            labelText: qsTr("悬停高度")
            valueText: _descendAltFact.valueString + " " + _descendAltFact.units
            visible:    _rtlLandDelayValue !== 0
        }

        VehicleSummaryRow {
            labelText: qsTr("降落延时")
            valueText: _rtlLandDelayValue + " " + _rtlLandDelayFact.units
            visible:    _rtlLandDelayValue > 0
        }
    }
}
