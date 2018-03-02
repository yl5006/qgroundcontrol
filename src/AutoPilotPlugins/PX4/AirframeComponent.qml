/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.ScreenTools 1.0


SetupPage {
    id:             airframePage
    pageComponent:  pageComponent

    Component {
        id: pageComponent
        // anchors.margins:    ScreenTools.defaultFontPixelWidth
        Item {
            width:  availableWidth
            height: flowView.height+ScreenTools.defaultFontPixelHeight*16
            property real _minW:        ScreenTools.defaultFontPixelWidth * 35
            property real _boxWidth:    _minW
            property real _boxSpace:    ScreenTools.defaultFontPixelWidth
            property int  _selectstate:    0
            readonly property real spacerHeight: ScreenTools.defaultFontPixelHeight

            function computeDimensions() {
                var sw  = 0
                var rw  = 0
                var idx = Math.floor(flowView.width / (_minW + ScreenTools.defaultFontPixelWidth))
                if(idx < 1) {
                    _boxWidth = flowView.width
                    _boxSpace = 0
                } else {
                    _boxSpace = 0
                    if(idx > 1) {
                        _boxSpace = ScreenTools.defaultFontPixelWidth
                        sw = _boxSpace * (idx - 1)
                    }
                    rw = flowView.width - sw
                    _boxWidth = rw / idx
                }
            }
            function getvisiable(type) {
                switch(_selectstate)
                {
                default:
                case 0:
                    switch(type)
                    {
                    case 2:
                    case 3:
                    case 4:
                    case 13:
                    case 14:
                    case 15:
                        return true;
                    default:
                        return false;
                    }
                case 1:
                    switch(type)
                    {
                    case 1:
                        return true;
                    default:
                        return false;
                    }
                case 2:
                    switch(type)
                    {
                    case 10:
                    case 11:
                    case 12:
                    case 19:
                    case 20:
                    case 21:
                        return true;
                    default:
                        return false;
                    }
                case 3:
                    switch(type)
                    {
                    case 22:
                        return false;
                    default:
                        return true;
                    }
                }

            }
            QGCCircleProgress{
                id:                 airframecircle
                anchors.left:       parent.left
                anchors.top:        parent.top
                anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                width:              ScreenTools.defaultFontPixelHeight*5
                value:              0
            }
            QGCColoredImage {
                id:         airframeimg
                height:     ScreenTools.defaultFontPixelHeight*2.5
                width:      height
                sourceSize.width: width
                source:     "/qmlimages/map_plane.svg"
                fillMode:   Image.PreserveAspectFit
                color:      qgcPal.text
                anchors.horizontalCenter:airframecircle.horizontalCenter
                anchors.verticalCenter: airframecircle.verticalCenter
            }
            QGCLabel {
                id:             idset
                anchors.left:   airframeimg.left
                anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                text:           qsTr("机体")//"Vehicle"
                font.pointSize: ScreenTools.mediumFontPointSize
                font.bold:      true
                color:          qgcPal.text
                anchors.verticalCenter: airframeimg.verticalCenter
            }
            Image {
                source:    "/qmlimages/title.svg"
                width:      idset.width+ScreenTools.defaultFontPixelHeight*4
                height:     ScreenTools.defaultFontPixelHeight*3
                anchors.verticalCenter: airframecircle.verticalCenter
                anchors.left:           airframecircle.right
                //        fillMode: Image.PreserveAspectFit
            }
            Item {
                id:             helpApplyRow
                anchors.verticalCenter: airframecircle.verticalCenter
                anchors.left:   airframecircle.right
                anchors.leftMargin: ScreenTools.defaultFontPixelHeight*5
                anchors.right:  parent.right
                height:         Math.max(helpText.contentHeight, applyButton.height)

                QGCLabel {
                    id:             helpText
                    width:          parent.width*0.4
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           (controller.currentVehicleName != "" ? "" : qsTr("机型未设置"))+
                                    //qsTr("You've connected a %1.").arg(controller.currentVehicleName) :
                                    //     qsTr("Airframe is not set.")) +
                                    qsTr("改变机型，选择并确认")//qsTr("To change this configuration, select the desired airframe below then click “Apply and Restart”.")
                    font.family:    ScreenTools.demiboldFontFamily
                    wrapMode:       Text.WordWrap
                }

                QGCButton {
                    id:             applyButton
                    anchors.right:  parent.right
                    text:           qsTr("生效并重启")//qsTr("Apply and Restart")

                    onClicked:      showDialog(applyRestartDialogComponent, qsTr("生效并重启"), qgcView.showDialogDefaultWidth, StandardButton.Apply | StandardButton.Cancel)
                }
            }
            Column {
                id:                 mainColumn
                anchors.left:       parent.left
                anchors.right:      parent.right
                anchors.bottom:     parent.bottom
                anchors.top:        airframeimg.bottom
                anchors.margins:    ScreenTools.defaultFontPixelWidth*5
                width:              availableWidth
                spacing:            ScreenTools.defaultFontPixelWidth
                onWidthChanged: {
                    computeDimensions()
                }

                Component.onCompleted: computeDimensions()

                AirframeComponentController {
                    id:         controller
                    factPanel:  airframePage.viewPanel

                    Component.onCompleted: {
                        if (controller.showCustomConfigPanel) {
                            showDialog(customConfigDialogComponent, qsTr("Custom Airframe Config"), qgcView.showDialogDefaultWidth, StandardButton.Reset)
                        }
                    }
                }

                Component {
                    id: customConfigDialogComponent

                    QGCViewMessage {
                        id:       customConfigDialog
                        message:  qsTr("Your vehicle is using a custom airframe configuration. ") +
                                  qsTr("This configuration can only be modified through the Parameter Editor.\n\n") +
                                  qsTr("If you want to reset your airframe configuration and select a standard configuration, click 'Reset' above.")

                        property Fact sys_autostart: controller.getParameterFact(-1, "SYS_AUTOSTART")

                        function accept() {
                            sys_autostart.value = 0
                            customConfigDialog.hideDialog()
                        }
                    }
                }

                Component {
                    id: applyRestartDialogComponent

                    QGCViewDialog {
                        id: applyRestartDialog
                        height: ScreenTools.defaultFontPixelHeight*10
                        function accept() {
                            controller.changeAutostart()
                            applyRestartDialog.hideDialog()
                        }

                        QGCLabel {
                            anchors.fill:   parent
                            wrapMode:       Text.WordWrap
                        text:           qsTr("点击 确认 会保存你选择的机型配置.<br><br>\
                                              除了遥控校准参数其他参数会被重置.<br><br>\
                                              重启完成操作")
//                       Clicking “Apply” will save the changes you have made to your airframe configuration.<br><br>\
//                        All vehicle parameters other than Radio Calibration will be reset.<br><br>\
//                        Your vehicle will also be restarted in order to complete the process.
                        }
                    }
                }

                //        Item {
                //            id:             helpApplyRow
                //            anchors.left:   parent.left
                //            anchors.right:  parent.right
                //            height:         Math.max(helpText.contentHeight, applyButton.height)

                //            QGCLabel {
                //                id:             helpText
                //                width:          parent.width - applyButton.width - 5
                //                text:           (controller.currentVehicleName != "" ?
                //                                     qsTr("You've connected a %1.").arg(controller.currentVehicleName) :
                //                                     qsTr("Airframe is not set.")) +
                //                                qsTr("To change this configuration, select the desired airframe below then click “Apply and Restart”.")
                //                font.family:    ScreenTools.demiboldFontFamily
                //                wrapMode:       Text.WordWrap
                //            }

                //            QGCButton {
                //                id:             applyButton
                //                anchors.right:  parent.right
                //                text:           qsTr("Apply and Restart")

                //                onClicked:      showDialog(applyRestartDialogComponent, qsTr("Apply and Restart"), qgcView.showDialogDefaultWidth, StandardButton.Apply | StandardButton.Cancel)
                //            }
                //        }
                Row{
                    id:             rowbutton
                    ExclusiveGroup { id: planeGroup }
                    anchors.horizontalCenter: parent.horizontalCenter
                    width:      parent.width*0.8
                    spacing:    ScreenTools.defaultFontPixelWidth*0.5
                    QGCButton{
                        exclusiveGroup:      planeGroup
                        checkable:          true
                        width:              parent.width*0.2
                        checked:            _selectstate==0
                        text:               qsTr("多旋翼")//coper
                        onClicked: {
                            _selectstate=0
                        }
                    }
                    QGCButton{
                        exclusiveGroup:      planeGroup
                        checkable:          true
                        width:              parent.width*0.2
                        checked:            _selectstate==1
                        text:               qsTr("固定翼")//fixwing
                        onClicked: {
                            _selectstate=1
                        }
                    }
                    QGCButton{
                        exclusiveGroup:      planeGroup
                        checkable:          true
                        checked:            _selectstate==2
                        width:              parent.width*0.2
                        text:               qsTr("其他")//else
                        onClicked: {
                            _selectstate=2
                        }
                    }
                    QGCButton{
                        exclusiveGroup:      planeGroup
                        checkable:          true
                        checked:            _selectstate==3
                        width:              parent.width*0.2
                        text:               qsTr("全部")//all
                        onClicked: {
                            _selectstate=3
                        }
                    }
                }

                QGCFlickable {
                    clip:               true
                    //     anchors.top:        rowbutton.bottom
                    anchors.margins:    ScreenTools.defaultFontPixelWidth*3
                    width:              parent.width
                    height:             parent.height-ScreenTools.defaultFontPixelWidth*3
                    contentHeight:      flowView.height
                    contentWidth:       parent.width
                    flickableDirection: Flickable.VerticalFlick
                    Flow {
                        id:         flowView
                        width:      parent.width*0.9
                        spacing:    _boxSpace
                        anchors.horizontalCenter: parent.horizontalCenter
                        ExclusiveGroup {
                            id: airframeTypeExclusive
                        }

                        Repeater {
                            model: controller.airframeTypes

                            // Outer summary item rectangle
                            Rectangle {
                                width:      _boxWidth
                                height:     ScreenTools.defaultFontPixelHeight * 16
                                color:      "transparent"//qgcPal.window
                                visible:    getvisiable(modelData.type)
                                readonly property real titleHeight: ScreenTools.defaultFontPixelHeight * 1.75
                                readonly property real innerMargin: ScreenTools.defaultFontPixelWidth

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        applyButton.primary = true
                                        airframeCheckBox.checked = true
                                    }
                                }
                                Image {
                                    id:                 bg
                                    anchors.fill:       parent
                                    fillMode:           Image.PreserveAspectFit
                                    smooth:             true
                                    mipmap:             true
                                    source:             airframeCheckBox.checked ? "/qmlimages/planebgselect.svg":"/qmlimages/planebg.svg"
                                }
                                QGCLabel {
                                    id:     title
                                    anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                                    anchors.top:        parent.top
                                    anchors.horizontalCenter:  parent.horizontalCenter
                                    text:   modelData.name
                                }

                                Rectangle {
                                    anchors.topMargin:  ScreenTools.defaultFontPixelHeight / 2
                                    anchors.top:        title.bottom
                                    anchors.bottom:     parent.bottom
                                    anchors.left:       parent.left
                                    anchors.right:      parent.right
                                    color:              "transparent"//  airframeCheckBox.checked ? qgcPal.buttonHighlight : qgcPal.windowShade

                                    Image {
                                        id:                 image
                                        anchors.margins:    innerMargin
                                        anchors.top:        parent.top
                                        anchors.bottom:     combo.top
                                        anchors.left:       parent.left
                                        anchors.right:      parent.right
                                        fillMode:           Image.PreserveAspectFit
                                        smooth:             true
                                        mipmap:             true
                                        source:             modelData.imageResource
                                    }

                                    QGCCheckBox {
                                        // Although this item is invisible we still use it to manage state
                                        id:             airframeCheckBox
                                        checked:        modelData.name === controller.currentAirframeType
                                        exclusiveGroup: airframeTypeExclusive
                                        visible:        false

                                        onCheckedChanged: {
                                            if (checked && combo.currentIndex != -1) {
                                        console.log("check box change", combo.currentIndex)
                                                controller.autostartId = modelData.airframes[combo.currentIndex].autostartId
                                            }
                                        }
                                    }

                                    QGCComboBox {
                                        id:                     combo
                                        objectName:             modelData.airframeType + "ComboBox"
                                        anchors.leftMargin:     parent.width*0.2
                                        anchors.rightMargin:    parent.width*0.2
                                        anchors.bottomMargin:   parent.height*0.02
                                        anchors.bottom:         parent.bottom
                                        anchors.left:           parent.left
                                        anchors.right:          parent.right
                                        model:                  modelData.airframes
                                        _showHighlight:         false
                                        Component.onCompleted: {
                                            if (airframeCheckBox.checked) {
                                                currentIndex = controller.currentVehicleIndex
                                            }
                                        }

                                        onActivated: {
                                            applyButton.primary = true
                                            airframeCheckBox.checked = true;
                                    console.log("combo change", index)
                                    controller.autostartId = modelData.airframes[index].autostartId
                                        }
                                    }
                                }
                            }
                        } // Repeater - summary boxes
                    } // Flow - summary boxes
                } //Fickable
            } // Column
        }// Rectangle
    }
}
