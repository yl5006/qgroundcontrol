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

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

QGCViewDialog {
    id: root
    height: commandList.y+commandList.height
    property var missionItem

    property var _vehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real _editFieldWidth:              ScreenTools.defaultFontPixelWidth * 15
    QGCPalette { id: qgcPal }

    QGCLabel {
        id:                 categoryLabel
        anchors.left:       parent.left
        anchors.margins:    ScreenTools.defaultFontPixelWidth*2
        anchors.baseline:   categoryCombo.baseline
        text:               qsTr("类别:")//qsTr("Category:")
    }

    QGCComboBox {
        id:                 categoryCombo
        anchors.margins:    ScreenTools.defaultFontPixelWidth
        anchors.left:       categoryLabel.right
        width:              _editFieldWidth
        model:              QGroundControl.missionCommandTree.categoriesForVehicle(_vehicle)

        function categorySelected(category) {
            commandRepeater.model = QGroundControl.missionCommandTree.getCommandsForCategory(_vehicle, category)
        }

        Component.onCompleted: {
            var category  = missionItem.category
            currentIndex = find(category)
            categorySelected(category)          
        }

        onActivated: categorySelected(textAt(index))
    }

    Flow {
        id:                 commandList
        anchors.margins:    ScreenTools.defaultFontPixelHeight
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        categoryCombo.bottom
        height:             ((commandRepeater.count+1)/2)*ScreenTools.defaultFontPixelHeight*5+ScreenTools.defaultFontPixelHeight*2
        //   anchors.bottom:     parent.bottom
        spacing:            ScreenTools.defaultFontPixelHeight / 2
        //        orientation:        ListView.Vertical
        //        clip:               true
        Repeater {
            id:     commandRepeater
            Rectangle {
                width:  parent.width/2-ScreenTools.defaultFontPixelHeight / 3
                height: ScreenTools.defaultFontPixelHeight*5
                color:  "transparent"//qgcPal.button

                Image {
                    anchors.fill:               parent
                    mipmap:                     true
                    source:                     "/qmlimages/safebackground.svg"
                    smooth:                     true
                }

                Image {
                    anchors.top:                    parent.top
                    anchors.left:                   parent.left
                    width:                          parent.width/3 * 2
                  //  fillMode:                       Image.PreserveAspectFit
                    height:                         ScreenTools.defaultFontPixelHeight*2
                    anchors.topMargin:              ScreenTools.defaultFontPixelHeight/24
                    mipmap:                         true
                    source:                         "/qmlimages/safetitlebg.svg"
                }
                property var    mavCmdInfo: modelData
                property var    textColor:  qgcPal.buttonText

                Column {
                    id:                 commandColumn
                    anchors.margins:    ScreenTools.defaultFontPixelWidth
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top
                    spacing:            ScreenTools.defaultFontPixelHeight / 2
                    QGCLabel {
                        text:           mavCmdInfo.friendlyName
                        color:          textColor
                        font.family:    ScreenTools.demiboldFontFamily
                        font.pointSize: ScreenTools.mediumFontPointSize
                    }

                    QGCLabel {
                        anchors.margins:    ScreenTools.defaultFontPixelWidth
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        text:               mavCmdInfo.description
                        wrapMode:           Text.WordWrap
                        color:              textColor
                    }
                }

                MouseArea {
                    anchors.fill:   parent
                    onClicked: {
                        missionItem.command = mavCmdInfo.command
                        root.reject()
                    }
                }
            }
        }
    } // QGCListView
} // QGCViewDialog
