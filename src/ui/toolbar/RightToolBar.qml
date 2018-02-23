/****************************************************************************
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
    color:      "transparent"//Qt.rgba(0,0,0,0.5)
    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    property var  activeVehicle:        QGroundControl.multiVehicleManager.activeVehicle
    property var  mainWindow:           null

    property bool isMessageImportant:   activeVehicle ? !activeVehicle.messageTypeNormal && !activeVehicle.messageTypeWarning && !activeVehicle.messageTypeNone : false
    readonly property var   colorGreen:     "#05f068"
    readonly property var   colorOrange:    "#f0ab06"
    readonly property var   colorRed:       "#fc4638"
    readonly property var   colorGrey:      "#7f7f7f"
    readonly property var   colorBlue:      "#636efe"
    readonly property var   colorWhite:     "#ffffff"

    signal showSetupView()
    signal showPlanView()
    signal showFlyView()
    signal showAnalyzeView()

    //-------------------------------------------------------------------------
    function getMessageColor() {
        if (activeVehicle) {
            if (activeVehicle.messageTypeNone)
                return colorGrey
            if (activeVehicle.messageTypeNormal)
                return colorBlue;
            if (activeVehicle.messageTypeWarning)
                return colorOrange;
            if (activeVehicle.messageTypeError)
                return colorRed;
            // Cannot be so make make it obnoxious to show error
            console.log("Invalid vehicle message type")
            return "purple";
        }
        //-- It can only get here when closing (vehicle gone while window active)
        return "white";
    }

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
    function checkAnalyzeButton() {
        analyzeButton.checked = true
    }
    Component.onCompleted: {
        //-- TODO: Get this from the actual state
        flyButton.checked = true
    }

    Image{
        anchors.fill:   parent
        fillMode:       Image.PreserveAspectFit
        source:          "/qmlimages/sidebar.svg"
    }
    Image {
        id:         hide
        source:     (rightbar.state=="Shown")?"/qmlimages/hidebar.svg":"/qmlimages/showbar.svg"
        width:      mainWindow.tbHeight*0.4
        height:     width
        anchors.verticalCenter: rightbar.verticalCenter
        anchors.right:          rightbar.right
        fillMode: Image.PreserveAspectFit
        MouseArea {
            anchors.fill: parent
            onClicked: {
                rightbar.state = (rightbar.state=="Hidden")?"Shown":"Hidden"
            }
        }
    }
    //---------------------------------------------
    // Right
    Column {
        id:                     viewRow
        spacing:                mainWindow.tbSpacing
//        anchors.top:            parent.top
        anchors.left:           parent.left   
        anchors.right:          parent.right
//        anchors.bottom:         parent.bottom
        ExclusiveGroup { id: mainActionGroup }
        anchors.verticalCenter: parent.verticalCenter
        QGCToolBarButton {
            id:                 flyButton
            height:             mainWindow.tbButtonWidth
            anchors.left:       parent.left
            anchors.right:      parent.right
            exclusiveGroup:     mainActionGroup
            source:             "/qmlimages/PaperPlane.svg"
            onClicked:          rightbar.showFlyView()
        }

        QGCToolBarButton {
            id:                 planButton
            height:              mainWindow.tbButtonWidth
            anchors.left:        parent.left
            anchors.right:       parent.right
            exclusiveGroup:     mainActionGroup
            source:             "/qmlimages/Plan.svg"
            onClicked:          rightbar.showPlanView()
        }

        QGCToolBarButton {
            id:                 setupButton
            height:              mainWindow.tbButtonWidth
            anchors.left:        parent.left
            anchors.right:       parent.right
            exclusiveGroup:      mainActionGroup
            source:             "/qmlimages/Hamburger.svg"
            onClicked:          rightbar.showSetupView()
        }
        QGCToolBarButton {
            id:                  analyzeButton
            height:              mainWindow.tbButtonWidth
            anchors.left:        parent.left
            anchors.right:       parent.right
            exclusiveGroup:      mainActionGroup
            source:              "/qmlimages/Analyze.svg"
            visible:             false&&!ScreenTools.isMobile
            onClicked:           rightbar.showAnalyzeView()
        }
        //-------------------------------------------------------------------------
        //-- Message Indicator
        Item {
            id:         messages
            width:      mainWindow.tbButtonWidth
            height:     mainWindow.tbButtonWidth
            anchors.left:        parent.left
            anchors.right:       parent.right
            anchors.rightMargin:    ScreenTools.defaultFontPixelHeight/2*3
       //     visible:    activeVehicle && activeVehicle.messageCount
            Item {
                id:                 criticalMessage
                anchors.fill:       parent
                visible:            activeVehicle && activeVehicle.messageCount > 0 && isMessageImportant
                Image {
                    source:             "/qmlimages/Yield.svg"
                    height:             mainWindow.tbCellHeight
                    sourceSize.height:  height
                    fillMode:           Image.PreserveAspectFit
                    cache:              false
                    visible:            isMessageImportant
                    anchors.verticalCenter:   parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Item {
                anchors.fill:       parent
                visible:            !criticalMessage.visible
                QGCColoredImage {
                    id:         messageIcon
                    source:     "/qmlimages/Megaphone.svg"
                    height:     mainWindow.tbCellHeight
                    width:      height
                    sourceSize.height: height
                    fillMode:   Image.PreserveAspectFit
                    color:      getMessageColor()
                    anchors.verticalCenter:   parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mainWindow.showMessageArea()
                }
            }
        }

    }
}
