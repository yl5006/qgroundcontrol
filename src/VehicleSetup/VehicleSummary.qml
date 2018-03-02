﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0

Rectangle {
    id:             _summaryRoot
    anchors.fill:   parent
    anchors.rightMargin: ScreenTools.defaultFontPixelWidth
    anchors.leftMargin:  ScreenTools.defaultFontPixelWidth
    color:          qgcPal.window

    property real _minSummaryW:     ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelWidth * 28 : ScreenTools.defaultFontPixelWidth * 36
    property real _summaryBoxWidth: _minSummaryW
    property real _summaryBoxSpace: ScreenTools.defaultFontPixelWidth * 2

    function computeSummaryBoxSize() {
        var sw  = 0
        var rw  = 0
        var idx = Math.floor((_summaryRoot.width-ScreenTools.defaultFontPixelWidth * 8) / (_minSummaryW + ScreenTools.defaultFontPixelWidth))
        if(idx < 1) {
            _summaryBoxWidth = (_summaryRoot.width-ScreenTools.defaultFontPixelWidth * 8)
            _summaryBoxSpace = 0
        } else {
            _summaryBoxSpace = 0
            if(idx > 1) {
                _summaryBoxSpace = ScreenTools.defaultFontPixelWidth * 4
                sw = _summaryBoxSpace * (idx - 1)
            }
            rw = _summaryRoot.width-ScreenTools.defaultFontPixelWidth * 8 - sw
            _summaryBoxWidth = rw / idx
        }
    }

    function capitalizeWords(sentence) {
        return sentence.replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); });
    }

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  enabled
    }

    Component.onCompleted: {
        computeSummaryBoxSize()
    }

    onWidthChanged: {
        computeSummaryBoxSize()
    }

    QGCFlickable {
        clip:               true
        anchors.fill:       parent
        contentHeight:      summaryColumn.height
        contentWidth:       _summaryRoot.width
        flickableDirection: Flickable.VerticalFlick

        Column {
            id:             summaryColumn
            width:          _summaryRoot.width
            spacing:        ScreenTools.defaultFontPixelHeight

            QGCLabel {
                width:			parent.width
                wrapMode:		Text.WordWrap
                color:			setupComplete ? qgcPal.text : qgcPal.warningText
                font.family:    ScreenTools.demiboldFontFamily
                horizontalAlignment: Text.AlignHCenter
                text:           setupComplete ?qsTr("设置预览"):qsTr("警告:你的机体未设置完全，请设置标红的那些栏")
//                    qsTr("Below you will find a summary of the settings for your vehicle. To the left are the setup menus for each component.") :
//                   qsTr("WARNING: Your vehicle requires setup prior to flight. Please resolve the items marked in red using the menu on the left.")
                property bool setupComplete: QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.autopilot.setupComplete : false
            }

            Flow {
                id:         _flowCtl
                width:      _summaryRoot.width-ScreenTools.defaultFontPixelWidth*8
                spacing:    _summaryBoxSpace
                anchors.margins:    _summaryBoxSpace
                Repeater {
                    model: QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.autopilot.vehicleComponents : undefined

                    // Outer summary item rectangle
                    Rectangle {
                        width:      _summaryBoxWidth
                        height:     ScreenTools.defaultFontPixelHeight * 13
                        color:      qgcPal.windowShade
                        visible:    modelData.summaryQmlSource.toString() !== ""
//                        border.width: 1
//                        border.color: qgcPal.text
//                        Component.onCompleted: {
//                            border.color = Qt.rgba(border.color.r, border.color.g, border.color.b, 0.1)
//                        }

                        readonly property real titleHeight: ScreenTools.defaultFontPixelHeight * 2

                        // Title bar
                        QGCVariantButton {
                            id:     titleBar
                            width:  parent.width
                            height: titleHeight
                            text:   capitalizeWords(modelData.name)
                            bordercolor:  modelData.setupComplete ? Qt.rgba(0.0627, 0.9216, 0.749, 1)   :Qt.rgba(0.8941, 0.2275, 0.2392, 1)
                            startcolor:   modelData.setupComplete ? Qt.rgba(0.0627, 0.9216, 0.749, 0)   :Qt.rgba(0.8941, 0.2275, 0.2392, 0)
                            middlecolor:  modelData.setupComplete ? Qt.rgba(0.0627, 0.9216, 0.749, 0.35):Qt.rgba(0.8941, 0.2275, 0.2392, 0.35)
                            stopcolor:    modelData.setupComplete ? Qt.rgba(0.0627, 0.9216, 0.749, 0)   :Qt.rgba(0.8941, 0.2275, 0.2392, 0)
                            _showDotBorder: true
                            _showVerticalDotBorder: modelData.setupComplete ? false :true
                            _dottedAnimation:        modelData.setupComplete ? false :true
                            QGCColoredImage {
                                source:                 "/res/buttoncircle.svg"
                                anchors.leftMargin:    ScreenTools.defaultFontPixelWidth*2
                                anchors.left:          parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                width:                  ScreenTools.defaultFontPixelWidth * 1.75
                                height:                 width
                                radius:                 width / 2
                                color:                  modelData.setupComplete ? Qt.rgba(0.0627, 0.9216, 0.749, 1)   :Qt.rgba(0.8941, 0.2275, 0.2392, 1)
                                visible:                modelData.requiresSetup && modelData.setupSource !== ""
                            }

                            onClicked : {
                                console.log(modelData.setupSource)
                                if (modelData.setupSource !== "") {
                                    setupView.showVehicleComponentPanel(modelData)
                                }
                            }
                        }
                        // Summary Qml
                        Rectangle {
                            anchors.top:    titleBar.bottom
                            width:          parent.width-titleHeight
                            color:          qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter
                            height:         ScreenTools.defaultFontPixelHeight * 13-titleHeight
                            border.width: 1
                            border.color:  modelData.setupComplete ? Qt.rgba(0.0627, 0.9216, 0.749, 0.35)   :Qt.rgba(0.8941, 0.2275, 0.2392, 0.35)

                            Loader {
                                anchors.fill:       parent
                                anchors.margins:    ScreenTools.defaultFontPixelWidth
                                source:             modelData.summaryQmlSource
                            }
                        }
                    }
                }
            }
        }
    }
}
