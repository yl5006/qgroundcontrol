/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.5
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtQuick.Dialogs          1.1

import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0


QGCFlickable {
    clip:               true
    width:              parent.width
    height:             parent.height -ScreenTools.defaultFontPixelWidth*20
    contentHeight:      column.height
    contentWidth:       parent.width
    flickableDirection: Flickable.VerticalFlick

    QGCPalette { id: qgcPal }

    property Fact   fact
    function resettodefault(factstring) {
        fact=controller.getParameterFact(-1, factstring)
        fact.value = fact.defaultValue
        fact.valueChanged(fact.value)
    }

    property real _editFieldWidth:              ScreenTools.defaultFontPixelWidth * 16
    property real _buttonWidth:                 ScreenTools.defaultFontPixelWidth * 14

    Column{
        id:       column
        spacing: ScreenTools.defaultFontPixelHeight/2
        anchors.horizontalCenter: parent.horizontalCenter
        QGCLabel {
            anchors.horizontalCenter:     parent.horizontalCenter
            text:              qsTr("该栏参数需重新启动飞机！")//
            color:             qgcPal.warningText
        }
        Row{
            spacing: ScreenTools.defaultFontPixelHeight*2

            Rectangle {
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                width:              _editFieldWidth+_buttonWidth+ScreenTools.defaultFontPixelHeight
                height:             ScreenTools.defaultFontPixelHeight*8
                color:              "transparent"// qgcPal.windowShadeDark
                Column{
                    anchors.fill: parent
                    anchors.margins:  ScreenTools.defaultFontPixelHeight*0.3
                    spacing: ScreenTools.defaultFontPixelHeight*0.3
                    Rectangle {      //-----------------------------------------------------------------
                        width:  parent.width
                        height: reset.height+ScreenTools.defaultFontPixelWidth/2
                        color:        "transparent"//      qgcPal.buttonHighlight
                        Column{
                            Row {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCColoredImage{
                                    color:                      qgcPal.primaryButton
                                    width:                      ScreenTools.defaultFontPixelHeight*1.5
                                    height:                     width
                                    sourceSize.height:          width
                                    mipmap:                     true
                                    source:                     "/qmlimages/paramshelp.svg"
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("主通道输出")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    id:     reset
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("PWM_MAX")
                                        resettodefault("PWM_MIN")
                                        resettodefault("PWM_DISARMED")
                                    }
                                }
                            }
                            Rectangle {
                                width:  parent.width
                                height: ScreenTools.defaultFontPixelWidth/2
                                color:   "#698596"
                            }
                        }
                    }
                    Column{
                        spacing: ScreenTools.defaultFontPixelHeight*0.3
                        Repeater {
                            model:  [ "PWM_MAX", "PWM_MIN", "PWM_DISARMED"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("PWM最大值") , qsTr("PWM最小值"), qsTr("加锁值")]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _editFieldWidth
                                        text:               parent.description[index]
                                    }

                                    FactTextField {
                                        showUnits:          true
                                        fact:               parent.fact
                                        width:              _buttonWidth
                                        showbg:             false
                                        textColor:          parent.fact.defaultValueAvailable ? (parent.fact.valueEqualsDefault ? qgcPal.text : qgcPal.buttonHighlight) : qgcPal.text
                                    }
                                }Rectangle {
                                    width:  parent.width
                                    height: ScreenTools.defaultFontPixelWidth/4
                                    color:   "#698596"
                                }// Repeater
                            }
                        }
                    }
                }
            }
            /*
            Rectangle {
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                width:              _editFieldWidth+_buttonWidth+ScreenTools.defaultFontPixelHeight
                height:             ScreenTools.defaultFontPixelHeight*10
                color:              "transparent"// qgcPal.windowShadeDark
                Column{
                    anchors.fill: parent
                    anchors.margins:  ScreenTools.defaultFontPixelHeight*0.3
                    spacing: ScreenTools.defaultFontPixelHeight*0.3
                    Rectangle {      //-----------------------------------------------------------------
                        width:  parent.width
                        height: reset.height+ScreenTools.defaultFontPixelWidth/2
                        color:        "transparent"//      qgcPal.buttonHighlight
                        Column{
                            Row {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCColoredImage{
                                    color:                      qgcPal.primaryButton
                                    width:                      ScreenTools.defaultFontPixelHeight*1.5
                                    height:                     width
                                    sourceSize.height:          width
                                    mipmap:                     true
                                    source:                     "/qmlimages/paramshelp.svg"
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("辅通道输出")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("PWM_AUX_MAX")
                                        resettodefault("PWM_AUX_MIN")
                                        resettodefault("PWM_AUX_DISARMED")
                                    }
                                }
                            }
                            Rectangle {
                                width:  parent.width
                                height: ScreenTools.defaultFontPixelWidth/2
                                color:   "#698596"
                            }
                        }
                    }
                    Column{
                        spacing: ScreenTools.defaultFontPixelHeight*0.3
                        Repeater {
                            model:  [ "PWM_AUX_MAX", "PWM_AUX_MIN", "PWM_AUX_DISARMED"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("PWM最大值") , qsTr("PWM最小值"), qsTr("加锁值")]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _editFieldWidth
                                        text:               parent.description[index]
                                    }

                                    FactTextField {
                                        showUnits:          true
                                        fact:               parent.fact
                                        width:              _buttonWidth
                                        showbg:             false
                                        textColor:          parent.fact.defaultValueAvailable ? (parent.fact.valueEqualsDefault ? qgcPal.text : qgcPal.buttonHighlight) : qgcPal.text
                                    }
                                }Rectangle {
                                    width:  parent.width
                                    height: ScreenTools.defaultFontPixelWidth/4
                                    color:   "#698596"
                                }// Repeater
                            }
                        }
                    }
                }
            }*/
        }
        Row{
            spacing: ScreenTools.defaultFontPixelHeight*2

            Rectangle {
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                width:              _editFieldWidth+_buttonWidth+ScreenTools.defaultFontPixelHeight
                height:             ScreenTools.defaultFontPixelHeight*20
                color:              "transparent"// qgcPal.windowShadeDark
                Column{
                    anchors.fill: parent
                    anchors.margins:  ScreenTools.defaultFontPixelHeight*0.3
                    spacing: ScreenTools.defaultFontPixelHeight*0.3
                    Rectangle {      //-----------------------------------------------------------------
                        width:  parent.width
                        height: reset.height+ScreenTools.defaultFontPixelWidth/2
                        color:        "transparent"//      qgcPal.buttonHighlight
                        Column{
                            Row {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCColoredImage{
                                    color:                      qgcPal.primaryButton
                                    width:                      ScreenTools.defaultFontPixelHeight*1.5
                                    height:                     width
                                    sourceSize.height:          width
                                    mipmap:                     true
                                    source:                     "/qmlimages/paramshelp.svg"
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("主输出通道反转")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("PWM_MAIN_REV1")
                                        resettodefault("PWM_MAIN_REV2")
                                        resettodefault("PWM_MAIN_REV3")
                                        resettodefault("PWM_MAIN_REV4")
                                        resettodefault("PWM_MAIN_REV5")
                                        resettodefault("PWM_MAIN_REV6")
                                        resettodefault("PWM_MAIN_REV7")
                                        resettodefault("PWM_MAIN_REV8")
                                    }
                                }
                            }
                            Rectangle {
                                width:  parent.width
                                height: ScreenTools.defaultFontPixelWidth/2
                                color:   "#698596"
                            }
                        }
                    }
                    Column{
                        spacing: ScreenTools.defaultFontPixelHeight*0.3
                        Repeater {
                            model:  [ "PWM_MAIN_REV1", "PWM_MAIN_REV2", "PWM_MAIN_REV3", "PWM_MAIN_REV4","PWM_MAIN_REV5", "PWM_MAIN_REV6", "PWM_MAIN_REV7", "PWM_MAIN_REV8"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("输出通道1") , qsTr("输出通道2"), qsTr("输出通道3"), qsTr("输出通道4"),qsTr("输出通道5") , qsTr("输出通道6"), qsTr("输出通道7"), qsTr("输出通道8")]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _editFieldWidth
                                        text:               parent.description[index]
                                    }
                                    FactComboBox {
                                        width:              _editFieldWidth
                                        fact:               parent.fact
                                        _showHighlight:     false
                                        indexModel:         false
                                    }
                                }Rectangle {
                                    width:  parent.width
                                    height: ScreenTools.defaultFontPixelWidth/4
                                    color:   "#698596"
                                }// Repeater
                            }
                        }
                    }
                }
            }
            Rectangle {
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                width:              _editFieldWidth+_buttonWidth+ScreenTools.defaultFontPixelHeight
                height:             ScreenTools.defaultFontPixelHeight*20
                color:              "transparent"// qgcPal.windowShadeDark
                Column{
                    anchors.fill: parent
                    anchors.margins:  ScreenTools.defaultFontPixelHeight*0.3
                    spacing: ScreenTools.defaultFontPixelHeight*0.3
                    Rectangle {      //-----------------------------------------------------------------
                        width:  parent.width
                        height: reset.height+ScreenTools.defaultFontPixelWidth/2
                        color:        "transparent"//      qgcPal.buttonHighlight
                        Column{
                            Row {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCColoredImage{
                                    color:                      qgcPal.primaryButton
                                    width:                      ScreenTools.defaultFontPixelHeight*1.5
                                    height:                     width
                                    sourceSize.height:          width
                                    mipmap:                     true
                                    source:                     "/qmlimages/paramshelp.svg"
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("辅输出通道反转")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("PWM_AUX_REV1")
                                        resettodefault("PWM_AUX_REV2")
                                        resettodefault("PWM_AUX_REV3")
                                        resettodefault("PWM_AUX_REV4")
                                        resettodefault("PWM_AUX_REV5")
                                        resettodefault("PWM_AUX_REV6")
                                    }
                                }
                            }
                            Rectangle {
                                width:  parent.width
                                height: ScreenTools.defaultFontPixelWidth/2
                                color:   "#698596"
                            }
                        }
                    }
                    Column{
                        spacing: ScreenTools.defaultFontPixelHeight*0.3
                        Repeater {
                            model:  [ "PWM_AUX_REV1", "PWM_AUX_REV2", "PWM_AUX_REV3", "PWM_AUX_REV4", "PWM_AUX_REV5", "PWM_AUX_REV6"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("输出通道1") , qsTr("输出通道2"), qsTr("输出通道3"), qsTr("输出通道4"), qsTr("输出通道5"), qsTr("输出通道6")]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _editFieldWidth
                                        text:               parent.description[index]
                                    }

                                    FactComboBox {
                                        width:              _editFieldWidth
                                        fact:               parent.fact
                                        _showHighlight:     false
                                        indexModel:         false
                                    }
                                }Rectangle {
                                    width:  parent.width
                                    height: ScreenTools.defaultFontPixelWidth/4
                                    color:   "#698596"
                                }// Repeater
                            }
                        }
                    }
                }
            }
        }
    }
}// QGCViewPanel
