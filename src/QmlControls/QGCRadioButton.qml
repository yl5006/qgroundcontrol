﻿import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

RadioButton {
    property var color:             qgcPal.text    ///< Text color
    property int textStyle:         Text.Normal
    property color textStyleColor:  qgcPal.text

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    style: RadioButtonStyle {
        indicator: Rectangle {
                implicitWidth:  16
                implicitHeight: 16
                radius: 9
                border.color: qgcPal.primaryButton
                border.width: 2
                color: "transparent"
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    visible: control.checked
                    color:  qgcPal.primaryButton
                    radius: width/2
                }
        }
        label: Item {
            implicitWidth:          text.implicitWidth + ScreenTools.defaultFontPixelWidth * 0.4
            implicitHeight:         text.implicitHeight
            baselineOffset:         text.y + text.baselineOffset

            Rectangle {
                anchors.fill:       text
                anchors.margins:    -1
                anchors.leftMargin: -3
                anchors.rightMargin:-3
                visible:            control.activeFocus
                height:             ScreenTools.defaultFontPixelWidth * 0.4
                radius:             height * 0.5
                color:              "#224f9fef"
                border.color:       "#47b"
                opacity:            0.6
            }

            Text {
                id:                 text
                text:               control.text
                font.pointSize:     ScreenTools.defaultFontPointSize
                font.family:        ScreenTools.normalFontFamily
                antialiasing:       true
                color:              control.color
                style:              control.textStyle
                styleColor:         control.textStyleColor
                anchors.centerIn:   parent
            }
        }
    }
}
