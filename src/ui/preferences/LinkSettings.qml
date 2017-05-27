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

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

Rectangle {
    id:                 _linkRoot
    color:              qgcPal.window
    anchors.fill:       parent
 //   anchors.margins:    ScreenTools.defaultFontPixelWidth

    property var _currentSelection: null
    property int _firstColumn:      ScreenTools.defaultFontPixelWidth * 12
    property int _secondColumn:     ScreenTools.defaultFontPixelWidth * 30
    property int _defaultHeght:     ScreenTools.isMobile ? ScreenTools. defaultFontPixelHeight*0.8:ScreenTools. defaultFontPixelHeight
    ExclusiveGroup { id: linkGroup }

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  enabled
    }

    function openCommSettings(lconf) {
        settingLoader.linkConfig = lconf
        settingLoader.sourceComponent = commSettings
        settingLoader.visible = true
    }

    function closeCommSettings() {
        settingLoader.visible = false
        settingLoader.sourceComponent = null
    }

    QGCCircleProgress{
        id:                 setcircle
        anchors.left:       parent.left
        anchors.top:        parent.top
        anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
        anchors.topMargin:  ScreenTools.defaultFontPixelHeight
        width:              ScreenTools.defaultFontPixelHeight*5
        value:              0
    }
    QGCColoredImage {
        id:         setimg
        height:     ScreenTools.defaultFontPixelHeight*2.5
        width:      height
        sourceSize.width: width
        source:     "/res/connect.svg"
        fillMode:   Image.PreserveAspectFit
        color:      qgcPal.text
        anchors.horizontalCenter:setcircle.horizontalCenter
        anchors.verticalCenter: setcircle.verticalCenter
    }
    QGCLabel {
        id:             idset
        anchors.left:   setimg.left
        anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
        text:           qsTr("连接")//"Systemseting"
        font.pointSize: ScreenTools.mediumFontPointSize
        font.bold:      true
        color:          qgcPal.text
        anchors.verticalCenter: setimg.verticalCenter
    }
    Image {
        source:    "/qmlimages/title.svg"
        width:      idset.width+ScreenTools.defaultFontPixelHeight*4
        height:     ScreenTools.defaultFontPixelHeight*3
        anchors.verticalCenter: setcircle.verticalCenter
        anchors.left:           setcircle.right
        //        fillMode: Image.PreserveAspectFit
    }

    QGCFlickable {
        clip:               true
        anchors.top:        setimg.bottom
        anchors.margins:    ScreenTools.defaultFontPixelWidth*2
        width:              parent.width
        height:             parent.height -ScreenTools.defaultFontPixelWidth*20
        contentHeight:      settingsColumn.height+ScreenTools.defaultFontPixelWidth*2
        contentWidth:       _linkRoot.width
        flickableDirection: Flickable.VerticalFlick

        Flow {
            id:                 settingsColumn
            width:              _linkRoot.width*0.9
            anchors.left:       parent.left
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth*20
            anchors.top:        parent.top
            anchors.topMargin:  ScreenTools.defaultFontPixelWidth
            spacing:            _defaultHeght*4
            Repeater {
                model: QGroundControl.linkManager.linkConfigurations
                delegate: Rectangle{
                    width:              _defaultHeght * 24
                    height:             _defaultHeght * 10
                    color:              "transparent"
                    ImageButton {
                        id:                  con
                        imageResource:       "/qmlimages/connecttitlebg.svg"
                        checkimage:          "/qmlimages/connecttitlebgcheck.svg"
                        exclusiveGroup:      linkGroup
                        anchors.top:         parent.top
                        anchors.left:        parent.left
                        checkable:           true
                        width:               _defaultHeght * 24
                        height:              _defaultHeght * 3
                        text:                object.name
                        onClicked: {
                            //  checked=  true
                            _currentSelection = object
                        }
                    }
                    Image{
                        id:                     bgicon
                        anchors.top:                con.bottom
                        anchors.horizontalCenter:   con.horizontalCenter
                        source:             "/qmlimages/connecticonbg.svg"
                        fillMode:            Image.PreserveAspectFit
                        width:               _defaultHeght * 20
                        height:              _defaultHeght * 4
                    }
                    Row{
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: bgicon.verticalCenter
                        spacing:            ScreenTools.defaultFontPixelHeight * 3
                        QGCColoredImage {
                            id:                     connect
                            width:                  ScreenTools.defaultFontPixelHeight * 2
                            height:                 ScreenTools.defaultFontPixelHeight * 2
                            fillMode:               Image.PreserveAspectFit
                            smooth:                 true
                            color:                  "#8ea6b1"//"White"//qgcPal.button
                            source:                 "/qmlimages/connect.svg"
                            visible:                 object && !object.link
                            MouseArea{
                                anchors.fill: parent
                                enabled:    object && !object.link
                                onClicked: {
                                   QGroundControl.linkManager.createConnectedLink(object)
                                }
                            }
                        }
                        QGCColoredImage {
                            id:                     edit
                            anchors.verticalCenter: parent.verticalCenter
                            width:                  ScreenTools.defaultFontPixelHeight * 2
                            height:                 ScreenTools.defaultFontPixelHeight * 2
                            fillMode:               Image.PreserveAspectFit
                            smooth:                 true
                            color:                  "#8ea6b1"//"White"// qgcPal.button
                            source:                 "/qmlimages/connectedit.svg"
                            visible:                object && !object.link
                            MouseArea{
                                anchors.fill: parent
                                enabled:    object && !object.link
                                onClicked: {
                                   _linkRoot.openCommSettings(object)
                                }
                            }

                        }
                        QGCColoredImage {
                            id:                     del
                            anchors.verticalCenter: parent.verticalCenter
                            width:                  ScreenTools.defaultFontPixelHeight * 2
                            height:                 ScreenTools.defaultFontPixelHeight * 2
                            fillMode:               Image.PreserveAspectFit
                            smooth:                 true
                            color:                  "#8ea6b1"//"White"//qgcPal.button
                            source:                 "/qmlimages/connectdel.svg"
                            visible:                object && ! object.dynamic
                            MouseArea{
                                anchors.fill: parent
                                enabled:                object && ! object.dynamic
                                onClicked: {
                                    if(object)
                                        deleteDialog.visible = true
                                }
                                MessageDialog {
                                    id:         deleteDialog
                                    visible:    false
                                    icon:       StandardIcon.Warning
                                    standardButtons: StandardButton.Yes | StandardButton.No
                                    title:      qsTr("删除连接")//Remove Link Configuration
                                    text:       object ? qsTr("删除 %1. 确认删除?").arg(object.name) : ""//"Remove %1. Is this really what you want?"
                                    onYes: {
                                        if(object)
                                            QGroundControl.linkManager.removeConfiguration(object)
                                        deleteDialog.visible = false
                                    }
                                    onNo: {
                                        deleteDialog.visible = false
                                    }
                                }
                            }
                        }
                    }
                }
            }//Repeater
            ImageButton {
                id:                  add
                imageResource:       "/qmlimages/connectadd.svg"
                width:               ScreenTools.defaultFontPixelHeight * 24
                height:              ScreenTools.defaultFontPixelHeight * 7
                onClicked: {
                    _linkRoot.openCommSettings(null) //  checked=  tru
                }
            }
        }
    }

