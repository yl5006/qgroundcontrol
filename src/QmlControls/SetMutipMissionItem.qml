import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2

import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0

/// Mission item Set control
Rectangle {
    id:      _root
    height:  ScreenTools.defaultFontPixelHeight*30
    color:   qgcPal.windowShade
    width:   ScreenTools.defaultFontPixelHeight*42
    readonly property var       _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var    missionItems                ///< List of all available mission items
    property var    missionController
    property real   missionDistance:            missionController != undefined ? missionController.missionDistance : 0.1
    readonly property real  _editFieldWidth:    Math.min(width - _margin * 2, ScreenTools.defaultFontPixelWidth * 16)
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius:            ScreenTools.defaultFontPixelWidth / 2
    MouseArea {
        anchors.fill: parent
        onClicked: {
            forceActiveFocus()
        }
    }
    function clearcheck() {
        for(var i = 1; i < reperter.count; i++)
            reperter.itemAt(i).checked = false
        allcheck.checked=false
    }
    function setcheck() {
        for(var i = 1; i < reperter.count; i++)
        {
            if(reperter.itemAt(i).checked === true)
            {
                missionItems.get(i).applyNewAltitude(Number(altField.text));
                missionItems.get(i).param1=Number(timeField.text);
                missionItems.get(i).param3=Number(speedField.text);
            }
        }
    }
    Column {
        id:         column
        spacing: ScreenTools.defaultFontPixelHeight
        width:          parent.width*0.9
        anchors.top:            parent.top
        anchors.topMargin:      ScreenTools.defaultFontPixelHeight
        anchors.left:           parent.left
        anchors.leftMargin:     ScreenTools.defaultFontPixelHeight
        Rectangle {
            id:                 title
            height:             ScreenTools.defaultFontPixelHeight*2
            width:              parent.width
            color:              "transparent"
            Image{
                source:     "/qmlimages/safetitlebg.svg"
                width:      _editFieldWidth
                anchors.verticalCenter: parent.verticalCenter
            }
            QGCLabel {
                width:      _editFieldWidth
                anchors.left:           parent.left
                anchors.leftMargin:     ScreenTools.defaultFontPixelHeight
                anchors.verticalCenter: parent.verticalCenter
                text:               qsTr("批量修改航点")//"Alt diff"// + _altText
            }
        }
        Canvas {
            id:                 canvas
            height:             ScreenTools.defaultFontPixelHeight*10
            width:              parent.width

            function drawBackground(ctx) {        // 界面的绘制由onPaint开始，这是绘制背景的一个函数。ctx作为传参，类似C++中的painter
                       ctx.save();                                     // 保存之前绘制内容
                       ctx.fillStyle = "transparent";                      // 填充颜色，之所以叫Style是因为它还可以使用渐变等等...
                       ctx.fillRect(0, 0, canvas.width, canvas.height);  // fillRect是一个便利函数，用来填充一个矩形区域
                       ctx.strokeStyle = "white";                    // 描边颜色
                       ctx.beginPath();
                                                                        // 水平网格线
                       ctx.moveTo(0, canvas.height);
                       ctx.lineTo(canvas.width,canvas.height);

                       ctx.moveTo(0, canvas.height);
                       ctx.lineTo(0, canvas.height/20);
                                                                        // 垂直网格线
                       ctx.stroke();                                    // 描线

                       ctx.closePath();                                                     // 完成路径

                       ctx.restore();                                                     // 载入保存的内容
                   }
            function clearCanvas()
            {
                var ctx = getContext("2d");
                ctx.reset();
                canvas.requestPaint();
            }
            function drawAMSLAlt(ctx,missionItems)                      // 绘制右方股票价格标尺函数
            {
                ctx.save();
                ctx.strokeStyle = "green";
                ctx.beginPath();
                var addx = 0
                ctx.moveTo(0, canvas.height);
                for (var i = 0; i < missionItems.count; i ++) {            // 隔一级显示
                    var y = canvas.height - missionItems.get(i).altPercent * canvas.height
                    var x = missionItems.get(i).distance / missionDistance * canvas.width
                    addx = addx + x
                    ctx.lineTo(addx, y);
                }
                ctx.stroke();
                ctx.restore();
                ctx.closePath();
                ctx.save();
                ctx.beginPath();
                ctx.strokeStyle = "yellow";
                ctx.moveTo(0, canvas.height);
                addx = 0
                for (var i = 0; i < missionItems.count; i ++) {            // 隔一级显示
                    var y = canvas.height - missionItems.get(i).terrainPercent * canvas.height
                    var x = missionItems.get(i).distance / missionDistance * canvas.width
                    addx = addx + x
                    ctx.lineTo(addx, y);
                }
                ctx.stroke();
                ctx.closePath();
            }

            onPaint: {
                var context = getContext("2d")
                context.lineWidth = 2;
                drawBackground(context);                              // 背景绘制
                drawAMSLAlt(context,missionItems)
            }
        }
        QGCCheckBox{
            id:     allcheck
            text:   qsTr("全选")
            onClicked: {
                for(var i = 1; i < reperter.count; i++)
                {
                    reperter.itemAt(i).checked=checked
                }
               canvas.clearCanvas()
            }
        }
    }
    Row{
        anchors.top:        column.bottom
        anchors.topMargin:  ScreenTools.defaultFontPixelHeight
        anchors.left:       parent.left
        anchors.leftMargin: ScreenTools.defaultFontPixelHeight*2
        height:             parent.height -column.height-ScreenTools.defaultFontPixelHeight*4
        spacing:            ScreenTools.defaultFontPixelHeight
        QGCFlickable {
            clip:               true
            width:              ScreenTools.defaultFontPixelHeight*28
            height:             parent.height
            contentHeight:      buttonFlow.height+ScreenTools.defaultFontPixelWidth*2
            contentWidth:       ScreenTools.defaultFontPixelHeight*28
            flickableDirection: Flickable.VerticalFlick
            Flow
            {
                id:             buttonFlow
                width:          parent.width
                spacing:        ScreenTools.defaultFontPixelWidth
                Repeater {
                    id:          reperter
                    model:       missionItems
                    QGCButton {
                        width:         ScreenTools.defaultFontPixelHeight*2
                        height:        ScreenTools.defaultFontPixelHeight*2
                        text:          object.sequenceNumber
                        visible:       index>0
                        checkable:     true
                    }
                }
            }        // }
        }
        Rectangle {
            height:    parent.height
            width:     2
            color:     "grey"
        }
        Column {
            spacing:            ScreenTools.defaultFontPixelHeight
            anchors.verticalCenter: parent.verticalCenter
            Row{
                spacing:            ScreenTools.defaultFontPixelWidth
                QGCLabel {
                    width:          ScreenTools.defaultFontPixelHeight*5
                    text:            qsTr("高度m")
                }
                QGCTextField {
                    id:             altField
                    width:           ScreenTools.defaultFontPixelHeight*4
                    text:           "50"
                }
            }
            Row{
                spacing:            ScreenTools.defaultFontPixelWidth
                visible:            _activeVehicle&&!_activeVehicle.fixedWing
                QGCLabel {
                    width:          ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("停留时间s")
                }
                QGCTextField {
                    id:             timeField
                    width:          ScreenTools.defaultFontPixelHeight*4
                    text:           "0"
                }
            }
            Row{
                spacing:            ScreenTools.defaultFontPixelWidth
                QGCLabel {
                    width:          ScreenTools.defaultFontPixelHeight*5
                    text:           qsTr("飞行速度m/s")
                }
                QGCTextField {
                    id:             speedField
                    width:          ScreenTools.defaultFontPixelHeight*4
                    text:           "15"
                }
            }
            Row{
                spacing:           ScreenTools.defaultFontPixelHeight
                QGCButton {
                    width:         ScreenTools.defaultFontPixelHeight*4
                    height:        ScreenTools.defaultFontPixelHeight*2
                    text:          "确认修改"
                    checkable:     false
                    primary:       true
                    onClicked:  {
                        forceActiveFocus()
                        setcheck()
                        _root.visible=false
                        clearcheck()

                    }
                }
                QGCButton {
                    width:         ScreenTools.defaultFontPixelHeight*4
                    height:        ScreenTools.defaultFontPixelHeight*2
                    text:          "取消"
                    checkable:     false
                    primary:       true
                    onClicked:  {
                        forceActiveFocus()
                        clearcheck()
                        _root.visible=false
                    }
                }
            }
        }
    }
}// Rectangle
