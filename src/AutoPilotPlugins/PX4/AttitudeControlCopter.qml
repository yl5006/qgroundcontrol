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
            //运动模式最大角度
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
                                            helpDialog.text= qsTr("运动模式最大角速度。")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("运动模式最大角速度")//
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
                                        resettodefault("MC_ACRO_P_MAX")
                                        resettodefault("MC_ACRO_R_MAX")
                                        resettodefault("MC_ACRO_Y_MAX")
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
                            model:  [ "MC_ACRO_P_MAX", "MC_ACRO_R_MAX", "MC_ACRO_Y_MAX"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("仰俯速度") , qsTr("横滚速度"), qsTr("航向速度") ]
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
                height:             ScreenTools.defaultFontPixelHeight*5
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
                                    text:   qsTr("手动油门限制")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("MPC_MANTHR_MAX")
                                        resettodefault("MPC_MANTHR_MIN")
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
                            model:  [ "MPC_MANTHR_MAX", "MPC_MANTHR_MIN"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("最大油门") , qsTr("最小油门")]
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
                                    text:   qsTr("自稳增益")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("MC_PITCH_P")
                                        resettodefault("MC_ROLL_P")
                                        resettodefault("MC_YAW_P")
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
                            model:  [ "MC_PITCH_P", "MC_ROLL_P", "MC_YAW_P"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("Pitch增益") , qsTr("Roll增益"), qsTr("Yaw增益") ]
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
                                            helpDialog.text= qsTr("这限制控制器输出最大仰角速率（度每秒）。设置零值禁用限制")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("最大角速度")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("MC_PITCHRATE_MAX")
                                        resettodefault("MC_ROLLRATE_MAX")
                                        resettodefault("MC_YAWRATE_MAX")
                                        resettodefault("MC_YAWRAUTO_MAX")
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
                            model:  ["MC_PITCHRATE_MAX", "MC_ROLLRATE_MAX", "MC_YAWRATE_MAX", "MC_YAWRAUTO_MAX"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("Pitch速度") , qsTr("Roll速度") , qsTr("Yaw速度"), qsTr("自动模式下Yaw速度")]
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
                                        helpDialog.text= qsTr("自动降落设置参数如左示意图\n 降落油门限位高度:（相对高度）默认-1.0 表示让系统应用油门限制在2/3的平飘高度限制。\n方向锁定水平距离:我们希望在飞机上保持跟踪期望的飞行路径，直到我们开始平飘，如果我们进入航向保持模式较早那么我们的风险是从跑道由横风推开\n最小空速*系数:进场空速=最小空速*该系数")
                                        helpDialog.visible=true
                                    }
                                }
                            }
                            QGCLabel {
                                anchors.verticalCenter:     parent.verticalCenter
                                width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                text:   qsTr("手动最大角度")//
                                color:                      qgcPal.primaryButton
                            }
                            SubMenuButton {
                                width:  _buttonWidth
                                text:   qsTr("恢复默认")   //reset to default
                                showcolor:   false
                                imageResource:  "/qmlimages/paramsreset.svg"
                                imgcolor:   qgcPal.buttonHighlight
                                onClicked: {
                                    resettodefault("MPC_MAN_TILT_MAX")
                                    resettodefault("MPC_MAN_Y_MAX")
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
                        model:  [ "MPC_MAN_TILT_MAX", "MPC_MAN_Y_MAX"]
                        Column{
                            Row {
                                spacing: ScreenTools.defaultFontPixelHeight
                                property var description: [ qsTr("空中倾斜角度") , qsTr("Yaw速率")]
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
                                            helpDialog.text= qsTr("P(比例)值设置\nI(积分)\nIMAX(积分部的部分被限制在这个值)\n前反馈:直接速率输出到控制舵面")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("Pitch速度")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("MC_PITCHRATE_P")
                                        resettodefault("MC_PITCHRATE_I")
                                        resettodefault("MC_PITCHRATE_D")
                                        resettodefault("MC_PITCHRATE_FF")
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
                            model:  ["MC_PITCHRATE_P", "MC_PITCHRATE_I", "MC_PITCHRATE_D", "MC_PITCHRATE_FF"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("P") , qsTr("I") , qsTr("D"), qsTr("前反馈") ]
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
                                            helpDialog.text= qsTr("P(比例)值设置\nI(积分)\nIMAX(积分部的部分被限制在这个值)\n前反馈:直接速率输出到控制舵面")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("Roll速度")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("MC_ROLLRATE_P")
                                        resettodefault("MC_ROLLRATE_I")
                                        resettodefault("MC_ROLLRATE_D")
                                        resettodefault("MC_ROLLRATE_FF")
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
                            model:  ["MC_ROLLRATE_P", "MC_ROLLRATE_I", "MC_ROLLRATE_D", "MC_ROLLRATE_FF"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("P") , qsTr("I") , qsTr("D"), qsTr("前反馈") ]
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
                                            helpDialog.text= qsTr("P(比例)值设置\nI(积分)\nIMAX(积分部的部分被限制在这个值)\n前反馈:直接速率输出到控制舵面")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("Yaw速度")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("MC_YAWRATE_P")
                                        resettodefault("MC_YAWRATE_I")
                                        resettodefault("MC_YAWRATE_D")
                                        resettodefault("MC_YAWRATE_FF")
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
                            model:  ["MC_YAWRATE_P", "MC_YAWRATE_I", "MC_YAWRATE_D", "MC_YAWRATE_FF"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("P") , qsTr("I") , qsTr("D"), qsTr("前反馈") ]
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
