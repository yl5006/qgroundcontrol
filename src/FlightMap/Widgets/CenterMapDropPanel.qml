/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtPositioning    5.3

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0

ColumnLayout {
    id:         root
    spacing:    ScreenTools.defaultFontPixelWidth * 0.5

    property var    map
    property var    fitFunctions
    property bool   showMission:          true
    property bool   showAllItems:         true

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    QGCLabel { text: qsTr("地图中心:") }
    Row {
        spacing: ScreenTools.defaultFontPixelWidth*0.5
        RoundImageButton {
            width:          ScreenTools.defaultFontPixelHeight*3
            height:         width
            imageResource:  "/qmlimages/map_home.svg"
            bordercolor:    qgcPal.text
            onClicked: {
                dropPanel.hideDropDown()
                map.center = fitFunctions.fitHomePosition()
            }
        }
        Rectangle {
            anchors.verticalCenter:         parent.verticalCenter
            height:     parent.height*0.8
            width:      1
            color:      "grey"
        }
        RoundImageButton {
            width:          ScreenTools.defaultFontPixelHeight*3
            height:         width
            imageResource:  "/qmlimages/Plan.svg"
            bordercolor:    qgcPal.text
            onClicked: {
                dropPanel.hideDropDown()
                fitFunctions.fitMapViewportToMissionItems()
            }
        }

        Rectangle {
            anchors.verticalCenter:         parent.verticalCenter
            height:     parent.height*0.8
            width:      1
            color:      "grey"
            visible:        map.gcsPosition.isValid
        }
        RoundImageButton {
            width:          ScreenTools.defaultFontPixelHeight*3
            height:         width
            imageResource:  "/qmlimages/people.svg" //"Current Location"
            visible:        map.gcsPosition.isValid
            bordercolor:    qgcPal.text
            onClicked: {
                dropPanel.hideDropDown()
                map.center = map.gcsPosition
            }
        }

        Rectangle {
            anchors.verticalCenter:         parent.verticalCenter
            height:     parent.height*0.8
            width:      1
            color:      "grey"
            visible:        _activeVehicle && _activeVehicle.coordinate.isValid
        }

        RoundImageButton {
            width:          ScreenTools.defaultFontPixelHeight*3
            height:         width
            imageResource:  "/qmlimages/map_plane.svg"
            bordercolor:    qgcPal.text
            visible:        _activeVehicle && _activeVehicle.coordinate.isValid
            onClicked: {
                dropPanel.hideDropDown()
                map.center = activeVehicle.coordinate
            }
        }
    }

    QGCButton {
        text:               qsTr("All items")
        Layout.fillWidth:   true
        visible:            showAllItems

        onClicked: {
            dropPanel.hide()
            fitFunctions.fitMapViewportToAllItems()
        }
    }

    QGCButton {
        text:               qsTr("Home")
        Layout.fillWidth:   true

        onClicked: {
            dropPanel.hide()
            map.center = fitFunctions.fitHomePosition()
        }
    }

    QGCButton {
        text:               qsTr("Vehicle")
        Layout.fillWidth:   true
        enabled:            _activeVehicle && _activeVehicle.coordinate.isValid

        onClicked: {
            dropPanel.hide()
            map.center = activeVehicle.coordinate
        }
    }

    QGCButton {
        text:               qsTr("Current Location")
        Layout.fillWidth:   true
        enabled:            map.gcsPosition.isValid

        onClicked: {
            dropPanel.hide()
            map.center = map.gcsPosition
        }
    }

    QGCButton {
        text:               qsTr("Specified Location")
        Layout.fillWidth:   true

        onClicked: {
            dropPanel.hide()
            map.centerToSpecifiedLocation()
        }
    }
} // Column
