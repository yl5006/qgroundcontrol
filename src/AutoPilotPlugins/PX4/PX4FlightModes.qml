/****************************************************************************
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
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

/// PX4 Flight Mode configuration. This control will load either the Simple or Advanced Flight Mode config
/// based on current parameter settings.
SetupPage {
    id:             flightModesPage
    pageComponent:  pageComponent
    visibleWhileArmed:   true
    Component {
        id: pageComponent
        Item {
            Rectangle {
                id:                         title
                anchors.top:                parent.top
                anchors.horizontalCenter:   parent.horizontalCenter
                width:                      parent.width
                height:                     ScreenTools.defaultFontPixelHeight*6
                color:                      "transparent"
                QGCCircleProgress{
                    id:                     circle
                    anchors.left:           parent.left
                    anchors.top:            parent.top
                    anchors.leftMargin:     ScreenTools.defaultFontPixelHeight*5
                    anchors.topMargin:      ScreenTools.defaultFontPixelHeight
                    width:                  ScreenTools.defaultFontPixelHeight*5
                    value:                  0
                }
                QGCColoredImage {
                    id:                     img
                    height:                 ScreenTools.defaultFontPixelHeight*2.5
                    width:                  height
                    sourceSize.width: width
                    source:     "/qmlimages/FlightModesComponentIcon.svg"
                    fillMode:   Image.PreserveAspectFit
                    color:      qgcPal.text
                    anchors.horizontalCenter:circle.horizontalCenter
                    anchors.verticalCenter: circle.verticalCenter
                }
                QGCLabel {
                    id:             idset
                    anchors.left:   img.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("飞行模式")//"sensors"
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold:              true
                    color:          qgcPal.text
                    anchors.verticalCenter: img.verticalCenter
                }
                Image {
                    source:    "/qmlimages/title.svg"
                    width:      idset.width+ScreenTools.defaultFontPixelHeight*4
                    height:     ScreenTools.defaultFontPixelHeight*3
                    anchors.verticalCenter: circle.verticalCenter
                    anchors.left:          circle.right
                    //                fillMode: Image.PreserveAspectFit
                }
            }
            Loader {
                anchors.top: title.bottom
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                anchors.left:       parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelHeight*6
                width:  availableWidth-ScreenTools.defaultFontPixelHeight*6
                height: availableHeight-ScreenTools.defaultFontPixelHeight*6
           //     source: _simpleMode ? "qrc:/qml/PX4SimpleFlightModes.qml" : "qrc:/qml/PX4AdvancedFlightModes.qml"
                source: "qrc:/qml/PX4SimpleFlightModes.qml"

                property Fact _nullFact
                property bool _rcMapFltmodeExists:  controller.parameterExists(-1, "RC_MAP_FLTMODE")
                property Fact _rcMapFltmode:        _rcMapFltmodeExists ? controller.getParameterFact(-1, "RC_MAP_FLTMODE") : _nullFact
                property Fact _rcMapModeSw:         controller.getParameterFact(-1, "RC_MAP_MODE_SW")
            //    property bool _simpleMode:          _rcMapFltmodeExists ? _rcMapFltmode.value > 0 || _rcMapModeSw.value == 0 : false

                FactPanelController {
                    id:         controller
                    factPanel:  flightModesPage.viewPanel
                }

                property var qgcView:       flightModesPage
                property var qgcViewPanel:  flightModesPage.viewPanel
            }
        }
    }
}
