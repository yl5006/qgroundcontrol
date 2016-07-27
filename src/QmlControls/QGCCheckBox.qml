﻿import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

CheckBox {
    property var __qgcPal: QGCPalette { colorGroupEnabled: enabled }

    style: CheckBoxStyle {
        indicator: Item {
                     implicitWidth:  16
                     implicitHeight: 16
                     Rectangle {
                     anchors.fill: parent
                     radius: 2
                     border.color: "#2ebbd9"//control.__qgcPal.buttonHighlightText
                     border.width: 1
                     Rectangle {
                         visible: control.checked
                         color: "#2ebbd9"
                         radius: 1
                         anchors.margins: 4
                         anchors.fill: parent
                     }
                     }
        }
        label: Item {
            implicitWidth: text.implicitWidth + 2
            implicitHeight: text.implicitHeight
            baselineOffset: text.baselineOffset
            Rectangle {
                anchors.fill: text
                anchors.margins: -1
                anchors.leftMargin: -3
                anchors.rightMargin: -3
                visible: control.activeFocus
                height: 6
                radius: 3
                color: "#224f9fef"
                border.color: "#47b"
                opacity: 0.6
            }
            Text {
                id:             text
                text:           control.text
                antialiasing:   true
                font.pointSize: ScreenTools.defaultFontPointSize
                font.family:    ScreenTools.normalFontFamily
                color:          control.__qgcPal.text
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
