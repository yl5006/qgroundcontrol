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
    height:             editorLoader.y + editorLoader.height + (_margin * 2)
    anchors.left:       parent.left
    anchors.right:      parent.right
    anchors.top:        parent.top
    color:              "transparent"//qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.8) : Qt.rgba(0,0,0,0.75)

    property var    missionController
    property var    currentMissionItem          ///< Mission item to display status for
    property var    missionItem
    property var    map
    property bool   readOnly        ///< true: read only view, false: full editing view
    property var    rootQgcView

    property var    missionItems:               _controllerValid ? missionController.visualItems : undefined
    property real   missionDistance:            _controllerValid ? missionController.missionDistance : NaN
    property real   missionTime:                _controllerValid ? missionController.missionTime : NaN
    property real   missionMaxTelemetry:        _controllerValid ? missionController.missionMaxTelemetry : NaN
    property bool   missionDirty:               _controllerValid ? missionController.dirty : false

    property var    _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle

    property bool   _statusValid:               currentMissionItem != undefined
    property bool   _missionValid:              missionItems != undefined
    property bool   _controllerValid:           missionController != undefined
    property bool   _manualUpload:              QGroundControl.settingsManager.appSettings.automaticMissionUpload.rawValue == 0

    readonly property real  _editFieldWidth:    Math.min(width - _margin * 2, ScreenTools.defaultFontPixelWidth * 12)
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _hamburgerSize:     commandPicker.height * 0.75
    Connections {
        target: QGroundControl.settingsManager.appSettings.automaticMissionUpload
        onRawValueChanged: console.log("changed", QGroundControl.settingsManager.appSettings.automaticMissionUpload.rawValue)
    }

    property real   _largeValueWidth:           ScreenTools.defaultFontPixelWidth * 8
    property real   _smallValueWidth:           ScreenTools.defaultFontPixelWidth * 4
    property real   _labelToValueSpacing:       ScreenTools.defaultFontPixelWidth
    property real   _distance:                  _statusValid ? currentMissionItem.distance : NaN
    property real   _altDifference:             _statusValid ? currentMissionItem.altDifference : NaN
    property real   _gradient:                  _statusValid && currentMissionItem.distance > 0 ? Math.atan(currentMissionItem.altDifference / currentMissionItem.distance) : NaN
    property real   _gradientPercent:           isNaN(_gradient) ? NaN : _gradient * 100
    property real   _azimuth:                   _statusValid ? currentMissionItem.azimuth : NaN
    property real   _missionDistance:           _missionValid ? missionDistance : NaN
    property real   _missionMaxTelemetry:       _missionValid ? missionMaxTelemetry : NaN
    property real   _missionTime:               _missionValid ? missionTime : NaN
    property int    _batteryChangePoint:        _controllerValid ? missionController.batteryChangePoint : -1
    property int    _batteriesRequired:         _controllerValid ? missionController.batteriesRequired : -1

    property string _distanceText:              isNaN(_distance) ?              "-.-" : _distance < 1000 ? QGroundControl.metersToAppSettingsDistanceUnits(_distance).toFixed(1) + QGroundControl.appSettingsDistanceUnitsString : QGroundControl.metersToAppSettingsDistanceUnits(_distance/1000).toFixed(2) + "k" + QGroundControl.appSettingsDistanceUnitsString
    property string _altDifferenceText:         isNaN(_altDifference) ? 	"-.-" : QGroundControl.metersToAppSettingsDistanceUnits(_altDifference).toFixed(2) + QGroundControl.appSettingsDistanceUnitsString
    property string _gradientText:              isNaN(_gradient) ? 		"-.-" : _gradientPercent.toFixed(0) + "%"
    property string _azimuthText:               isNaN(_azimuth) ? 		"-.-" : Math.round(_azimuth)
    property string _missionDistanceText:       isNaN(_missionDistance) ? 	"-.-" : _missionDistance < 1000 ? QGroundControl.metersToAppSettingsDistanceUnits(_missionDistance).toFixed(1) + QGroundControl.appSettingsDistanceUnitsString : QGroundControl.metersToAppSettingsDistanceUnits(_missionDistance/1000).toFixed(2) + "k" + QGroundControl.appSettingsDistanceUnitsString
    property string _missionTimeText:           isNaN(_missionTime) ? 		"-.-" : Number(_missionTime / 60).toFixed(1) + "m"
    property string _missionMaxTelemetryText:   isNaN(_missionMaxTelemetry) ? 	"-.-" : _missionMaxTelemetry < 1000 ? QGroundControl.metersToAppSettingsDistanceUnits(_missionMaxTelemetry).toFixed(1) + QGroundControl.appSettingsDistanceUnitsString : QGroundControl.metersToAppSettingsDistanceUnits(_missionMaxTelemetry/1000).toFixed(2) + "k" + QGroundControl.appSettingsDistanceUnitsString
    property string _batteryChangePointText:    _batteryChangePoint < 0 ?       "N/A" : _batteryChangePoint
    property string _batteriesRequiredText:     _batteriesRequired < 0 ?        "N/A" : _batteriesRequired

    QGCPalette { id: qgcPal }

    signal remove

    signal insert

    Rectangle {
        id:                 total
        width:              parent.width
        height:             ScreenTools.defaultFontPixelHeight*5
        anchors.top:        parent.top
        color:              Qt.rgba(0.102,0.122,0.133,0.9)//qgcPal.windowShade
        radius:             _margin
        Column{
            anchors.topMargin:  _margin*2
            anchors.top:        parent.top
            width:               parent.width*0.9
            anchors.horizontalCenter: parent.horizontalCenter
            spacing:          ScreenTools.defaultFontPixelHeight/2
            Row{
                width:                   parent.width
                QGCLabel {
                    width:              parent.width/3
                    horizontalAlignment:    Text.AlignHCenter
                    color:              Qt.rgba(0.555,0.648,0.691,1)
                    text:               qsTr("任务距离")//"Distance" //+ _distanceText
                }
                QGCLabel {
                    width:              parent.width/3
                    horizontalAlignment:    Text.AlignHCenter
                    color:              Qt.rgba(0.555,0.648,0.691,1)
                    text:               qsTr("任务时间")//"Alt diff"// + _altText
                }

                QGCLabel {
                    width:              parent.width/3
                    horizontalAlignment:    Text.AlignHCenter
                    color:              Qt.rgba(0.555,0.648,0.691,1)
                    text:               qsTr("最大距离")//"Azimuth" //+ _azimuthText
                }
            }
            Row{
                width:                   parent.width
                QGCLabel {
                    width:              parent.width/3
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:     ScreenTools.defaultFontPixelHeight
                    font.bold:          true
                    color:              Qt.rgba(0.102,0.887,0.609,1)
                    text:               _missionDistanceText
                }

                QGCLabel {
                    width:              parent.width/3
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:     ScreenTools.defaultFontPixelHeight
                    font.bold:          true
                    color:              Qt.rgba(0.102,0.887,0.609,1)
                    text:               _missionTimeText
                }
                QGCLabel {
                    width:              parent.width/3
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:     ScreenTools.defaultFontPixelHeight
                    font.bold:          true
                    color:              Qt.rgba(0.102,0.887,0.609,1)
                    text:               _missionMaxTelemetryText
                }
            }
        }
    }


    MouseArea {
        anchors.fill:   parent
        onClicked: {
            forceActiveFocus()
        }
    }


    Rectangle {
        width:           parent.width
        anchors.top:     total.bottom
        anchors.topMargin:  _margin*2
        anchors.bottom:  parent.bottom

        color:      Qt.rgba(0.102,0.122,0.133,0.9)//qgcPal.windowShade
    }
    Rectangle {
        width:           parent.width
        anchors.top:     total.bottom
        anchors.topMargin:  _margin*2
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
        visible:                missionItem.isCurrentItem && missionItem.sequenceNumber != 0
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
        anchors.topMargin:      ScreenTools.defaultFontPixelWidth * 4
        anchors.top:            total.bottom
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

        onClicked:              qgcView.showDialog(commandDialog,qsTr("选择任务") /*"Select Mission Command"*/, qgcView.showDialogDefaultWidth, StandardButton.Cancel)

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
            item.visible = Qt.binding(function() { return missionItem.isCurrentItem; })
        }

        property real   availableWidth: _root.width - (_margin * 2) ///< How wide the editor should be
        property var    editorRoot:     _root
    }
} // Rectangle
