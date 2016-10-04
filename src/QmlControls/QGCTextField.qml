﻿import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

TextField {
    id: root

    property bool showUnits: false
    property string unitsLabel: ""

    property bool showbg: true
    Component.onCompleted: {
        if (typeof qgcTextFieldforwardKeysTo !== 'undefined') {
            root.Keys.forwardTo = [qgcTextFieldforwardKeysTo]
        }
    }

    property var __qgcPal: QGCPalette { colorGroupEnabled: enabled }

    textColor:          showbg ? __qgcPal.textFieldText: " White"
    height:             Math.round(Math.max(25, ScreenTools.defaultFontPixelHeight * (ScreenTools.isMobile ? 2.5 : 1.2)))

    QGCLabel {
        id:             unitsLabelWidthGenerator
        text:           unitsLabel
        width:          contentWidth + parent.__contentHeight * 0.666
        visible:        false
        antialiasing:   true
    }

    style: TextFieldStyle {
        font.pointSize: ScreenTools.defaultFontPointSize
        background: Item {
            id: backgroundItem

//            Rectangle {
//                anchors.fill:           parent
//                anchors.bottomMargin:   -1
//                color:                   showbg ? " #44ffffff":"transparent"
//            }

            Rectangle {
                anchors.fill:           parent
                border.color:           control.activeFocus ? "#47b" : "transparent"//"#999"
                color:                  showbg ?__qgcPal.textField : "transparent"
            }

            Text {
                id: unitsLabel

                anchors.top:    parent.top
                anchors.bottom: parent.bottom

                verticalAlignment:  Text.AlignVCenter
                horizontalAlignment:Text.AlignHCenter

                x:              parent.width - width
                width:          unitsLabelWidthGenerator.width

                text:           control.unitsLabel
                font.pointSize: ScreenTools.defaultFontPointSize
                font.family:    ScreenTools.normalFontFamily
                antialiasing:   true

                color:          control.textColor
                visible:        control.showUnits
            }
        }

        padding.right: control.showUnits ? unitsLabelWidthGenerator.width : control.__contentHeight * 0.333
    }

    onActiveFocusChanged: {
        if (!ScreenTools.isMobile && activeFocus) {
            selectAll()
        }
    }
}
