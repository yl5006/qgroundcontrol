import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtQuick.Dialogs          1.2

import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl               1.0

/// Mission item edit control
Rectangle {
    id:      _root
    height: editorLoader.y + editorLoader.height + (_margin * 2)
    color:   Qt.rgba(0.102,0.122,0.133,0.9)//qgcPal.windowShade
    radius: _radius

    property var    missionItem ///< MissionItem associated with this editor
    property bool   readOnly    ///< true: read only view, false: full editing view
    property var    qgcView     ///< QGCView control used for showing dialogs

    signal remove
    signal insert(int i)
    signal moveHomeToMapCenter

    property bool   _currentItem:       missionItem.isCurrentItem
    property color  _outerTextColor:    "black"

    readonly property real  _editFieldWidth:    Math.min(width - _margin * 2, ScreenTools.defaultFontPixelWidth * 16)
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius:            ScreenTools.defaultFontPixelWidth / 2


    property real   _distance:          _statusValid ? missionItem.distance : 0
    property real   _altDifference:     _statusValid ? missionItem.altDifference : 0
    property real   _gradient:          _statusValid ? Math.atan(missionItem.altDifference / missionItem.distance) : 0
    property real   _gradientPercent:   isNaN(_gradient) ? 0 : _gradient * 100
    property real   _azimuth:           _statusValid ? missionItem.azimuth : -1
    property bool   _statusValid:       missionItem.command==16&&missionItem.sequenceNumber != 0&&missionItem != undefined
    property string _distanceText:      _distance<1000 ? QGroundControl.metersToAppSettingsDistanceUnits(_distance).toFixed(1) + QGroundControl.appSettingsDistanceUnitsString : QGroundControl.metersToAppSettingsDistanceUnits(_distance/1000).toFixed(2) + "k" + QGroundControl.appSettingsDistanceUnitsString
    property string _altText:           _statusValid ? QGroundControl.metersToAppSettingsDistanceUnits(_altDifference).toFixed(1)  + QGroundControl.appSettingsDistanceUnitsString : ""
    property string _gradientText:      _statusValid ? _gradientPercent.toFixed(0) + "%" : ""
    property string _azimuthText:       _statusValid ? " "+Math.round(_azimuth)+ "°" : ""


    MouseArea {
        anchors.fill:   parent
    }
    Rectangle {
        width:           parent.width
        anchors.top:     parent.top
        anchors.bottom:  distanceLabel.top
        anchors.bottomMargin: _margin
        color:     Qt.rgba(0.2,0.267,0.306,1)//qgcPal.windowShade
    }


    QGCLabel {
        id:                     label
        anchors.verticalCenter: commandPicker.verticalCenter
        anchors.leftMargin:     _margin*4
        font.pointSize:         ScreenTools.defaultFontPixelHeight*2
        font.bold:              true
        anchors.left:           parent.left
        text:                   missionItem.abbreviation
        color:                  Qt.rgba(1,0.675,0.290,1)
    }

    Image {
        id:                     insertpoint
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
        anchors.right:          parent.right
        anchors.verticalCenter: commandPicker.verticalCenter
        width:                  ScreenTools.defaultFontPixelHeight*2
        height:                 ScreenTools.defaultFontPixelHeight*2
        source:                 "qrc:/qmlimages/insertpoint.svg"
        visible:                missionItem.sequenceNumber != 0
        MouseArea {
                   anchors.fill: parent
                   onClicked: insert(missionItem.sequenceNumber)
                  }
    }
    Image {
        id:                     deletepoint
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth*2
        anchors.right:          insertpoint.left
        anchors.verticalCenter: commandPicker.verticalCenter
        width:                  ScreenTools.defaultFontPixelHeight*2
        height:                 ScreenTools.defaultFontPixelHeight*2
        source:                 "qrc:/qmlimages/deletepoint.svg"
        visible:                missionItem.sequenceNumber != 0
        MouseArea {
                   anchors.fill: parent
                   onClicked: remove()
                  }
    }

    QGCButton {
        id:                     commandPicker
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 2
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth * 2
        anchors.topMargin:      ScreenTools.defaultFontPixelWidth * 2
        anchors.top:            parent.top
        anchors.left:           label.right
        anchors.right:          deletepoint.left
        visible:                missionItem.sequenceNumber != 0 && missionItem.isCurrentItem && !missionItem.rawEdit && missionItem.isSimpleItem
        text:                   missionItem.commandName

        Component {
            id: commandDialog

            MissionCommandDialog {
                missionItem: _root.missionItem
            }
        }

        onClicked:              qgcView.showDialog(commandDialog, "Select Mission Command", qgcView.showDialogDefaultWidth, StandardButton.Cancel)
    }

    QGCLabel {
        anchors.fill:       commandPicker
        visible:            missionItem.sequenceNumber == 0 || !missionItem.isCurrentItem || !missionItem.isSimpleItem
        verticalAlignment:  Text.AlignVCenter
        text:               missionItem.sequenceNumber == 0 ? "Home Position" : (missionItem.isSimpleItem ? missionItem.commandName : "Survey")
        color:              _outerTextColor
    }
    QGCLabel {
        id:                 distanceLabel
        anchors.leftMargin: _margin*6
        anchors.topMargin:  _margin*4
        anchors.left:       parent.left
        anchors.top:        commandPicker.bottom
        color:              Qt.rgba(0.555,0.648,0.691,1)
        text:               qsTr("距离")//"Distance" //+ _distanceText
    }

    QGCLabel {
        id:                 altLabel
        anchors.verticalCenter: distanceLabel.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color:              Qt.rgba(0.555,0.648,0.691,1)
        text:               qsTr("高度差")//"Alt diff"// + _altText
    }

    QGCLabel {
        id:                 azimuthLabel
        anchors.verticalCenter: distanceLabel.verticalCenter
        anchors.right:          parent.right
        anchors.rightMargin: _margin*5
        color:              Qt.rgba(0.555,0.648,0.691,1)
        text:               qsTr("方位角")//"Azimuth" //+ _azimuthText
    }

    QGCLabel {
        id:                 distance
        anchors.horizontalCenter: distanceLabel.horizontalCenter
        anchors.topMargin:  _margin*2
        anchors.top:        distanceLabel.bottom
        font.pointSize:     ScreenTools.defaultFontPixelHeight
        font.bold:          true
        color:              Qt.rgba(0.102,0.887,0.609,1)
        text:               _distanceText
    }

    QGCLabel {
        id:                 alt
        anchors.horizontalCenter: altLabel.horizontalCenter
        anchors.topMargin:  _margin*2
        anchors.top:        altLabel.bottom
        font.pointSize:     ScreenTools.defaultFontPixelHeight
        font.bold:          true
        color:              Qt.rgba(0.102,0.887,0.609,1)
        text:               _altText
    }


    QGCLabel {
        id:                 azimuth
        anchors.horizontalCenter: azimuthLabel.horizontalCenter
        anchors.topMargin:  _margin*2
        anchors.top:        azimuthLabel.bottom
        font.pointSize:     ScreenTools.defaultFontPixelHeight
        font.bold:          true
        color:              Qt.rgba(0.102,0.887,0.609,1)
        text:               _azimuthText
        }
    Rectangle {
        id:                 space
        anchors.topMargin:  _margin*3
        anchors.top:        distance.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width:              parent.width*0.8
        height:             2
        color:              Qt.rgba(0,0,0,1)
    }
    Loader {
        id:                 editorLoader
        anchors.leftMargin: _margin
        anchors.topMargin:  _margin*2
        anchors.left:       parent.left
        anchors.top:        space.bottom
        height:             _currentItem && item ? item.height : 0
        source:             _currentItem ? (missionItem.isSimpleItem ? "qrc:/qml/SimpleItemEditor.qml" : "qrc:/qml/SurveyItemEditor.qml"):""

        property real   availableWidth: _root.width - (_margin * 2) ///< How wide the editor should be
        property var    editorRoot:     _root
    }
} // Rectangle
