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

import QGroundControl.Palette 1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

SetupPage {
    id:             paramsPage
    pageComponent:  pageComponent
    Component {
        id: pageComponent

        Item {
            width:  availableWidth
            height: availableHeight
            property real _middleRowWidth:  ScreenTools.defaultFontPixelWidth * 20
            property real _editFieldWidth:  ScreenTools.defaultFontPixelWidth * 14

            FactPanelController {
                id:         controller
                factPanel:  paramsPage.viewPanel
            }
            QGCPalette { id: qgcPal; colorGroupEnabled: true }

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
                QGCLabel {
                    text:           qsTr("注意！在飞行中修改参数可能造成飞行不稳定或坠机，请谨慎")//"safe"
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold:              true
                    color:          qgcPal.warningText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row{
                id:             rowbutton
                anchors.top:    title.bottom
                anchors.topMargin:      ScreenTools.defaultFontPixelHeight*0.5
                ExclusiveGroup { id: paramsGroup }
                anchors.horizontalCenter: parent.horizontalCenter
                spacing:    ScreenTools.defaultFontPixelWidth*0.5
                QGCButton{
                    exclusiveGroup:     paramsGroup
                    checkable:          true
                    width:              _middleRowWidth
                    checked:           true
                    text:               qsTr("姿态控制")//att
                    onClicked: {
                        panelLoader.source = "AttitudeControlPlane.qml";
                        checked  =   true
                    }
                }
                QGCButton{
                    exclusiveGroup:     paramsGroup
                    checkable:          true
                    width:              _middleRowWidth
                    text:               qsTr("自动控制")//pos
                    onClicked: {
                        checked  =   true
                        panelLoader.source = "L1ControlPlane.qml";
                    }
                }
                QGCButton{
                    exclusiveGroup:     paramsGroup
                    checkable:          true
                    width:              _middleRowWidth
                    text:               qsTr("算法控制")//
                    onClicked: {
                        checked  =   true
                        panelLoader.source = "TECSControlPlane.qml";//"TECSControlPlane.qml";
                     }
                }
                QGCButton{
                    exclusiveGroup:     paramsGroup
                    checkable:          true
                    width:              _middleRowWidth
                    text:               qsTr("输出设置")//else
                    onClicked: {
                        checked  =   true
                        panelLoader.source = "OutputSetting.qml";
                    }
                }
            }
            Rectangle {
                id:                     loader
                anchors.top:            rowbutton.bottom
                anchors.topMargin:      ScreenTools.defaultFontPixelHeight*0.5
                width:                  parent.width*0.9
                height:                 parent.height*0.8
                anchors.horizontalCenter: parent.horizontalCenter
                color:                  "transparent"//qgcPal.window
                Loader {
                    id:                     panelLoader
                    anchors.fill:           parent
                }
            }
            Component.onCompleted: {
                panelLoader.source = "AttitudeControlPlane.qml";
            }
            Component {
                id: elsesetComponent

                Rectangle {
                    color:  "transparent"

                    QGCLabel {
                        anchors.margins:        _defaultTextWidth * 2
                        anchors.fill:           parent
                        verticalAlignment:      Text.AlignVCenter
                        horizontalAlignment:    Text.AlignHCenter
                        wrapMode:               Text.WordWrap
                        font.pointSize:         ScreenTools.largeFontPointSize
                        text:                   qsTr("if some params want I will add 添加中")
                        onLinkActivated: Qt.openUrlExternally(link)
                    }
                }
            }
        }
    }
}

