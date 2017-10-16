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
import QtQuick.Dialogs  1.2
import QtPositioning    5.3

import QGroundControl                       1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controls              1.0
import QGroundControl.FlightDisplay         1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Controllers           1.0

import QGroundControl.FlightMap     1.0

/// Inner common QML for mainWindow
Item {
    id: mainWindow

    signal reallyClose

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    property real   availableWidth:     width   //add yaoling
    property real   tbHeight:           ScreenTools.isMobile ? (ScreenTools.isTinyScreen ? (mainWindow.width * 0.0666) : (mainWindow.width * 0.05)) : ScreenTools.defaultFontPixelHeight * 3
    property int    tbCellHeight:       tbHeight * 0.75
    property real   tbSpacing:          ScreenTools.isMobile ? width * 0.00824 : 9.54
    property real   tbButtonWidth:      tbCellHeight * 1.35
    property var    gcsPosition:        QtPositioning.coordinate()  // Starts as invalid coordinate
    property var    currentPopUp:       null
    property real   currentCenterX:     0
    property var    activeVehicle:      QGroundControl.multiVehicleManager.activeVehicle
    property string formatedMessage:    activeVehicle ? activeVehicle.formatedMessage : ""

    property var _viewList: [ settingsViewLoader, setupViewLoader, planViewLoader, flightView, analyzeViewLoader ]
    property bool vehicleConnectionLost: activeVehicle ? activeVehicle.connectionLost : false
    
    readonly property string _planViewSource:       "PlanView.qml"
    readonly property string _setupViewSource:      "SetupViewandAppsetting.qml"//"SetupView.qml"
    readonly property string _settingsViewSource:   "AppSettings.qml"
    readonly property string _analyzeViewSource:    "AnalyzeView.qml"

    onHeightChanged: {
        //-- We only deal with the available height if within the Fly or Plan view
        if(!setupViewLoader.visible) {
            ScreenTools.availableHeight = parent.height - toolBar.height
        }
    }

    function disableToolbar() {
        toolbarBlocker.enabled = true
    }

    function enableToolbar() {
        toolbarBlocker.enabled = false
    }

    function hideAllViews() {
        for (var i=0; i<_viewList.length; i++) {
            _viewList[i].visible = false
        }
        initMap.visible     = false
    }

    function showSettingsView() {
        mainWindow.enableToolbar()
        rootLoader.sourceComponent = null
        if(currentPopUp) {
            currentPopUp.close()
        }
        //-- In settings view, the full height is available. Set to 0 so it is ignored.
        ScreenTools.availableHeight = 0
        hideAllViews()
        if (settingsViewLoader.source != _settingsViewSource) {
            settingsViewLoader.source  = _settingsViewSource
        }
        initMap.visible           = false

        settingsViewLoader.visible  = true

        //	rightBar.checkSettingsButton()
        // toolBar.checkSettingsButton()
    }

    function showSetupView() {
        mainWindow.enableToolbar()
        rootLoader.sourceComponent = null
        if(currentPopUp) {
            currentPopUp.close()
        }
        //-- In setup view, the full height is available. Set to 0 so it is ignored.
        ScreenTools.availableHeight = 0
        hideAllViews()
        if (setupViewLoader.source  != _setupViewSource) {
            setupViewLoader.source  = _setupViewSource
        }
        initMap.visible          = true
        setupViewLoader.visible  = true
        rightBar.checkSetupButton()
        //	toolBar.checkSetupButton()
    }

    function showPlanView() {
        mainWindow.enableToolbar()
        rootLoader.sourceComponent = null
        if(currentPopUp) {
            currentPopUp.close()
        }
        if (planViewLoader.source   != _planViewSource) {
            planViewLoader.source   = _planViewSource
        }
        ScreenTools.availableHeight = parent.height - toolBar.height
        hideAllViews()
        planViewLoader.visible = true
        rightBar.checkPlanButton()
    }

    function showFlyView() {
        mainWindow.enableToolbar()
        rootLoader.sourceComponent = null
        if(currentPopUp) {
            currentPopUp.close()
        }
        ScreenTools.availableHeight = parent.height - toolBar.height
        hideAllViews()
        flightView.visible = true
        rightBar.checkFlyButton()
    }

    function showAnalyzeView() {
        mainWindow.enableToolbar()
        rootLoader.sourceComponent = null
        if(currentPopUp) {
            currentPopUp.close()
        }
        ScreenTools.availableHeight = 0
        if (analyzeViewLoader.source  != _analyzeViewSource) {
            analyzeViewLoader.source  = _analyzeViewSource
        }
        hideAllViews()
        analyzeViewLoader.visible = true
        rightBar.checkAnalyzeButton()
    }

    /// Start the process of closing QGroundControl. Prompts the user are needed.
    function attemptWindowClose() {
        unsavedMissionCloseDialog.check()
    }

    function finishCloseProcess() {
        QGroundControl.linkManager.shutdown()
        // The above shutdown causes a flurry of activity as the vehicle components are removed. This in turn
        // causes the Windows Version of Qt to crash if you allow the close event to be accepted. In order to prevent
        // the crash, we ignore the close event and setup a delayed timer to close the window after things settle down.
        if(ScreenTools.isWindows) {
            delayedWindowCloseTimer.start()
        } else {
            mainWindow.reallyClose()
        }
    }

    MessageDialog {
        id:                 unsavedMissionCloseDialog
        title:              qsTr("%1 close").arg(QGroundControl.appName)
        text:               qsTr("有未保存任务，关闭后会丢失，确认关闭?")//qsTr("You have a mission edit in progress which has not been saved/sent. If you close you will lose changes. Are you sure you want to close?")
        standardButtons:    StandardButton.Yes | StandardButton.No
        modality:           Qt.ApplicationModal
        visible:            false

        onYes: activeConnectionsCloseDialog.check()

        function check() {
            if (planViewLoader.item && planViewLoader.item.syncNeeded) {
                unsavedMissionCloseDialog.open()
            } else {
                activeConnectionsCloseDialog.check()
            }
        }
    }

    MessageDialog {
        id:                 activeConnectionsCloseDialog
        title:              qsTr("%1 close").arg(QGroundControl.appName)
        text:               qsTr("无人机仍在连接中， 关闭并断开连接?")//qsTr("There are still active connections to vehicles. Do you want to disconnect these before closing?")
        standardButtons:    StandardButton.Yes | StandardButton.Cancel
        modality:           Qt.ApplicationModal
        visible:            false
        onYes:              finishCloseProcess()

        function check() {
            if (QGroundControl.multiVehicleManager.activeVehicle) {
                activeConnectionsCloseDialog.open()
            } else {
                finishCloseProcess()
            }
        }
    }

    Timer {
        id:         delayedWindowCloseTimer
        interval:   1500
        running:    false
        repeat:     false

        onTriggered: {
            mainWindow.reallyClose()
        }
    }

    property var messageQueue: []

    function showMessage(message) {
        if(criticalMmessageArea.visible || QGroundControl.videoManager.fullScreen) {
            messageQueue.push(message)
        } else {
            criticalMessageText.append(message)
            criticalMmessageArea.visible = true
        }
    }

    //    function showMessage(message) {
    //        messageText.append(formatMessage(message))
    //    }
    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: #f95e5e; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: #f9b55e; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: #ffffff; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }

    //    onFormatedMessageChanged: {
    //        if(messageArea.visible) {
    //            messageText.append(formatMessage(formatedMessage))
    //            //-- Hack to scroll down
    //            messageFlick.flick(0,-500)
    //        }
    //    }

    function showMessageArea() {
        mainWindow.enableToolbar()
        rootLoader.sourceComponent = null
//        var currentlyVisible = messageArea.visible
//        if(currentPopUp) {
//            currentPopUp.close()
//        }
        criticalMmessageArea.visible = true
	        if(QGroundControl.multiVehicleManager.activeVehicleAvailable) {
            activeVehicle.resetMessages()
        }
/*
        if(!currentlyVisible) {
            if(QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                messageText.text = formatMessage(activeVehicle.formatedMessages)
                //-- Hack to scroll to last message
                for (var i = 0; i < activeVehicle.messageCount; i++)
                    messageFlick.flick(0,-5000)
                activeVehicle.resetMessages()
            } else {
                messageText.text = qsTr("No Messages")
            }
            currentPopUp = messageArea
            messageArea.visible = true
        }
*/
    }

    function showPopUp(dropItem, centerX) {
        mainWindow.enableToolbar()
        rootLoader.sourceComponent = null
        var oldIndicator = indicatorDropdown.sourceComponent
        if(currentPopUp) {
            currentPopUp.close()
        }
        if(oldIndicator !== dropItem) {
            //console.log(oldIndicator)
            //console.log(dropItem)
            indicatorDropdown.centerX = centerX
            indicatorDropdown.sourceComponent = dropItem
            indicatorDropdown.visible = true
            currentPopUp = indicatorDropdown
        }
    }

    //logo
    Rectangle {
        id:                 logo
        y:                  0
        width:              parent.width
        height:             tbHeight
        color:              qgcPal.windowShade
        z:                  QGroundControl.zOrderTopMost
        Image {
            source:"/qmlimages/logo.svg"
            height:     tbHeight*0.8
            width:      tbHeight*6*0.8
            mipmap:             true
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
        }
        NumberAnimation on y{
            id: myAn1
            to:  -tbHeight
            duration: 1000
            running: vehicleConnectionLost||(QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable && !QGroundControl.multiVehicleManager.activeVehicle.missingParameters)
        }
        NumberAnimation on y{
            id: myAn2
            to: 0
            duration: 1000
            running: activeVehicle && !vehicleConnectionLost ? false : true
        }
    }
    //-- Main UI

    MainTool {
        id:                 toolBar
        height:             ScreenTools.toolbarHeight * 1.8
        anchors.left:       parent.left
        mainWindow:         mainWindow
        anchors.right:      parent.right
        anchors.top:        logo.bottom
        z:                  QGroundControl.zOrderTopMost
        visible:            activeVehicle && !QGroundControl.videoManager.fullScreen
        Component.onCompleted:  ScreenTools.availableHeight = parent.height - toolBar.height
        MouseArea {
                   id:             toolbarBlocker
                   anchors.fill:   parent
                   enabled:        false
                   onWheel:        { wheel.accepted = true; }
                   onPressed:      { mouse.accepted = true; }
                   onReleased:     { mouse.accepted = true; }
       }
    }
    RightToolBar {
        id:                     rightBar
        width:                  mainWindow.tbHeight*2
        height:                 mainWindow.tbHeight*5
        mainWindow:             mainWindow
        anchors.left:           parent.left
        anchors.leftMargin:     _barMargin
        anchors.verticalCenter: parent.verticalCenter

        onShowSetupView:        mainWindow.showSetupView()
        onShowPlanView:         mainWindow.showPlanView()
        onShowFlyView:          mainWindow.showFlyView()
        onShowAnalyzeView:      mainWindow.showAnalyzeView()
        z:                      QGroundControl.zOrderTopMost
        state:                  "Init"
        property real   _barMargin:     0
        states: [
            State {
                name: "Shown"
                PropertyChanges { target: showAnimation; running: true  }
            },
            State {
                name: "Hidden"
                PropertyChanges { target: hideAnimation; running: true  }
            }
        ]
        NumberAnimation on _barMargin{
            id:             showAnimation
            duration:       150
            easing.type:    Easing.InOutQuad
            to:             0
        }
        NumberAnimation on _barMargin{
            id:             hideAnimation
            duration:       150
            easing.type:    Easing.InOutQuad
            to:             -mainWindow.tbHeight*1.6
        }

    }
/*
    PlanToolBar {
        id:                 planToolBar
        height:             ScreenTools.toolbarHeight
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        parent.top
        z:                  toolBar.z + 1

        onShowFlyView: {
            planToolBar.visible = false
            mainWindow.showFlyView()
        }
*/
    FlightMap {
        id:             initMap
        anchors.fill:   parent
        mapName:        "initmap"
        // Initial map position duplicates Fly view position
        Component.onCompleted: initMap.center = QGroundControl.flightMapPosition
    }


    Loader {
        id:                 settingsViewLoader
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        toolBar.bottom
        anchors.bottom:     parent.bottom
        visible:            false
/*
        onVisibleChanged: {
            if (!visible) {
                // Free up the memory for this when not shown. No need to persist.
                source = ""
            }
        }*/
    }

    Loader {
        id:                 setupViewLoader
        anchors.left:       parent.left
        anchors.leftMargin: mainWindow.tbHeight*2
        anchors.right:      parent.right
        anchors.top:        toolBar.visible?toolBar.bottom:logo.bottom
        anchors.bottom:     parent.bottom
        visible:            false

//      property var planToolBar: planToolBar
    }

    Loader {
        id:                 planViewLoader
        anchors.fill:       parent
        visible:            false

//      property var toolbar: planToolBar
    }

    FlightDisplayView {
        id:                 flightView
        anchors.fill:       parent
        visible:            true
        //-------------------------------------------------------------------------
        //-- Loader helper for any child, no matter how deep can display an element
        //   on top of the video window.
        Loader {
            id:             rootVideoLoader
            anchors.centerIn: parent
        }
    }

    Loader {
        id:                 analyzeViewLoader
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        toolBar.bottom
        anchors.bottom:     parent.bottom
        visible:            false
    }

    //-------------------------------------------------------------------------
    //-- Dismiss Pop Up Messages
    MouseArea {
        visible:        currentPopUp != null
        enabled:        currentPopUp != null
        anchors.fill:   parent
        onClicked: {
            currentPopUp.close()
        }
    }

    //-------------------------------------------------------------------------
    //-- Indicator Drop Down Info
    Loader {
        id: indicatorDropdown
        visible: false
        property real centerX: 0
        function close() {
            sourceComponent = null
            mainWindow.currentPopUp = null
        }
    }

    //-------------------------------------------------------------------------
    //-- System Message Area  do not show
    //        Rectangle {
    //            id:                 messageArea
    //            function close() {
    //                currentPopUp = null
    //                messageText.text    = ""
    //                messageArea.visible = false
    //            }
    //            width:              mainWindow.width  * 0.5
    //   	  height:             mainWindow.height * 0.5
    //            color:              Qt.rgba(0,0,0,0.8)
    //            visible:            false
    //            radius:             ScreenTools.defaultFontPixelHeight * 0.5
    //            border.color:       "#808080"
    //            border.width:       2
    //    	  anchors.horizontalCenter:   parent.horizontalCenter
    //            anchors.top:                parent.top
    //            anchors.topMargin:          toolBar.height + ScreenTools.defaultFontPixelHeight
    //            MouseArea {
    //                // This MouseArea prevents the Map below it from getting Mouse events. Without this
    //                // things like mousewheel will scroll the Flickable and then scroll the map as well.
    //                anchors.fill:       parent
    //                preventStealing:    true
    //                onWheel:            wheel.accepted = true
    //            }
    //            QGCFlickable {
    //                id:                 messageFlick
    //                anchors.margins:    ScreenTools.defaultFontPixelHeight
    //                anchors.fill:       parent
    //                contentHeight:      messageText.height
    //                contentWidth:       messageText.width
    //                pixelAligned:       true
    //                clip:               true
    //                TextEdit {
    //                    id:             messageText
    //                    readOnly:       true
    //                    textFormat:     TextEdit.RichText
    //                    color:          "white"
    //                }
    //            }

    //        //-- Dismiss System Message
    //        Image {
    //            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
    //            anchors.top:        parent.top
    //            anchors.right:      parent.right
    //            width:              ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
    //            height:             width
    //            sourceSize.height:  width
    //            source:             "/res/XDelete.svg"
    //            fillMode:           Image.PreserveAspectFit
    //            mipmap:             true
    //            smooth:             true
    //            MouseArea {
    //                anchors.fill:       parent
    //                anchors.margins:    ScreenTools.isMobile ? -ScreenTools.defaultFontPixelHeight : 0
    //                onClicked: {
    //                    messageArea.close()
    //                }
    //            }
    //        }
    //        //-- Clear Messages
    //        Image {
    //            anchors.bottom:     parent.bottom
    //            anchors.right:      parent.right
    //            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
    //            height:             ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
    //            width:              height
    //            sourceSize.height:   height
    //            source:             "/res/TrashDelete.svg"
    //            fillMode:           Image.PreserveAspectFit
    //            mipmap:             true
    //            smooth:             true
    //            MouseArea {
    //                anchors.fill:   parent
    //                onClicked: {
    //                    if(QGroundControl.multiVehicleManager.activeVehicleAvailable) {
    //                        activeVehicle.clearMessages();
    //                        messageArea.close()
    //                    }
    //                }
    //            }
    //        }
    //    }

    //-------------------------------------------------------------------------
    //-- Critical Message Area
    Rectangle {
        id:                         criticalMmessageArea
        width:                      mainWindow.width  * 0.685
        height:                     mainWindow.width  * 0.15
        color:                      "transparent"//#eecc44"
        visible:                    false
        radius:                     ScreenTools.defaultFontPixelHeight * 0.5
        //        anchors.horizontalCenter:   parent.horizontalCenter
        //        anchors.top:                parent.top
        //	  anchors.topMargin:          toolBar.height + ScreenTools.defaultFontPixelHeight / 2
        anchors.centerIn:           parent
        //border.color:               qgcPal.alertBorder
        //        border.width:               2

        readonly property real _textMargins: ScreenTools.defaultFontPixelHeight

        function close() {
            //-- Are there messages in the waiting queue?
            if(mainWindow.messageQueue.length) {
                criticalMessageText.text = ""
                //-- Show all messages in queue
                for (var i = 0; i < mainWindow.messageQueue.length; i++) {
                    var text = mainWindow.messageQueue[i]
                    criticalMessageText.append(text)
                }
                //-- Clear it
                mainWindow.messageQueue = []
            } else {
                criticalMessageText.text = ""
                criticalMmessageArea.visible = false
                if(QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                    activeVehicle.resetMessages()
                }
            }
        }

        Image {
            anchors.fill:       parent
            fillMode:           Image.PreserveAspectFit
            source:             "/res/criticalMessage.png"
            mipmap:             true
            smooth:             true
        }
        MouseArea {
            // This MouseArea prevents the Map below it from getting Mouse events. Without this
            // things like mousewheel will scroll the Flickable and then scroll the map as well.
            anchors.fill:       parent
            preventStealing:    true
            onWheel:            wheel.accepted = true
        }

        Flickable {
            id:                 criticalMessageFlick
            anchors.top:        parent.top
            anchors.topMargin:  ScreenTools.defaultFontPixelHeight * 2
            anchors.left:       parent.left
            anchors.leftMargin: ScreenTools.defaultFontPixelHeight * 20
            width:                      ScreenTools.defaultFontPixelHeight * 40
            height:                     ScreenTools.defaultFontPixelHeight * 12
            contentHeight:      criticalMessageText.height
            contentWidth:       criticalMessageText.width
            boundsBehavior:     Flickable.StopAtBounds
            pixelAligned:       true
            clip:               true

            TextEdit {
                id:             criticalMessageText
                width:          ScreenTools.defaultFontPixelHeight * 40//criticalMmessageArea.width - criticalClose.width - (ScreenTools.defaultFontPixelHeight * 2)
                anchors.left:   parent.left
                readOnly:       true
                textFormat:     TextEdit.RichText
                font.pointSize: ScreenTools.mediumFontPointSize
                font.family:    ScreenTools.demiboldFontFamily
                wrapMode:       TextEdit.WordWrap
                color:          "#fff100"   //qgcPal.alertText
            }
        }

        //-- Dismiss Critical Message
        Image {
            id:                 criticalClose
            anchors.bottomMargin:    ScreenTools.defaultFontPixelHeight * 3
            anchors.bottom:     parent.bottom
            anchors.right:      parent.right
            anchors.rightMargin: ScreenTools.defaultFontPixelHeight * 6
            height:               ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 4 : ScreenTools.defaultFontPixelHeight*3
            source:             "/res/Messageok.svg"
            fillMode:           Image.PreserveAspectFit
            MouseArea {
                anchors.fill:       parent
                // anchors.margins:    ScreenTools.isMobile ? -ScreenTools.defaultFontPixelHeight : 0
                onClicked: {
                    criticalMmessageArea.close()
                }
            }
        }
        QGCLabel {
            text:           qsTr("知道了")//"Systemseting"
            font.pointSize: ScreenTools.mediumFontPointSize
            font.bold:             true
            color:          qgcPal.text
            anchors.centerIn: criticalClose
        }
        //-- More text below indicator
        QGCColoredImage {
            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
            anchors.bottom:     parent.bottom
            anchors.right:      parent.right
            width:              ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
            height:             width
            sourceSize.height:  width
            source:             "/res/ArrowDown.svg"
            fillMode:           Image.PreserveAspectFit
            visible:            criticalMessageText.lineCount > 5
            color:              qgcPal.alertText
            MouseArea {
                anchors.fill:   parent
                onClicked: {
                    criticalMessageFlick.flick(0,-500)
                }
            }
        }
    }

    //-------------------------------------------------------------------------
    //-- Loader helper for any child, no matter how deep can display an element
    //   in the middle of the main window.
    Loader {
        id:         rootLoader
        anchors.centerIn: parent
    }

}

