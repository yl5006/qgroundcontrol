/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick              2.3
import QtQuick.Controls     1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

Column {
    /// ListModel must contains elements which look like this:
    ///     ListElement {
    ///         title:          "Roll sensitivity"
    ///         descriptionleft:    "Slide to the left to make roll control faster and more accurate. Slide to the right if roll oscillates or is too twitchy."
    ///         descriptionright:
    ///         param:          "MC_ROLL_TC"
    ///         min:            0
    ///         max:            100
    ///         step:           1
    ///     }
    property ListModel sliderModel

    property var qgcViewPanel

    property real _margins:         ScreenTools.defaultFontPixelHeight
    property bool _loadComplete:    false

    FactPanelController {
        id:         controller
        factPanel:  qgcViewPanel
    }

    QGCPalette { id: palette; colorGroupEnabled: enabled }

    Flow {
        id:                 sliderOuterColumn
        anchors.left:       parent.left
        anchors.right:      parent.right
        spacing:            _margins

        Repeater {
            id:     sliderRepeater
            model:  sliderModel

            Rectangle {
                id:                 sliderRect
                width:              Math.max(parent.width/2-_margins,ScreenTools.defaultFontPixelHeight*30)
                height:             sliderColumn.y + sliderColumn.height + _margins
                color:              "transparent"

                property alias sliderValue: slider.value
                Image {
                    anchors.fill:               parent
                    mipmap:                     true
                    source:                     "/qmlimages/safebackground.svg"
                }
                Image {
                    anchors.top:                    parent.top
                    anchors.left:                   parent.left
                    width:                          parent.width/2
                    height:                         ScreenTools.defaultFontPixelHeight*2.4
                    anchors.topMargin:              ScreenTools.defaultFontPixelHeight/2
                    mipmap:                         true
                    source:                         "/qmlimages/safetitlebg.svg"
                }
                Column {
                    id:                 sliderColumn
                    anchors.margins:    _margins
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        sliderRect.top
                    spacing:            _margins
                    QGCLabel {
                        text:           title
                        font.family:    ScreenTools.demiboldFontFamily
                        font.pointSize:                 ScreenTools.mediumFontPointSize
                        font.bold:       true
                    }

                    FactValueSlider {
                        digitCount:     fact.maxString.length
                        incrementSlots: 3
                        fact:           controller.getParameterFact(-1, param)
                    }
                    QGCLabel {
                        text:           descriptionleft
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                    }
                    QGCLabel {
                        text:           descriptionright
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                    }
                    GSSlider {
                        id:                 slider
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        minimumValue:       min
                        maximumValue:       max
                        stepSize:           isNaN(fact.increment) ? step : fact.increment
                        tickmarksEnabled:   true
                        activeFocusOnPress: true

                        property Fact fact: controller.getParameterFact(-1, param)

                        onValueChanged: {
                            if (_loadComplete) {
                                fact.value = value
                            }
                        }

                        // Block wheel events
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            onWheel: {
                                wheel.accepted = true
                            }
                        }
                    } // Slider
                } // Column
            } // Rectangle
        } // Repeater
    } // Column
} // QGCView
