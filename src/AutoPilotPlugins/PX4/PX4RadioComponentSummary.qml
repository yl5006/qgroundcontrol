import QtQuick 2.3
import QtQuick.Controls 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
FactPanel {
    id:             panel
    anchors.fill:   parent
    color:          qgcPal.windowShadeDark

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    FactPanelController { id: controller; factPanel: panel }

    property Fact mapRollFact:      controller.getParameterFact(-1, "RC_MAP_ROLL")
    property Fact mapPitchFact:     controller.getParameterFact(-1, "RC_MAP_PITCH")
    property Fact mapYawFact:       controller.getParameterFact(-1, "RC_MAP_YAW")
    property Fact mapThrottleFact:  controller.getParameterFact(-1, "RC_MAP_THROTTLE")
    property Fact mapFlapsFact:     controller.getParameterFact(-1, "RC_MAP_FLAPS")
    property Fact mapAux1Fact:      controller.getParameterFact(-1, "RC_MAP_AUX1")
    property Fact mapAux2Fact:      controller.getParameterFact(-1, "RC_MAP_AUX2")

    Column {
        anchors.fill:       parent
        spacing:            ScreenTools.defaultFontPointSize*0.5
        Row{
            //spacing:            ScreenTools.defaultFontPointSize*3
            width:              parent.width
            Column {
                spacing:            ScreenTools.defaultFontPointSize*0.5
                width:              parent.width*0.25
                QGCLabel {
                    id:     label
                    font.bold:   true
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:   qsTr("Roll:")
                    color:  qgcPal.buttonHighlight
                }
                QGCLabel {
                    font.bold:   true
                    anchors.horizontalCenter: label.horizontalCenter
                    text:   mapRollFact ? (mapRollFact.value === 0 ? qsTr("Setup required") : mapRollFact.valueString) : ""
                }
            }
            Column {
                spacing:            ScreenTools.defaultFontPointSize*0.5
                width:              parent.width*0.25
                QGCLabel {
                    id:     label1
                    font.bold:   true
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:   qsTr("Pitch:")//"Pitch:"
                    color:  qgcPal.buttonHighlight
                }
                QGCLabel {
                    font.bold:   true
                    anchors.horizontalCenter: label1.horizontalCenter
                    text:  mapPitchFact ? (mapPitchFact.value === 0 ? qsTr("Setup required")/*"Setup required"*/ : mapPitchFact.valueString) : ""
                }
            }
            Column {
                spacing:            ScreenTools.defaultFontPointSize*0.5
                width:              parent.width*0.25
                QGCLabel {
                    id:     label2
                    font.bold:   true
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:   qsTr("Yaw:")
                    color:  qgcPal.buttonHighlight
                }
                QGCLabel {
                    font.bold:   true
                    anchors.horizontalCenter: label2.horizontalCenter
                    text:   mapYawFact ? (mapYawFact.value === 0 ? qsTr("Setup required") : mapYawFact.valueString) : ""
                }
            }
            Column {
                spacing:            ScreenTools.defaultFontPointSize*0.5
                width:              parent.width*0.25
                QGCLabel {
                    id:     label3
                    font.bold:   true
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:   qsTr("Throttle:")
                    color:  qgcPal.buttonHighlight
                }
                QGCLabel {
                    font.bold:   true
                    anchors.horizontalCenter: label3.horizontalCenter
                    text:   mapThrottleFact ? (mapThrottleFact.value === 0 ? qsTr("Setup required") : mapThrottleFact.valueString) : ""
                }
            }
        }

        Rectangle {
            height:                 2
            width:                  parent.width
            color:                  qgcPal.buttonHighlight
        }
//        VehicleSummaryRow {
//            labelText: qsTr("横滚:")//"Roll:"
//            valueText: mapRollFact ? (mapRollFact.value === 0 ? qsTr("未设置")/*"Setup required"*/ : mapRollFact.valueString) : ""
//        }

//        VehicleSummaryRow {
//            labelText: qsTr("仰俯:")//"Pitch:"
//            valueText: mapPitchFact ? (mapPitchFact.value === 0 ? qsTr("未设置")/*"Setup required"*/ : mapPitchFact.valueString) : ""
//        }

//        VehicleSummaryRow {
//            labelText: qsTr("航角:")//"Yaw:"
//            valueText: mapYawFact ? (mapYawFact.value === 0 ? qsTr("未设置")/*"Setup required"*/ : mapYawFact.valueString) : ""
//        }

//        VehicleSummaryRow {
//            labelText: qsTr("油门:")//"Throttle:"
//            valueText: mapThrottleFact ? (mapThrottleFact.value === 0 ? qsTr("未设置")/*"Setup required"*/ : mapThrottleFact.valueString) : ""
//        }

        VehicleSummaryRow {
            labelText:  qsTr("Flaps")
            valueText:  mapFlapsFact ? (mapFlapsFact.value === 0 ? qsTr("Disabled") : mapFlapsFact.valueString) : ""
            visible:    !controller.vehicle.multiRotor
        }

        VehicleSummaryRow {
            labelText: qsTr("Aux1")
            valueText: mapAux1Fact ? (mapAux1Fact.value === 0 ? qsTr("Disabled") : mapAux1Fact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("Aux2")
            valueText: mapAux2Fact ? (mapAux2Fact.value === 0 ? qsTr("Disabled") : mapAux2Fact.valueString) : ""
        }
    }
}
