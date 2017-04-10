import QtQuick 2.3
import QtQuick.Controls 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools           1.0
FactPanel {
    id:                 panel
    anchors.fill:       parent
    color:              qgcPal.windowShadeDark

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    AirframeComponentController { id: controller; factPanel: panel }

    property Fact sysIdFact:        controller.getParameterFact(-1, "MAV_SYS_ID")
    property Fact sysAutoStartFact: controller.getParameterFact(-1, "SYS_AUTOSTART")

    property bool autoStartSet: sysAutoStartFact ? (sysAutoStartFact.value !== 0) : false

    Column {
        anchors.fill:       parent
        spacing:            ScreenTools.defaultFontPointSize*0.5
        VehicleSummaryRow {
            labelText: qsTr("系统ID")//"System ID:"
            valueText: sysIdFact ? sysIdFact.valueString : ""
        }
        VehicleSummaryRow {
            labelText: qsTr("飞机类型")//"Airframe type:"
            valueText: autoStartSet ? controller.currentAirframeType : "Setup required"
        }
        VehicleSummaryRow {
            labelText: qsTr("机体名称:")//"Vehicle:"
            valueText: autoStartSet ? controller.currentVehicleName : "Setup required"
        }
//   do not show
//        VehicleSummaryRow {
//            labelText: qsTr("Firmware Version:")
//            valueText: activeVehicle.firmwareMajorVersion == -1 ? qsTr("Unknown") : activeVehicle.firmwareMajorVersion + "." + activeVehicle.firmwareMinorVersion + "." + activeVehicle.firmwarePatchVersion + activeVehicle.firmwareVersionTypeString
//        }
    }
}
