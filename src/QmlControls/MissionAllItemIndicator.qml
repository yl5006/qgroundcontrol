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
    height:             total.height + (_margin * 2)
    anchors.left:       parent.left
    anchors.right:      parent.right
    anchors.top:        parent.top
    color:              "transparent"

    property var    missionController

    property var    missionItems:               _controllerValid ? missionController.visualItems : undefined
    property real   missionDistance:            _controllerValid ? missionController.missionDistance : NaN
    property real   missionTime:                _controllerValid ? missionController.missionTime : NaN
    property real   missionMaxTelemetry:        _controllerValid ? missionController.missionMaxTelemetry : NaN
    property bool   missionDirty:               _controllerValid ? missionController.dirty : false

    property var    _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle

    property bool   _missionValid:              missionItems != undefined
    property bool   _controllerValid:           missionController != undefined
//    property bool   _manualUpload:              QGroundControl.settingsManager.appSettings.automaticMissionUpload.rawValue == 0

    readonly property real  _editFieldWidth:    Math.min(width - _margin * 2, ScreenTools.defaultFontPixelWidth * 12)
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius:            ScreenTools.defaultFontPixelWidth / 2

    property real   _largeValueWidth:           ScreenTools.defaultFontPixelWidth * 8
    property real   _smallValueWidth:           ScreenTools.defaultFontPixelWidth * 4
    property real   _labelToValueSpacing:       ScreenTools.defaultFontPixelWidth

    property real   _missionDistance:           _missionValid ? missionDistance : NaN
    property real   _missionMaxTelemetry:       _missionValid ? missionMaxTelemetry : NaN
    property real   _missionTime:               _missionValid ? missionTime : NaN
    property int    _batteryChangePoint:        _controllerValid ? missionController.batteryChangePoint : -1
    property int    _batteriesRequired:         _controllerValid ? missionController.batteriesRequired : -1

    property string _missionDistanceText:       isNaN(_missionDistance) ? 	"-.-" : _missionDistance < 1000 ? QGroundControl.metersToAppSettingsDistanceUnits(_missionDistance).toFixed(1) + QGroundControl.appSettingsDistanceUnitsString : QGroundControl.metersToAppSettingsDistanceUnits(_missionDistance/1000).toFixed(1) + "k" + QGroundControl.appSettingsDistanceUnitsString
    property string _missionMaxTelemetryText:   isNaN(_missionMaxTelemetry) ? 	"-.-" : _missionMaxTelemetry < 1000 ? QGroundControl.metersToAppSettingsDistanceUnits(_missionMaxTelemetry).toFixed(1) + QGroundControl.appSettingsDistanceUnitsString : QGroundControl.metersToAppSettingsDistanceUnits(_missionMaxTelemetry/1000).toFixed(2) + "k" + QGroundControl.appSettingsDistanceUnitsString
    property string _batteryChangePointText:    _batteryChangePoint < 0 ?       "N/A" : _batteryChangePoint
    property string _batteriesRequiredText:     _batteriesRequired < 0 ?        "N/A" : _batteriesRequired

    QGCPalette { id: qgcPal }

    function getMissionTime() {
        if(isNaN(_missionTime)) {
            return "00:00:00"
        }
        var t = new Date(0, 0, 0, 0, 0, Number(_missionTime))
        return Qt.formatTime(t, 'hh:mm:ss')
    }
    
    MouseArea {
        anchors.fill:   parent
        onWheel:        { wheel.accepted = true; }
        onPressed:      { mouse.accepted = true; }
        onReleased:     { mouse.accepted = true; }
    }
    
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
            width:              parent.width
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
                    font.pointSize:     ScreenTools.defaultFontPixelHeight*0.8
                    font.bold:          true
                    color:              Qt.rgba(0.102,0.887,0.609,1)
                    text:               _missionDistanceText
                }

                QGCLabel {
                    width:              parent.width/3
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:     ScreenTools.defaultFontPixelHeight*0.8
                    font.bold:          true
                    color:              Qt.rgba(0.102,0.887,0.609,1)
                    text:               getMissionTime()
                }
                QGCLabel {
                    width:              parent.width/3
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:     ScreenTools.defaultFontPixelHeight*0.8
                    font.bold:          true
                    color:              Qt.rgba(0.102,0.887,0.609,1)
                    text:               _missionMaxTelemetryText
                }
            }
        }
    }
} // Rectangle
