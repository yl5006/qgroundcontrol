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
    id:                 att
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

    MessageDialog {
        id:         helpDialog
        visible:    false
        icon:       StandardIcon.Question
        standardButtons: StandardButton.Ok
        title:      qsTr("帮助")//"Clear Settings"
        modality:   Qt.ApplicationModal
        text:       qsTr("")//"All saved settings will be reset the next time you start QGroundControl. Is this really what you want?"
        onYes: {
            helpDialog.visible = false
        }
    }
    //---------------------------------------------

    Column{
        id:       column
        spacing: ScreenTools.defaultFontPixelHeight
        anchors.horizontalCenter: parent.horizontalCenter
        Row{
            spacing: ScreenTools.defaultFontPixelHeight
            //姿态最大角度
            Column{
                spacing: ScreenTools.defaultFontPixelHeight


            Rectangle {
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                width:              _editFieldWidth+_buttonWidth+ScreenTools.defaultFontPixelHeight
                height:             ScreenTools.defaultFontPixelHeight*6
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
                                            helpDialog.text= qsTr("自稳模式下手动控制最大角度。")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("姿态最大角度")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_MAN_P_MAX")
                                        resettodefault("FW_MAN_R_MAX")
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
                            model:  [ "FW_MAN_P_MAX", "FW_MAN_R_MAX"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("Pitch") , qsTr("Roll") ]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _buttonWidth
                                        text:               parent.description[index]
                                    }

                                    FactTextField {
                                        showUnits:          true
                                        fact:               parent.fact
                                        width:              _editFieldWidth
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
                height:             ScreenTools.defaultFontPixelHeight*6
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
                                            helpDialog.text= qsTr("一个机体特定度设定点的偏移，应该符合机身的典型的巡航速度。")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("设定点偏移")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_PSP_OFF")
                                        resettodefault("FW_RSP_OFF")
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
                            model:  [ "FW_PSP_OFF", "FW_RSP_OFF"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("Pitch") , qsTr("Roll") ]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _buttonWidth
                                        text:               parent.description[index]
                                    }
                                    FactTextField {
                                        showUnits:          true
                                        fact:               parent.fact
                                        width:              _editFieldWidth
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

  /*          Rectangle {
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                width:              _editFieldWidth+_buttonWidth+ScreenTools.defaultFontPixelHeight
                height:             ScreenTools.defaultFontPixelHeight*6
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
                                            helpDialog.text= qsTr("方法设置用于计算航向Yaw(转弯)速度方法：开环 零横向加速度基于运动学约束  闭环：尝试通过测量加速度，以减少横向加速度为0。\n
最小空速：高于此值航向(Yaw)计算要协调转弯。设置为非常高的值以禁止")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("协调航向")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_YCO_METHOD")
                                        resettodefault("FW_YCO_VMIN")
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
                        Row {
                            spacing: ScreenTools.defaultFontPixelHeight
                            property Fact fact: controller.getParameterFact(-1, "FW_YCO_METHOD")
                            QGCLabel {
                                width:              _buttonWidth
                                text:               qsTr("方法")
                            }
                            FactComboBox {
                                id:                 camTrigCombo
                                width:              _editFieldWidth
                                fact:               parent.fact
                                _showHighlight:     false
                                indexModel:         false
                                colortext:          parent.fact.defaultValueAvailable ? (parent.fact.valueEqualsDefault ? qgcPal.text : qgcPal.buttonHighlight) : qgcPal.text
                            }
                        }Rectangle {
                            width:  parent.width
                            height: ScreenTools.defaultFontPixelWidth/4
                            color:   "#698596"
                        }
                        Row {
                            spacing: ScreenTools.defaultFontPixelHeight
                            property Fact fact: controller.getParameterFact(-1, "FW_YCO_VMIN")
                            QGCLabel {
                                width:              _buttonWidth
                                text:               qsTr("最小空速")
                            }
                            FactTextField {
                                showUnits:          true
                                fact:               parent.fact
                                width:              _editFieldWidth
                                showbg:             false
                                textColor:          parent.fact.defaultValueAvailable ? (parent.fact.valueEqualsDefault ? qgcPal.text : qgcPal.buttonHighlight) : qgcPal.text
                            }
                        }
                        Rectangle {
                            width:  parent.width
                            height: ScreenTools.defaultFontPixelWidth/4
                            color:   "#698596"
                        }
                        // Repeater
                    }
                }
            }*/
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
                                            helpDialog.text= qsTr("这限制控制器输出最大仰角速率（度每秒）。设置零值禁用限制")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("最大输出角速度")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_P_RMAX_POS")
                                        resettodefault("FW_P_RMAX_NEG")
                                        resettodefault("FW_R_RMAX")
                                        resettodefault("FW_Y_RMAX")
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
                            model:  ["FW_P_RMAX_POS", "FW_P_RMAX_NEG", "FW_R_RMAX", "FW_Y_RMAX"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("Pitch正/上") , qsTr("Pitch负/下") , qsTr("Roll"), qsTr("Yaw")]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _buttonWidth
                                        text:               parent.description[index]
                                    }
                                    FactTextField {
                                        showUnits:          true
                                        fact:               parent.fact
                                        width:              _editFieldWidth
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
            height:             ScreenTools.defaultFontPixelHeight*9
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
                                        helpDialog.text=   qsTr("在全手动模式下的舵机命令比例因子，此参数可以调整投控制面。")
                                        helpDialog.visible=true
                                    }
                                }
                            }
                            QGCLabel {
                                anchors.verticalCenter:     parent.verticalCenter
                                width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                text:   qsTr("手动输入行程")//
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
                                    resettodefault("FW_MAN_P_SC")
                                    resettodefault("FW_MAN_R_SC")
                                    resettodefault("FW_MAN_Y_SC")
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
                        model:  [ "FW_MAN_P_SC", "FW_MAN_R_SC", "FW_MAN_Y_SC"]
                        Column{
                            Row {
                                spacing: ScreenTools.defaultFontPixelHeight
                                property var description: [ qsTr("Pitch") , qsTr("Roll") , qsTr("Yaw") ]
                                property Fact fact: controller.getParameterFact(-1, modelData)
                                QGCLabel {
                                    width:              _buttonWidth
                                    text:               parent.description[index]
                                }

                                FactTextField {
                                    showUnits:          true
                                    fact:               parent.fact
                                    width:              _editFieldWidth
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
        Rectangle {
            width:              pid.width
            height:             ScreenTools.defaultFontPixelHeight*2
            color:             qgcPal.buttonHighlight
            QGCLabel {
                anchors.centerIn:   parent
                text:   qsTr("回环控制")//
            }
        }


        Row{
            id:    pid
            spacing: ScreenTools.defaultFontPixelHeight

            Rectangle {
                anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                width:              _editFieldWidth+_buttonWidth+ScreenTools.defaultFontPixelHeight
                height:             ScreenTools.defaultFontPixelHeight*11
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
                                            helpDialog.text= qsTr("P(比例)值设置\nI(积分)\nIMAX(积分部的部分被限制在这个值)\n前反馈:直接速率输出到控制舵面")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("Pitch")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_PR_P")
                                        resettodefault("FW_PR_I")
                                        resettodefault("FW_PR_IMAX")
                                        resettodefault("FW_PR_FF")
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
                            model:  ["FW_PR_P", "FW_PR_I", "FW_PR_IMAX", "FW_PR_FF"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("P") , qsTr("I") , qsTr("IMAX"), qsTr("前反馈") ]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _buttonWidth
                                        text:               parent.description[index]
                                    }
                                    FactTextField {
                                        showUnits:          true
                                        fact:               parent.fact
                                        width:              _editFieldWidth
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
                height:             ScreenTools.defaultFontPixelHeight*11
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
                                            helpDialog.text= qsTr("P(比例)值设置\nI(积分)\nIMAX(积分部的部分被限制在这个值)\n前反馈:直接速率输出到控制舵面")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("Roll")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_RR_P")
                                        resettodefault("FW_RR_I")
                                        resettodefault("FW_RR_IMAX")
                                        resettodefault("FW_RR_FF")
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
                            model:  ["FW_RR_P", "FW_RR_I", "FW_RR_IMAX", "FW_RR_FF"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("P") , qsTr("I") , qsTr("IMAX"), qsTr("前反馈") ]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _buttonWidth
                                        text:               parent.description[index]
                                    }
                                    FactTextField {
                                        showUnits:          true
                                        fact:               parent.fact
                                        width:              _editFieldWidth
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
                height:             ScreenTools.defaultFontPixelHeight*11
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
                                            helpDialog.text= qsTr("P(比例)值设置\nI(积分)\nIMAX(积分部的部分被限制在这个值)\n前反馈:直接速率输出到控制舵面")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("Yaw")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_YR_P")
                                        resettodefault("FW_YR_I")
                                        resettodefault("FW_YR_IMAX")
                                        resettodefault("FW_YR_FF")
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
                            model:  ["FW_YR_P", "FW_YR_I", "FW_YR_IMAX", "FW_YR_FF"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("P") , qsTr("I") , qsTr("IMAX"), qsTr("前反馈") ]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _buttonWidth
                                        text:               parent.description[index]
                                    }
                                    FactTextField {
                                        showUnits:          true
                                        fact:               parent.fact
                                        width:              _editFieldWidth
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
                height:             ScreenTools.defaultFontPixelHeight*11
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
                                            helpDialog.text= qsTr("P(比例)值设置\nI(积分)\nIMAX(积分部的部分被限制在这个值)\n前反馈:直接速率输出到控制舵面")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("Wheel")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_WR_P")
                                        resettodefault("FW_WR_I")
                                        resettodefault("FW_WR_IMAX")
                                        resettodefault("FW_WR_FF")
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
                            model:   ["FW_WR_P", "FW_WR_I", "FW_WR_IMAX", "FW_WR_FF"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("P") , qsTr("I") , qsTr("IMAX"), qsTr("前反馈") ]
                                    property Fact fact: controller.getParameterFact(-1, modelData)
                                    QGCLabel {
                                        width:              _buttonWidth
                                        text:               parent.description[index]
                                    }
                                    FactTextField {
                                        showUnits:          true
                                        fact:               parent.fact
                                        width:              _editFieldWidth
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
