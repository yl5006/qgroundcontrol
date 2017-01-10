import QtQuick          2.5
import QtQuick.Controls 1.3
import QtQuick.Layouts  1.2

import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0

/// Mission item Set control
Rectangle {
    id:      _root
    height:  ScreenTools.defaultFontPixelHeight*20
    color:   qgcPal.windowShade
    width:   ScreenTools.defaultFontPixelHeight*40
    readonly property var       _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var    missionItems                ///< List of all available mission items

    readonly property real  _editFieldWidth:    Math.min(width - _margin * 2, ScreenTools.defaultFontPixelWidth * 16)
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius:            ScreenTools.defaultFontPixelWidth / 2
    MouseArea {
        anchors.fill: parent
    }
    Component.onCompleted: clearcheck()
    function clearcheck() {
        for(var i = 0; i < reperter.count; i++)
            reperter.itemAt(i).btn.btncheck=false
    }

    Column {
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
                text:               qsTr("批量选择航点")//"Alt diff"// + _altText
            }
        }
        QGCCheckBox{
            text:   qsTr("全选")
            onClicked: {
                for(var i = 1; i < reperter.count; i++)
                {
                    reperter.itemAt(i).checked=checked
                }

            }
        }

        //        QGCFlickable {
        //            clip:               true
        //            width:              parent.width
        //            height:             parent.height -title.height
        //            contentHeight:      buttonFlow.height+ScreenTools.defaultFontPixelWidth*2
        //            contentWidth:       parent.width
        //            flickableDirection: Flickable.VerticalFlick
        Flow
        {
            id:             buttonFlow
            width:          parent.width
            spacing:        ScreenTools.defaultFontPixelWidth
            Repeater {
                id:         reperter
                model:       missionItems
                QGCButton {
                    width:         ScreenTools.defaultFontPixelHeight*2
                    height:        ScreenTools.defaultFontPixelHeight*2
                    text:          object.abbreviation
                    visible:       index>0
                    checkable:     true
                }
            }
        }
    }
}// Rectangle
