/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @author Don Gagne <don@thegagnes.com>

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2

import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QtGraphicalEffects 1.0
FactPanel {
    id: _rootItem

    property var    qgcView:               _rootItem  ///< Used by Fact controls for validation dialogs
    property bool   completedSignalled:   false
    property real   topDialogMargin:      0           ///< Set a top margin for dialog
    property var    viewPanel

    /// This is signalled when the top level Item reaches Component.onCompleted. This allows
    /// the view subcomponent to connect to this signal and do work once the full ui is ready
    /// to go.
    signal completed        

    function _setupDialogButtons(buttons) {
        _acceptButton.visible = false
        _rejectButton.visible = false

        // Accept role buttons
        if (buttons & StandardButton.Ok) {
            _acceptButton.text = qsTr("确认")//qsTr("Ok")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Open) {
            _acceptButton.text = qsTr("打开")//qsTr("Open")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Save) {
            _acceptButton.text = qsTr("保存")//qsTr("Save")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Apply) {
            _acceptButton.text = qsTr("应用")//qsTr("Apply")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Open) {
            _acceptButton.text = qsTr("Open")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.SaveAll) {
            _acceptButton.text = qsTr("保存所有")//qsTr("Save All")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Yes) {
            _acceptButton.text = qsTr("是")//qsTr("Yes")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.YesToAll) {
            _acceptButton.text = qsTr("全是")//qsTr("Yes to All")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Retry) {
            _acceptButton.text = qsTr("重试")//qsTr("Retry")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Reset) {
            _acceptButton.text = qsTr("重置")//qsTr("Reset")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.RestoreToDefaults) {
            _acceptButton.text = qsTr("恢复默认")//qsTr("Restore to Defaults")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Ignore) {
            _acceptButton.text = qsTr("忽略")//qsTr("Ignore")
            _acceptButton.visible = true
        }

        // Reject role buttons
        if (buttons & StandardButton.Cancel) {
            _rejectButton.text = qsTr("取消")//qsTr("Cancel")
            _rejectButton.visible = true
        } else if (buttons & StandardButton.Close) {
            _rejectButton.text = qsTr("关闭")//qsTr("Close")
            _rejectButton.visible = true
        } else if (buttons & StandardButton.No) {
            _rejectButton.text = qsTr("否")//qsTr("No")
            _rejectButton.visible = true
        } else if (buttons & StandardButton.NoToAll) {
            _rejectButton.text = qsTr("忽略")//qsTr("No to All")
            _rejectButton.visible = true
        } else if (buttons & StandardButton.Abort) {
            _rejectButton.text = qsTr("终止")//qsTr("Abort")
            _rejectButton.visible = true
        }
    }

    function _checkForEarlyDialog(title) {
        if (!completedSignalled) {
            console.warn(qsTr("showDialog called before QGCView.completed signalled"), title)
        }
    }

    /// Shows a QGCViewDialog component
    ///     @param compoent QGCViewDialog component
    ///     @param title Title for dialog
    ///     @param charWidth Width of dialog in characters
    ///     @param buttons Buttons to show in dialog using StandardButton enum

    readonly property int showDialogFullWidth:      -1  ///< Use for full width dialog
    readonly property int showDialogDefaultWidth:   80  ///< Use for default dialog width

    function showDialog(component, title, charWidth, buttons) {
        if (_checkForEarlyDialog(title)) {
            return
        }

        _rejectButton.enabled = true
        _acceptButton.enabled = true

        _dialogCharWidth = charWidth
        _dialogTitle = title

        _setupDialogButtons(buttons)

        _dialogComponent = component
        viewPanel.enabled = false
        _dialogOverlay.visible = true
    }

    function showMessage(title, message, buttons) {
        if (_checkForEarlyDialog(title)) {
            return
        }

        _rejectButton.enabled = true
        _acceptButton.enabled = true

        _dialogCharWidth = showDialogDefaultWidth
        _dialogTitle = title
        _messageDialogText = message

        _setupDialogButtons(buttons)

        _dialogComponent = _messageDialog
        viewPanel.enabled = false
        _dialogOverlay.visible = true
 //       __animateShowDialog.start()
    }

    function hideDialog() {
        viewPanel.enabled = true
        _dialogComponent = null
        _dialogOverlay.visible = false
    }

    QGCPalette { id: _qgcPal; colorGroupEnabled: true }
    QGCLabel { id: _textMeasure; text: "X"; visible: false }

    property real defaultTextHeight: _textMeasure.contentHeight
    property real defaultTextWidth:  _textMeasure.contentWidth

    /// The width of the dialog panel in characters
    property int _dialogCharWidth: 75

    /// The title for the dialog panel
    property string _dialogTitle

    property string _messageDialogText

    property Component _dialogComponent

    function _signalCompleted() {
        // When we use this control inside a QGCQmlWidgetHolder Component.onCompleted is signalled
        // before the width and height are adjusted. So we need to wait for width and heigth to be
        // set before we signal our own completed signal.
        if (!completedSignalled && width != 0 && height != 0) {
            completedSignalled = true
            completed()
        }
    }

    Component.onCompleted:  _signalCompleted()
    onWidthChanged:         _signalCompleted()
    onHeightChanged:        _signalCompleted()

    Connections {
        target: _dialogComponentLoader.item

        onHideDialog: _rootItem.hideDialog()
    }

//    Rectangle {
//        id:      ti
//        anchors.fill: parent
//        color: "transparent"
//        opacity: 0.5
//    }

//    FastBlur {
//        id: fastBlur

//        height: 124

//        width: parent.width
//        radius: 40
//        opacity: 0.55

//        source: ShaderEffectSource {
//            sourceItem: flickable
//            sourceRect: Qt.rect(0, 0, fastBlur.width, fastBlur.height)
//        }
//    }

    Item {
        id:             _dialogOverlay
        visible:        false
        anchors.fill:   parent
        z:              5000

        // This covers the parent with an transparent section
//        Rectangle {
//            id:             _transparentSection
//            height:         ScreenTools.availableHeight ? ScreenTools.availableHeight : parent.height
//            anchors.bottom: parent.bottom
//            anchors.left:   parent.left
//            anchors.right:  _dialogPanel.left
//            opacity:        0.0
//            color:          _qgcPal.window
//        }

        // This is the main dialog panel which is anchored to the right edge
        Rectangle {
            id:                 _dialogPanel
            width:              _dialogCharWidth == showDialogFullWidth ? parent.width : defaultTextWidth * _dialogCharWidth
          //  anchors.topMargin:  ScreenTools.defaultFontPixelHeight*5
            height:             Math.max(_dialogComponentLoader.y+_dialogComponentLoader.height+ScreenTools.defaultFontPixelHeight,ScreenTools.defaultFontPixelHeight*5)//ScreenTools.availableHeight ? ScreenTools.availableHeight : parent.height
         // anchors.bottom:     parent.bottom
         // anchors.top:        parent.top
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
         //   anchors.right:      parent.right
            color:              _qgcPal.windowShadeDark
            border.width:      ScreenTools.defaultFontPixelHeight/8
            border.color:      _qgcPal.buttonHighlight
            radius:            ScreenTools.defaultFontPixelHeight/4
            Rectangle {
                id:     _header
                anchors.top:        parent.top
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight/8
                width:  parent.width-ScreenTools.defaultFontPixelHeight/4
                height: _acceptButton.visible ? _acceptButton.height : _rejectButton.height
                color:  _qgcPal.windowShade
                anchors.horizontalCenter: parent.horizontalCenter
                function _hidePanel() {
                    _fullPanel.visible = false
                }

                QGCLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height:             parent.height
                    verticalAlignment:	Text.AlignVCenter
                    text:               _dialogTitle
                }

                QGCButton {
                    id:             _rejectButton
                    anchors.right:  _acceptButton.visible ?  _acceptButton.left : parent.right
                    anchors.bottom: parent.bottom

                    onClicked: {
                        enabled = false // prevent multiple clicks
                        _dialogComponentLoader.item.reject()
                        if (!viewPanel.enabled) {
                            // Dialog was not closed, re-enable button
                            enabled = true
                        }
                    }
                }

                QGCButton {
                    id:             _acceptButton
                    anchors.right:  parent.right
                    primary:        true

                    onClicked: {
                        enabled = false // prevent multiple clicks
                       _dialogComponentLoader.item.accept()
                        if (!viewPanel.enabled) {
                            // Dialog was not closed, re-enable button
                            enabled = true
                        }
                    }
                }
            }

            Item {
                id:             _spacer
                width:          10
                height:         10
                anchors.top:    _header.bottom
            }

            Loader {
                id:                 _dialogComponentLoader
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.left:       parent.left
                anchors.right:      parent.right
                anchors.top:        _spacer.bottom
//                anchors.bottom:     parent.bottom
                sourceComponent:    _dialogComponent

                property bool acceptAllowed: _acceptButton.visible
                property bool rejectAllowed: _rejectButton.visible
            }
        } // Rectangle - Dialog panel
    } // Item - Dialog overlay

    Component {
        id: _messageDialog

        QGCViewMessage {
            message: _messageDialogText
        }
    }
}