//    Row {
//        id:                 buttonRow
//        spacing:            ScreenTools.defaultFontPixelWidth
//        anchors.bottom:     parent.bottom
//        anchors.margins:    ScreenTools.defaultFontPixelWidth
//        anchors.horizontalCenter: parent.horizontalCenter
//        QGCButton {
//            width:      ScreenTools.defaultFontPixelWidth * 10
//            text:       qsTr("Delete")
//            enabled:    _currentSelection && !_currentSelection.dynamic
//            onClicked: {
//                if(_currentSelection)
//                    deleteDialog1.visible = true
//            }
//            MessageDialog {
//                id:         deleteDialog1
//                visible:    false
//                icon:       StandardIcon.Warning
//                standardButtons: StandardButton.Yes | StandardButton.No
//                title:      qsTr("Remove Link Configuration")
//                text:       _currentSelection ? qsTr("Remove %1. Is this really what you want?").arg(_currentSelection.name) : ""
//                onYes: {
//                    if(_currentSelection)
//                        QGroundControl.linkManager.removeConfiguration(_currentSelection)
//                    deleteDialog.visible = false
//                }
//                onNo: {
//                    deleteDialog.visible = false
//                }
//            }
//        }
//        QGCButton {
//            text:       qsTr("Edit")
//            enabled:    _currentSelection && !_currentSelection.link
//            onClicked: {
//                _linkRoot.openCommSettings(_currentSelection)
//            }
//        }
//        QGCButton {
//            text:       qsTr("Add")
//            onClicked: {
//                _linkRoot.openCommSettings(null)
//            }
//        }
//        QGCButton {
//            text:       qsTr("Connect")
//            enabled:    _currentSelection && !_currentSelection.link
//            onClicked: {
//                QGroundControl.linkManager.createConnectedLink(_currentSelection)
//            }
//        }
//        QGCButton {
//            text:       qsTr("Disconnect")
//            enabled:    _currentSelection && _currentSelection.link
//            onClicked: {
//                QGroundControl.linkManager.disconnectLink(_currentSelection.link, false)
//            }
//        }
//    }

    Loader {
        id:             settingLoader
        anchors.fill:   parent
        visible:        false
        property var linkConfig: null
        property var editConfig: null
    }

    //---------------------------------------------
    // Comm Settings
    Component {
        id: commSettings
        Rectangle {
            color:          qgcPal.window
            anchors.fill:   parent
            Component.onCompleted: {
                // If editing, create copy for editing
                if(linkConfig) {
                    editConfig = QGroundControl.linkManager.startConfigurationEditing(linkConfig)
                } else {
                    // Create new link configuration
                    if(ScreenTools.isiOS)
                        editConfig = QGroundControl.linkManager.createConfiguration(LinkConfiguration.TypeUdp, "Unnamed")
                    else
                        editConfig = QGroundControl.linkManager.createConfiguration(LinkConfiguration.TypeSerial, "Unnamed")
                }
            }
            Component.onDestruction: {
                if(editConfig) {
                    QGroundControl.linkManager.cancelConfigurationEditing(editConfig)
                    editConfig = null
                }
            }
            QGCFlickable {
                id:                 settingsFlick
                clip:               true
                anchors.top:        parent.top
                width:              parent.width*0.8
                anchors.horizontalCenter: parent.horizontalCenter
                height:             parent.height - commButtonRow.height
                anchors.margins:    ScreenTools.defaultFontPixelHeight*2
                contentHeight:      commSettingsColumn.height
                contentWidth:       _linkRoot.width
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior:     Flickable.StopAtBounds
                Column {
                    id:                 commSettingsColumn
                    width:              _linkRoot.width
                    anchors.margins:    ScreenTools.defaultFontPixelWidth
                    spacing:            ScreenTools.defaultFontPixelHeight / 2
                    QGCLabel {
                        text:   linkConfig ? qsTr("编辑连接")/*qsTr("Edit Link Configuration Settings (WIP)") */: qsTr("创建连接")/*qsTr("Create New Link Configuration (WIP)")*/
                        font.pointSize: ScreenTools.mediumFontPointSize
                    }
                    Rectangle {
                        height: 1
                        width:  parent.width
                        color:  qgcPal.button
                    }
                    Item {
                        height: ScreenTools.defaultFontPixelHeight / 2
                        width:  parent.width
                    }
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            text:    qsTr("名称:")//qsTr("Name:")
                            width:  _firstColumn
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        QGCTextField {
                            id:     nameField
                            text:   editConfig ? editConfig.name : ""
                            width:  _secondColumn
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Row {
                        spacing:        ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            text:       qsTr("类型:")//("Type:")
                            width:      _firstColumn
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        //-----------------------------------------------------
                        // When editing, you can't change the link type
                        QGCLabel {
                            text:       linkConfig ? QGroundControl.linkManager.linkTypeStrings[linkConfig.linkType] : ""
                            visible:    linkConfig != null
                            width:      _secondColumn
                            anchors.verticalCenter: parent.verticalCenter
                            Component.onCompleted: {
                                if(linkConfig != null) {
                                    linkSettingLoader.source  = linkConfig.settingsURL
                                    linkSettingLoader.visible = true
                                }
                            }
                        }
                        //-----------------------------------------------------
                        // When creating, select a link type
                        QGCComboBox {
                            id:             linkTypeCombo
                            width:          _secondColumn
                            visible:        linkConfig == null
                            model:          QGroundControl.linkManager.linkTypeStrings
                            anchors.verticalCenter: parent.verticalCenter
                            onActivated: {
                                if (index != -1 && index !== editConfig.linkType) {
                                    // Destroy current panel
                                    linkSettingLoader.source = ""
                                    linkSettingLoader.visible = false
                                    // Save current name
                                    var name = editConfig.name
                                    // Discard link configuration (old type)
                                    QGroundControl.linkManager.cancelConfigurationEditing(editConfig)
                                    // Create new link configuration
                                    editConfig = QGroundControl.linkManager.createConfiguration(index, name)
                                    // Load appropriate configuration panel
                                    linkSettingLoader.source  = editConfig.settingsURL
                                    linkSettingLoader.visible = true
                                }
                            }
                            Component.onCompleted: {
                                if(linkConfig == null) {
                                    linkTypeCombo.currentIndex = 0
                                    linkSettingLoader.source   = editConfig.settingsURL
                                    linkSettingLoader.visible  = true
                                }
                            }
                        }
                    }
                    Item {
                        height: ScreenTools.defaultFontPixelHeight * 0.5
                        width:  parent.width
                    }
                    //-- Auto Connect on Start
                    QGCCheckBox {
                        text:       qsTr("启动自动连接:")//"Automatically Connect on Start"
                        checked:    false
                        visible:    editConfig ? editConfig.autoConnectAllowed : false
                        onCheckedChanged: {
                            if(editConfig) {
                                editConfig.autoConnect = checked
                            }
                        }
                        Component.onCompleted: {
                            if(editConfig)
                                checked = editConfig.autoConnect
                        }
                    }
                    Item {
                        height: ScreenTools.defaultFontPixelHeight
                        width:  parent.width
                    }
                    Loader {
                        id:             linkSettingLoader
                        width:          parent.width
                        visible:        false
                        property var subEditConfig: editConfig
                    }
                }
            }
            Row {
                id:                 commButtonRow
                spacing:            ScreenTools.defaultFontPixelWidth
                anchors.margins:    ScreenTools.defaultFontPixelWidth
                anchors.bottom:     parent.bottom
                anchors.right:      parent.right
                QGCButton {
                    width:      ScreenTools.defaultFontPixelWidth * 10
                    text:       qsTr("确定")//qsTr("OK")
                    enabled:    nameField.text !== ""
                    onClicked: {
                        // Save editting
                        linkSettingLoader.item.saveSettings()
                        editConfig.name = nameField.text
                        if(linkConfig) {
                            QGroundControl.linkManager.endConfigurationEditing(linkConfig, editConfig)
                        } else {
                            // If it was edited, it's no longer "dynamic"
                            editConfig.dynamic = false
                            QGroundControl.linkManager.endCreateConfiguration(editConfig)
                        }
                        linkSettingLoader.source = ""
                        editConfig = null
                        _linkRoot.closeCommSettings()
                    }
                }
                QGCButton {
                    width:      ScreenTools.defaultFontPixelWidth * 10
                    text:       qsTr("取消")//qsTr("Cancel")
                    onClicked: {
                        QGroundControl.linkManager.cancelConfigurationEditing(editConfig)
                        editConfig = null
                        _linkRoot.closeCommSettings()
                    }
                }
            }
        }
    }
}
