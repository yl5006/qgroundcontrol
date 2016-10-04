/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.5
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtQuick.Controls.Private 1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Slider {
    property var _qgcPal: QGCPalette { colorGroupEnabled: enabled }
    style: SliderStyle {
        groove: Rectangle {
                implicitWidth: 200
                implicitHeight: 16
                color: _qgcPal.button
                Rectangle {
                    anchors.left: parent.left
                    width: styleData.handlePosition
                    height: parent.height
                    color: _qgcPal.buttonHighlight
                }
            }


        handle: Rectangle  {
            anchors.centerIn:   parent
            implicitWidth:      36
            implicitHeight:     36
            color:    "transparent"
            Image
            {
                source:             "/res/slidercenter.svg"
                fillMode:           Image.PreserveAspectFit
                anchors.fill:       parent
            }
        }
    }
}
