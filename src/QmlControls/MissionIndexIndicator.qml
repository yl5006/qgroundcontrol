import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtQuick.Dialogs  1.2

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0

// indicator Plan View
Rectangle {
    id:                 _root
    height:             editorLoader.y + editorLoader.height
    anchors.left:       parent.left
    anchors.right:      parent.right
    anchors.top:        parent.top
    color:              Qt.rgba(0.102,0.122,0.133,0.9)//qgcPal.windowShade    
    radius:             _margin
    property var    map             ///< Map control
    property var    masterController
    property var    missionItem     ///< MissionItem associated with this editor
    property bool   readOnly        ///< true: read only view, false: full editing view
    property var    rootQgcView

    property bool   _statusValid:               missionItem != undefined
    property var    _masterController:          masterController
    property var    _missionController:         _masterController.missionController
    property bool   _currentItem:               missionItem.isCurrentItem

    readonly property real  _editFieldWidth:    Math.min(width - _margin * 2, ScreenTools.defaultFontPixelWidth * 12)
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _hamburgerSize:     commandPicker.height * 0.7
    readonly property bool  _waypointsOnlyMode: QGroundControl.corePlugin.options.missionWaypointsOnly
    property real   _largeValueWidth:           ScreenTools.defaultFontPixelWidth * 8
    property real   _smallValueWidth:           ScreenTools.defaultFontPixelWidth * 4
    property real   _labelToValueSpacing:       ScreenTools.defaultFontPixelWidth

    property real   _distance:                  _statusValid ? missionItem.distance : NaN
    property real   _altDifference:             _statusValid ? missionItem.altDifference : NaN
    property real   _gradient:                  _statusValid && missionItem.distance > 0 ? Math.atan(missionItem.altDifference / missionItem.distance) : NaN
    property real   _gradientPercent:           isNaN(_gradient) ? NaN : _gradient * 100
    property real   _azimuth:                   _statusValid ? missionItem.azimuth : NaN

    property string _distanceText:              isNaN(_distance) ?              "-.-" : _distance < 1000 ? QGroundControl.metersToAppSettingsDistanceUnits(_distance).toFixed(1) + QGroundControl.appSettingsDistanceUnitsString : QGroundControl.metersToAppSettingsDistanceUnits(_distance/1000).toFixed(2) + "k" + QGroundControl.appSettingsDistanceUnitsString
    property string _altDifferenceText:         isNaN(_altDifference) ? 	"-.-" : QGroundControl.metersToAppSettingsDistanceUnits(_altDifference).toFixed(2) + QGroundControl.appSettingsDistanceUnitsString
    property string _gradientText:              isNaN(_gradient) ? 		"-.-" : _gradientPercent.toFixed(0) + "%"
    property string _azimuthText:               isNaN(_azimuth) ? 		"-.-" : Math.round(_azimuth)

    QGCPalette { id: qgcPal }

    signal remove

    signal insert

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            forceActiveFocus()
        }
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
        anchors.leftMargin:     _margin*2
        font.pointSize:         ScreenTools.defaultFontPixelHeight*2
        font.bold:              true
        anchors.left:           parent.left
        text:                   missionItem.sequenceNumber
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
        visible:                _currentItem && missionItem.sequenceNumber != 0
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
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 1
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth * 1
        anchors.topMargin:      ScreenTools.defaultFontPixelWidth * 2
        anchors.top:            parent.top
        anchors.left:           label.right
        anchors.right:          deletepoint.left
        visible:                missionItem.isCurrentItem && !missionItem.rawEdit && missionItem.isSimpleItem
        text:                   missionItem.commandName

        Component {
            id: commandDialog

            MissionCommandDialog {
                missionItem: _root.missionItem
            }
        }

        onClicked:              qgcView.showDialog(commandDialog,qsTr("Select Mission Command"), qgcView.showDialogDefaultWidth, StandardButton.Cancel)

    }
    Rectangle {
        width:           commandPicker.width*0.8
        height:          1
        visible:         missionItem.isCurrentItem && !missionItem.rawEdit && missionItem.isSimpleItem
        anchors.top:     commandPicker.bottom
        anchors.horizontalCenter: commandPicker.horizontalCenter
        color:            "White"
    }

    QGCLabel {
        anchors.fill:       commandPicker
        visible:            !missionItem.isCurrentItem || !missionItem.isSimpleItem
        anchors.horizontalCenter: commandPicker.horizontalCenter
        verticalAlignment:  Text.AlignVCenter
        text:               missionItem.commandName
       // color:              _outerTextColor
    }
    QGCLabel {
        id:                 distanceLabel
        anchors.leftMargin: _margin*6
        anchors.topMargin:  _margin*4
        anchors.left:       parent.left
        anchors.top:        commandPicker.bottom
        color:              Qt.rgba(0.555,0.648,0.691,1)
        text:               qsTr("Distance")//"Distance" //+ _distanceText
    }

    QGCLabel {
        id:                 altLabel
        anchors.verticalCenter: distanceLabel.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color:              Qt.rgba(0.555,0.648,0.691,1)
        text:               qsTr("Alt diff")
    }

    QGCLabel {
        id:                 azimuthLabel
        anchors.verticalCenter: distanceLabel.verticalCenter
        anchors.right:          parent.right
        anchors.rightMargin: _margin*5
        color:              Qt.rgba(0.555,0.648,0.691,1)
        text:               qsTr("Azimuth")
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
        text:               _altDifferenceText
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
        anchors.topMargin:  _margin
        anchors.top:        distance.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width:              parent.width*0.8
        height:             2
        color:              Qt.rgba(0,0,0,1)
    }
    Loader {
        id:                 editorLoader
        anchors.leftMargin: _margin
        anchors.topMargin:  _margin
        anchors.left:       parent.left
        anchors.top:        space.bottom
        height:             item ? item.height : 0
        source:             missionItem.editorQml

        onLoaded: {
            item.visible = Qt.binding(function() { return _currentItem; })
        }

        property var    masterController:   _masterController
        property real   availableWidth: _root.width - (_margin * 2) ///< How wide the editor should be
        property var    editorRoot:     _root
    }
} // Rectangle
