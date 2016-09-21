/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick              2.5
import QtQuick.Controls     1.4

import QGroundControl.Controls  1.0
import QGroundControl.ScreenTools   1.0
SetupPage {
    id:             paramsPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  availableWidth
            height: rowbutton.height+ScreenTools.defaultFontPixelHeight*8
            property real _middleRowWidth:  ScreenTools.defaultFontPixelWidth * 20
            property real _editFieldWidth:  ScreenTools.defaultFontPixelWidth * 14
            Rectangle {
                id:                         title
                anchors.top:                parent.top
                anchors.horizontalCenter:   parent.horizontalCenter
                width:                      parent.width
                height:                     ScreenTools.defaultFontPixelHeight*6
                color:                      "transparent"
                QGCCircleProgress{
                    id:                     circle
                    anchors.left:           parent.left
                    anchors.top:            parent.top
                    anchors.leftMargin:     ScreenTools.defaultFontPixelHeight*5
                    anchors.topMargin:      ScreenTools.defaultFontPixelHeight
                    width:                  ScreenTools.defaultFontPixelHeight*5
                    value:                  0
                }
                QGCColoredImage {
                    id:                     img
                    height:                 ScreenTools.defaultFontPixelHeight*2.5
                    width:                  height
                    sourceSize.width: width
                    source:     "/qmlimages/subMenuButtonImage.png";
                    fillMode:   Image.PreserveAspectFit
                    color:      qgcPal.text
                    anchors.horizontalCenter:circle.horizontalCenter
                    anchors.verticalCenter: circle.verticalCenter
                }
                QGCLabel {
                    id:             idset
                    anchors.left:   img.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("机参")//"safe"
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold:              true
                    color:          qgcPal.text
                    anchors.verticalCenter: img.verticalCenter
                }
                Image {
                    source:    "/qmlimages/title.svg"
                    width:      idset.width+ScreenTools.defaultFontPixelHeight*4
                    height:     ScreenTools.defaultFontPixelHeight*3
                    anchors.verticalCenter: circle.verticalCenter
                    anchors.left:          circle.right
                }
            }
            Row{
                id:             rowbutton
                anchors.top:    title.bottom
                anchors.topMargin:      ScreenTools.defaultFontPixelHeight
                ExclusiveGroup { id: paramsGroup }
                anchors.horizontalCenter: parent.horizontalCenter
                spacing:    ScreenTools.defaultFontPixelWidth*0.5
                QGCButton{
                    exclusiveGroup:     paramsGroup
                    checkable:          true
                    width:              _middleRowWidth
                    text:               qsTr("姿态控制")//att
                    onClicked: {
                        panelLoader.source = "LinkSettings.qml";
                    }
                }
                QGCButton{
                    exclusiveGroup:     paramsGroup
                    checkable:          true
                    width:              _middleRowWidth
                    text:               qsTr("位置控制")//pos
                    onClicked: {
                        panelLoader.source = "LinkSettings.qml";
                    }
                }
                QGCButton{
                    exclusiveGroup:     paramsGroup
                    checkable:          true
                    width:              _middleRowWidth
                    text:               qsTr("算法控制")//
                    onClicked: {
                        panelLoader.source = "LinkSettings.qml";
                    }
                }
                QGCButton{
                    exclusiveGroup:     paramsGroup
                    checkable:          true
                    width:              _middleRowWidth
                    text:               qsTr("其他设置")//else
                    onClicked: {
                        panelLoader.source = "LinkSettings.qml";
                    }
                }
            }
            Rectangle {
                id:                     loader
                anchors.fill:           parent
                anchors.margins:        _defaultTextHeight
                visible:                true
                color:                  qgcPal.windowShade
                z:                       QGroundControl.zOrderTopMost
                Loader {
                    id:                     panelLoader
                    anchors.fill:           parent
                }

            }
        }
    }
}

