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
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0

// Editor for Fixed Wing Landing Pattern complex mission item
Rectangle {
    id:         _root
    height:     visible ? ((editorColumn.visible ? editorColumn.height : editorColumnNeedLandingPoint.height) + (_margin * 2)) : 0
    width:      availableWidth
    color:      qgcPal.windowShadeDark
    radius:     _radius

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property real _margin: ScreenTools.defaultFontPixelWidth / 2
    property real _spacer: ScreenTools.defaultFontPixelWidth / 2

    Column {
        id:                 editorColumn
        anchors.margins:    _margin
        anchors.left:       parent.left
        anchors.right:      parent.right
        spacing:            _margin
        visible:            missionItem.landingCoordSet

        SectionHeader {
            text: qsTr("盘旋点")
        }

        Item { width: 1; height: _spacer }

        FactTextFieldGrid {
            anchors.left:   parent.left
            anchors.right:  parent.right
            factList:       [ missionItem.loiterAltitude, missionItem.loiterRadius ]
            factLabels:     [ qsTr("Altitude"), qsTr("Radius") ]
        }

        Item { width: 1; height: _spacer }

        QGCCheckBox {
            id:             loiterAltRelative
            anchors.right:  parent.right
            text:           qsTr("高度参考Home点")
            checked:        missionItem.loiterAltitudeRelative
            onClicked:      missionItem.loiterAltitudeRelative = checked
        }

        Item { width: 1; height: _spacer }

        QGCCheckBox {
            anchors.left:   loiterAltRelative.left
            text:           qsTr("顺时针盘旋")
            checked:        missionItem.loiterClockwise
            onClicked:      missionItem.loiterClockwise = checked
        }

        SectionHeader { text: qsTr("降落点") }

        Item { width: 1; height: _spacer }

        GridLayout {
            anchors.left:    parent.left
            anchors.right:   parent.right
            columns:         2

                QGCLabel { text: qsTr("Heading") }

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.landingHeading
                }

                QGCLabel { text: qsTr("Altitude") }

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.landingAltitude
                }

            QGCRadioButton {
                id:                     useLandingDistance
                text:                   qsTr("Landing dist")
                checked:                !useFallRate.checked
                onClicked: {
                    useFallRate.checked = false
                    missionItem.fallRate.value = parseFloat(missionItem.loiterAltitude.value)*100/parseFloat (missionItem.landingDistance.value)
                }
                Layout.fillWidth:       true
            }

            FactTextField {
                fact:                   missionItem.landingDistance
                enabled:                useLandingDistance.checked
                Layout.fillWidth:       true
            }

            QGCRadioButton {
                id:                     useFallRate
                text:                   qsTr("Descent rate")
                checked:                !useLandingDistance.checked
                onClicked: {
                    useLandingDistance.checked = false
                    missionItem.landingDistance.value = parseFloat(missionItem.loiterAltitude.value)*100/parseFloat (missionItem.fallRate.value)
                }
                Layout.fillWidth:       true
            }

            FactTextField {
                fact:                   missionItem.fallRate
                enabled:                useFallRate.checked
                Layout.fillWidth:       true
            }

            Connections {
                target: missionItem.landingDistance

                onValueChanged: {
                    missionItem.fallRate.value = parseFloat(missionItem.loiterAltitude.value)*100/parseFloat (missionItem.landingDistance.value)
                }
            }

            Connections {
                target: missionItem.fallRate

                onValueChanged: {
                    missionItem.landingDistance.value = parseFloat(missionItem.loiterAltitude.value)*100/parseFloat (missionItem.fallRate.value)
                }
            }
        }

        Item { width: 1; height: _spacer }

        QGCCheckBox {
            anchors.right:  parent.right
            text:           qsTr("高度参考Home点")
            checked:        missionItem.landingAltitudeRelative
            onClicked:      missionItem.landingAltitudeRelative = checked
        }
    }

    Column {
        id:                 editorColumnNeedLandingPoint
        anchors.margins:    _margin
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        visible:            !missionItem.landingCoordSet
        spacing:            ScreenTools.defaultFontPixelHeight

        QGCLabel {
            anchors.left:   parent.left
            anchors.right:  parent.right
            wrapMode:       Text.WordWrap
            text:           qsTr("点击地图设置降落点")
        }
    }
}
