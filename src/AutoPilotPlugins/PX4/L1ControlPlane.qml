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

    MessageDialog {
        id:         helpDialog
        visible:    false
        icon:       StandardIcon.Question
        standardButtons: StandardButton.Ok
        title:      qsTr("帮助")//"Clear Settings"
        modality:   Qt.ApplicationModal
        text:       qsTr("在全手动模式下的舵机命令比例因子，此参数可以调整投控制面。")//"All saved settings will be reset the next time you start QGroundControl. Is this really what you want?"
        onYes: {
            helpDialog.visible = false
        }
    }

    property real _editFieldWidth:              ScreenTools.defaultFontPixelWidth * 16
    property real _buttonWidth:                 ScreenTools.defaultFontPixelWidth * 14

    Column{
        id:       column
        spacing: ScreenTools.defaultFontPixelHeight
        anchors.horizontalCenter: parent.horizontalCenter
        Row{
            spacing: ScreenTools.defaultFontPixelHeight*8
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
                                    MouseArea{
                                        anchors.fill:    parent
                                        onClicked: {
                                            helpDialog.text= qsTr("自动降落设置参数如左示意图\n 降落油门限位高度:（相对高度）默认-1.0 表示让系统应用油门限制在2/3的平飘高度限制。\n方向锁定水平距离:我们希望在飞机上保持跟踪期望的飞行路径，直到我们开始平飘，如果我们进入航向保持模式较早那么我们的风险是从跑道由横风推开\n最小空速*系数:进场空速=最小空速*该系数")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("降落设置")//
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
                                        resettodefault("FW_LND_ANG")
                                        resettodefault("FW_LND_HVIRT")
                                        resettodefault("FW_LND_FLALT")
                                        resettodefault("FW_LND_FL_PMIN")
                                        resettodefault("FW_LND_FL_PMAX")
                                        resettodefault("FW_LND_TLALT")
                                        resettodefault("FW_LND_USETER")
                                        resettodefault("FW_LND_HHDIST")
                                        resettodefault("FW_LND_AIRSPD_SC")

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
                            model:  [ "FW_LND_ANG", "FW_LND_HVIRT", "FW_LND_FLALT", "FW_LND_FL_PMIN", "FW_LND_FL_PMAX", "FW_LND_TLALT",  "FW_LND_HHDIST", "FW_LND_AIRSPD_SC"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("降落角度") , qsTr("H1虚拟高度") , qsTr("降落平飘高度") , qsTr("最小Pitch"), qsTr("最大Pitch"), qsTr("油门限制高度"), qsTr("方向锁定水平距离"), qsTr("最小空速*系数")]
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
                        Column{
                            Row {
                                spacing: ScreenTools.defaultFontPixelHeight
                                property Fact fact: controller.getParameterFact(-1, "FW_LND_USETER")
                                QGCLabel {
                                    width:              _editFieldWidth
                                    text:               qsTr("地形预估")
                                }

                                FactComboBox {
                                    fact:               parent.fact
                                    width:              _buttonWidth
                                    _showHighlight:     false
                                    indexModel:         false
                                    colortext:          parent.fact.defaultValueAvailable ? (parent.fact.valueEqualsDefault ? qgcPal.text : qgcPal.buttonHighlight) : qgcPal.text
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
            Image {
                anchors.verticalCenter: parent.verticalCenter
                height:             parent.height
                fillMode:           Image.PreserveAspectFit
                smooth:             true
                mipmap:             true
                source:             "/qmlimages/fw_landing.png"
            }
        }
        Row{
            spacing: ScreenTools.defaultFontPixelHeight*8
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
                                    MouseArea{
                                        anchors.fill:    parent
                                        onClicked: {
                                            helpDialog.text= qsTr("姿态输出限制")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("姿态限制")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_P_LIM_MIN")
                                        resettodefault("FW_P_LIM_MAX")
                                        resettodefault("FW_R_LIM")
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
                            model:  [ "FW_P_LIM_MIN", "FW_P_LIM_MAX", "FW_R_LIM"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("负Pitch限制") , qsTr("正Pitch限制") , qsTr("Roll限制")]
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
                                    MouseArea{
                                        anchors.fill:    parent
                                        onClicked: {
                                            helpDialog.text= qsTr("油门输出设置")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("油门设置")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_THR_MIN")
                                        resettodefault("FW_THR_MAX")
                                        resettodefault("FW_THR_IDLE")
                                        resettodefault("FW_THR_SLEW_MAX")
                                        resettodefault("FW_THR_LND_MAX")
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
                            model:  [ "FW_THR_MIN", "FW_THR_MAX", "FW_THR_IDLE","FW_THR_SLEW_MAX", "FW_THR_LND_MAX"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("最小油门") , qsTr("最大油门") , qsTr("空闲油门"), qsTr("油门压摆率"), qsTr("平飘前降落最大油门")]
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
        }
    }
}// QGCViewPanel
