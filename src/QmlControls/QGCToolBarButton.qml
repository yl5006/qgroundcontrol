﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.3
import QtQuick.Controls 1.2

import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Item {
    id:     _root
    width:  height
    state:  "HelpShown"
    clip:   true

    property alias          source:         icon.source
    property bool           checked:        false
    property bool           primary:           true
    property ExclusiveGroup exclusiveGroup:  null
    property color          color:  "#ffffff"
    signal clicked()

    readonly property real _topBottomMargins: ScreenTools.defaultFontPixelHeight / 2

    onExclusiveGroupChanged: {
        if (exclusiveGroup) {
            exclusiveGroup.bindCheckable(_root)
        }
    }

    QGCPalette { id: qgcPal }

//    Rectangle {
//        anchors.fill:   parent
//        visible:        logo
//        color:          qgcPal.brandingPurple
//    }

    QGCColoredImage {
        id:                     icon
        anchors.left:           parent.left
        anchors.rightMargin:    _topBottomMargins*3
        anchors.right:          parent.right
        anchors.topMargin:      _topBottomMargins
        anchors.top:            parent.top
        anchors.bottomMargin:   _topBottomMargins
        anchors.bottom:         parent.bottom
        sourceSize.height:      parent.height
        fillMode:               Image.PreserveAspectFit
        color:                  (checked ?(primary ? qgcPal.primaryButton : qgcPal.buttonHighlight)  : qgcPal.buttonText)
    }

//    Rectangle {
//        anchors.left:   parent.left
//        anchors.right:  parent.right
//        anchors.bottom: parent.bottom
//        height:         _topBottomMargins * 0.25
//        visible:        checked
//        color:          (checked ? "#e4e428" : parent.color)
//    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            checked = true
            _root.clicked()
        }
    }
}
