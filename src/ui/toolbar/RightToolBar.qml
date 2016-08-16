﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/**
 * @file
 *   @brief QGC Main Tool Bar
 *   @author Gus Grubba <mavlink@grubba.com>
 */

import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0

Rectangle {
    id:         rightbar
    color:      Qt.rgba(0,0,0,0.5)
    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    property var  activeVehicle:        QGroundControl.multiVehicleManager.activeVehicle
    property var  mainWindow:           null


    readonly property var   colorGreen:     "#05f068"
    readonly property var   colorOrange:    "#f0ab06"
    readonly property var   colorRed:       "#fc4638"
    readonly property var   colorGrey:      "#7f7f7f"
    readonly property var   colorBlue:      "#636efe"
    readonly property var   colorWhite:     "#ffffff"

    signal showSetupView()
    signal showPlanView()
    signal showFlyView()

    MainToolBarController { id: _controller }

    function checkSettingsButton() {
        preferencesButton.checked = true
    }

    function checkSetupButton() {
        setupButton.checked = true
    }

    function checkPlanButton() {
        planButton.checked = true
    }

    function checkFlyButton() {
        flyButton.checked = true
    }

    Component.onCompleted: {
        //-- TODO: Get this from the actual state
        flyButton.checked = true
    }

    //---------------------------------------------
    // Right
    Column {
        id:                     viewRow
        spacing:                mainWindow.tbSpacing*2
        anchors.top:            parent.top
        anchors.left:           parent.left
        anchors.right:          parent.right
        anchors.bottom:         parent.bottom
        ExclusiveGroup { id: mainActionGroup }

        QGCToolBarButton {
            id:                 flyButton
            height:             mainWindow.tbButtonWidth
            anchors.left:        parent.left
            anchors.right:     parent.right
            exclusiveGroup:     mainActionGroup
            source:             "/qmlimages/PaperPlane.svg"
            onClicked:          rightbar.showFlyView()
        }

        QGCToolBarButton {
            id:                 planButton
            height:              mainWindow.tbButtonWidth
            anchors.left:        parent.left
            anchors.right:     parent.right
            exclusiveGroup:     mainActionGroup
            source:             "/qmlimages/Plan.svg"
            onClicked:          rightbar.showPlanView()
        }

        QGCToolBarButton {
            id:                 setupButton
            height:              mainWindow.tbButtonWidth
            anchors.left:        parent.left
            anchors.right:     parent.right
            exclusiveGroup:     mainActionGroup
            source:             "/qmlimages/Gears.svg"
            onClicked:          rightbar.showSetupView()
        }

    }
}
