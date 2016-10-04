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
        text:       qsTr("")//"All saved settings will be reset the next time you start QGroundControl. Is this really what you want?"
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
        Rectangle {
            width:    parent.width*0.8
            height:   ScreenTools.defaultFontPixelWidth*20
            color:      "transparent"
            QGCLabel {
                anchors.centerIn:   parent
                text:   qsTr("* - 融合速度和高度，用油门来控制总能量和俯仰角来控制势能和动能可选择的速度或高度优先模式之间的能量交换计算俯仰角\n
* - 后备模式，当没有空速测量是可用的根据身高速率要求设置油门开关和俯仰角控制，以高度优先\n
* - 低速保护，要求最大油门切换俯仰角控制速度优先模式\n
* - 通过使用直观的时间常数的调整，相对容易一些，修剪率和阻尼参数和使用容易衡量飞机性能数据")//
            }
        }

        Row{
            spacing: ScreenTools.defaultFontPixelHeight*4
            //空速设置
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
                                            helpDialog.text= qsTr("固定机翼尝试在这个空速飞行，逆风下节省电力")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("空速设置")//
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
                                        resettodefault("FW_AIRSPD_MIN")
                                        resettodefault("FW_AIRSPD_MAX")
                                        resettodefault("FW_AIRSPD_TRIM")
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
                            model:  [ "FW_AIRSPD_MIN", "FW_AIRSPD_MAX", "FW_AIRSPD_TRIM"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("最小空速") , qsTr("最大空速"), qsTr("巡航空速") ]
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
            //升降速度设置
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
                                            helpDialog.text= qsTr("这是最好的爬升率，飞机可以与油门设置为最大油门和空速设定为缺省值实现的。保证在电量减少前执行完飞行任务。此参数的设置可以通过指挥爬升百米高度悬停，返航或引导模式进行检查。如果爬所需的油门接近最大油门，飞机保持着空速，那么这个参数设置是否正确。如果空速开始减少，则该参数被设置为高，并且如果攀登和保持速度所需的油门要求是明显比最大小于油门，然后或者最大爬升率应增加或最大油门减小。
\n 最大降落速度：如果该值过大，飞机可能高速降落。这应该被设置为可以在不超过最低的pitch角和超速")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("升降速度设置")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_T_CLMB_MAX")
                                        resettodefault("FW_T_SINK_MAX")
                                        resettodefault("FW_T_SINK_MIN")
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
                            model:  [ "FW_T_CLMB_MAX", "FW_T_SINK_MAX", "FW_T_SINK_MIN"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("最大爬升速度") , qsTr("最大下降速度"), qsTr("最小下降速度") ]
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

            //时间常数设置
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
                                            helpDialog.text= qsTr("较小的值使其更快响应，较大的值使其慢回应。")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("时间常数设置")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_T_TIME_CONST")
                                        resettodefault("FW_T_THRO_CONST")
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
                            model:  [ "FW_T_TIME_CONST", "FW_T_THRO_CONST"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("算法时间常数") , qsTr("油门时间常数") ]
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
            //阻尼系数设置
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
                                            helpDialog.text= qsTr("这是为了油门要求环路阻尼增益。以校正在速度和高度振荡。\n这是桨距需求量环路阻尼增益，以校正在高度振荡。0.0的默认值将正常工作提供的仰伺服控制器")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("阻尼系数设置")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_T_THR_DAMP")
                                        resettodefault("FW_T_PTCH_DAMP")
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
                            model:  [ "FW_T_THR_DAMP", "FW_T_PTCH_DAMP"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("油门系数") , qsTr("Pitch系数") ]
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

        Row{
            spacing: ScreenTools.defaultFontPixelHeight*4
            //系数设置
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
                                            helpDialog.text= qsTr("这是在交叉频率（弧度/秒），用于融合垂直加速度和气压高度，以获得高度率和高度的估计互补滤波器。增加此频率权重的解决方案更倾向于使用气压的计，同时降低其权重的解决方案更倾向于使用加速度计数据\n这是在交叉频率（弧度/秒），用于融合纵向加速度和空速，以获得改善的空速估计互补滤波器。增加此频率权重的解决方案更倾向于使用空速传感器，同时降低其权重的解决方案更倾向于使用加速度计的数据。")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("系数设置")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_T_HGT_OMEGA")
                                        resettodefault("FW_T_SPD_OMEGA")
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
                            model:  [ "FW_T_HGT_OMEGA", "FW_T_SPD_OMEGA"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("高度滤波器OMEGA") , qsTr("速度滤波器OMEGA") ]
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
            //爬升高度差
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
                                            helpDialog.text= qsTr("如果该高度误差超过该参数时，系统将爬出最大油门和最小空速直到它比该距离更接近期望的高度。主要用于起飞航点/模式。\n设置为0禁用爬升模式（不推荐）。")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("高度")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_T_VERT_ACC")
                                        resettodefault("FW_CLMBOUT_DIFF")
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
                            model:  [ "FW_T_VERT_ACC", "FW_CLMBOUT_DIFF"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("垂直加速度") , qsTr("起飞至高度差") ]
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
            //比重设置
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
                                            helpDialog.text= qsTr("增加该增益反过来增加，这将被用于补偿由转动产生的额外的阻力油门的量。理想情况下这应该被设定为约10×额外的下沉速度米每秒用45度坡度的转弯创建/。增加此增益如果飞机开始轮流失去能量，减少如果飞机开始轮流获得能量。有效的高宽比飞机（如供电滑翔机）可以使用一个较低的值，而低效率的低纵横比模型（例如三角翼）可以使用一个更高的值。\n\n此参数调整权重的变桨距控制适用于速度VS高度误差量。它设置为0.0将使音高控制来控制高度和速度忽略的错误。这通常会提高高程精度，但给大空速误差。将其设置为2.0将使音高控制回路来控制速度，而忽略高度误差。这通常减少空速误差，但给予更大的高度误差。的默认值1.0允许桨距控制来同时控制高度和速度。注意滑翔机飞行员 - 这个参数设置为2.0（滑翔机将其调整俯仰角度保持空速，忽略了高度的变化）。")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("优先级设置")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_T_RLL2THR")
                                        resettodefault("FW_T_SPDWEIGHT")
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
                            model:  [ "FW_T_RLL2THR", "FW_T_SPDWEIGHT"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("Roll->油门前馈") , qsTr("速度<->高度优先") ]
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
            //控制设置
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
                                            helpDialog.text= qsTr("比例控制")
                                            helpDialog.visible=true
                                        }
                                    }
                                }
                                QGCLabel {
                                    anchors.verticalCenter:     parent.verticalCenter
                                    width:  _editFieldWidth-ScreenTools.defaultFontPixelHeight*1.5
                                    text:   qsTr("控制设置")//
                                    color:                      qgcPal.primaryButton
                                }
                                SubMenuButton {
                                    width:  _buttonWidth
                                    text:   qsTr("恢复默认")   //reset to default
                                    showcolor:   false
                                    imageResource:  "/qmlimages/paramsreset.svg"
                                    imgcolor:   qgcPal.buttonHighlight
                                    onClicked: {
                                        resettodefault("FW_T_INTEG_GAIN")
                                        resettodefault("FW_T_HRATE_P")
                                        resettodefault("FW_T_HRATE_FF")
                                        resettodefault("FW_T_SRATE_P")
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
                            model:  [ "FW_T_INTEG_GAIN", "FW_T_HRATE_P", "FW_T_HRATE_FF", "FW_T_SRATE_P"]
                            Column{
                                Row {
                                    spacing: ScreenTools.defaultFontPixelHeight
                                    property var description: [ qsTr("积分增益"), qsTr("高度P"), qsTr("高度前反馈"), qsTr("速度P") ]
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

    }// QGCViewPanel
}
