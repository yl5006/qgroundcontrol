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

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Switch {
    id: _root
    QGCPalette { id:qgcPal; colorGroupEnabled: true }
    style: SwitchStyle {
        groove:     Rectangle {
            implicitWidth:  ScreenTools.defaultFontPixelWidth * 4.5
            implicitHeight: ScreenTools.defaultFontPixelHeight
            color:          (control.checked && control.enabled) ? qgcPal.buttonHighlight : qgcPal.colorGrey
            radius:         ScreenTools.defaultFontPixelHeight/2
            border.color:   qgcPal.button
            border.width:   1
        }
        handle : Rectangle{
            implicitWidth:  ScreenTools.defaultFontPixelWidth * 2
            implicitHeight: ScreenTools.defaultFontPixelHeight
            radius:         ScreenTools.defaultFontPixelHeight/2
            border.color:   qgcPal.button
            border.width:   1
        }
    }
}
