﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @brief Battery, propeller and magnetometer summary
///     @author Gus Grubba <mavlink@grubba.com>

import QtQuick 2.2
import QtQuick.Controls 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools           1.0
FactPanel {
    id:             panel
    anchors.fill:   parent
    color:          qgcPal.windowShadeDark

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    FactPanelController { id: controller; factPanel: panel }

    property Fact batVChargedFact:  controller.getParameterFact(-1, "BAT_V_CHARGED")
    property Fact batVEmptyFact:    controller.getParameterFact(-1, "BAT_V_EMPTY")
    property Fact batCellsFact:     controller.getParameterFact(-1, "BAT_N_CELLS")

    Column {
        anchors.fill:       parent
        Row{
            spacing:            ScreenTools.defaultFontPointSize*5
            Column {
                spacing:            ScreenTools.defaultFontPointSize*0.5
                QGCLabel {
                    id:     label
                    text:   qsTr("满电压")//"Battery Full:"
                    color:  qgcPal.buttonHighlight
                }
                QGCLabel {
                    anchors.horizontalCenter: label.horizontalCenter
                    text:   batVChargedFact ? batVChargedFact.valueString + " " + batVChargedFact.units : ""
                }
            }
            Column {
                spacing:            ScreenTools.defaultFontPointSize*0.5
                QGCLabel {
                    id:     label1
                    text:   qsTr("空电压")//"Battery Empty:"
                    color:  qgcPal.buttonHighlight
                }
                QGCLabel {
                    anchors.horizontalCenter: label1.horizontalCenter
                    text:  batVEmptyFact ? batVEmptyFact.valueString + " " + batVEmptyFact.units : ""
                }
            }
            Column {
                spacing:            ScreenTools.defaultFontPointSize*0.5
                QGCLabel {
                    id:     label2
                    text:   qsTr("电芯数")//"Number of Cells:"
                    color:  qgcPal.buttonHighlight
                }
                QGCLabel {
                    anchors.horizontalCenter: label2.horizontalCenter
                    text:   batCellsFact ? batCellsFact.valueString : ""
                }
            }
        }

//        VehicleSummaryRow {
//            labelText: qsTr("满电压")//"Battery Full:"
//            valueText: batVChargedFact ? batVChargedFact.valueString + " " + batVChargedFact.units : ""
//        }

//        VehicleSummaryRow {
//            labelText: qsTr("空电压")//"Battery Empty:"
//            valueText: batVEmptyFact ? batVEmptyFact.valueString + " " + batVEmptyFact.units : ""
//        }

//        VehicleSummaryRow {
//            labelText: qsTr("电芯数")//"Number of Cells:"
//            valueText: batCellsFact ? batCellsFact.valueString : ""
//        }
    }
}
