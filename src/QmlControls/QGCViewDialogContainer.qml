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

import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Item {
    id: _root
    z:  5000

    property alias  dialogWidth:     _dialogPanel.width
    property alias  dialogTitle:     titleLabel.text
    property alias  dialogComponent: _dialogComponentLoader.sourceComponent
    property var    viewPanel

    property real _defaultTextHeight:   _textMeasure.contentHeight
    property real _defaultTextWidth:    _textMeasure.contentWidth

    function setupDialogButtons(buttons) {
        _acceptButton.visible = false
        _rejectButton.visible = false

        // Accept role buttons
        if (buttons & StandardButton.Ok) {
            _acceptButton.text = qsTr("确认")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Open) {
            _acceptButton.text = qsTr("打开")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Save) {
            _acceptButton.text = qsTr("保存")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Apply) {
            _acceptButton.text = qsTr("应用")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Open) {
            _acceptButton.text = qsTr("打开")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.SaveAll) {
            _acceptButton.text = qsTr("保存全部")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Yes) {
            _acceptButton.text = qsTr("是")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.YesToAll) {
            _acceptButton.text = qsTr("全部")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Retry) {
            _acceptButton.text = qsTr("重试")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Reset) {
            _acceptButton.text = qsTr("重置")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.RestoreToDefaults) {
            _acceptButton.text = qsTr("恢复默认")
            _acceptButton.visible = true
        } else if (buttons & StandardButton.Ignore) {
            _acceptButton.text = qsTr("忽略")
            _acceptButton.visible = true
        }

        // Reject role buttons
        if (buttons & StandardButton.Cancel) {
            _rejectButton.text = qsTr("取消")
            _rejectButton.visible = true
        } else if (buttons & StandardButton.Close) {
            _rejectButton.text = qsTr("关闭")
            _rejectButton.visible = true
        } else if (buttons & StandardButton.No) {
            _rejectButton.text = qsTr("否")
            _rejectButton.visible = true
        } else if (buttons & StandardButton.NoToAll) {
            _rejectButton.text = qsTr("全部否")
            _rejectButton.visible = true
        } else if (buttons & StandardButton.Abort) {
            _rejectButton.text = qsTr("终止")
            _rejectButton.visible = true
        }
    }

    Connections {
        target: _dialogComponentLoader.item

        onHideDialog: {
            viewPanel.enabled = true
            _root.destroy()
        }
    }

    QGCPalette { id: _qgcPal; colorGroupEnabled: true }
    QGCLabel { id: _textMeasure; text: "X"; visible: false }

//    Rectangle {
//        anchors.top:    parent.top
//        anchors.bottom: parent.bottom
//        anchors.left:   parent.left
//        anchors.right:  _dialogPanel.left
//        opacity:        0.5
//        color:          _qgcPal.window
//        z:              5000
//    }

    // This is the main dialog panel which is anchored to the right edge
    Rectangle {
        id:                 _dialogPanel
//        height:             ScreenTools.availableHeight ? ScreenTools.availableHeight : parent.height
//        anchors.bottom:     parent.bottom
//        anchors.right:      parent.right
        color:              _qgcPal.windowShadeDark
        anchors.centerIn:   parent

        width:              _dialogCharWidth == showDialogFullWidth ? parent.width : defaultTextWidth * _dialogCharWidth
        height:             Math.max(_dialogComponentLoader.y+_dialogComponentLoader.height+ScreenTools.defaultFontPixelHeight*2,ScreenTools.defaultFontPixelHeight*5)//ScreenTools.availableHeight ? ScreenTools.availableHeight : parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        border.width:      ScreenTools.defaultFontPixelHeight/8
        border.color:      _qgcPal.buttonHighlight
        radius:            ScreenTools.defaultFontPixelHeight/4
        Rectangle {
            id:     _header
            width:  parent.width
            height: _acceptButton.visible ? _acceptButton.height : _rejectButton.height
            color:  _qgcPal.windowShade

            function _hidePanel() {
                _fullPanel.visible = false
            }

            QGCLabel {
                id:                 titleLabel
                x:                  _defaultTextWidth
                height:             parent.height
                verticalAlignment:	Text.AlignVCenter
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
            anchors.margins:    5
            anchors.left:       parent.left
            anchors.right:      parent.right
            anchors.top:        _spacer.bottom
//            anchors.bottom:     parent.bottom
            sourceComponent:    _dialogComponent

            property bool acceptAllowed: _acceptButton.visible
            property bool rejectAllowed: _rejectButton.visible
        }
    } // Rectangle - Dialog panel
}
