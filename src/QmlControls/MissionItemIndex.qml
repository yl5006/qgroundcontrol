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
    id: _root
    property var    missionItem ///< MissionItem associated with this editor
    property bool   readOnly    ///< true: read only view, false: full editing view

    signal clicked

    property bool   _currentItem:       missionItem.isCurrentItem
    property color  _outerTextColor:    _currentItem ? "black" : qgcPal.text

    readonly property real  _editFieldWidth:    ScreenTools.defaultFontPointSize * 16
    readonly property real  _margin:            ScreenTools.defaultFontPointSize / 2
    readonly property real  _radius:            ScreenTools.defaultFontPointSize / 2
    readonly property real  _PointFieldWidth:   ScreenTools.defaultFontPointSize * 9
    property real   _distance:          _statusValid ? missionItem.distance : 0
    property bool   _statusValid:       missionItem.sequenceNumber != 0
    property string _distanceText:      _distance<1000 ? QGroundControl.metersToAppSettingsDistanceUnits(_distance).toFixed(0) + QGroundControl.appSettingsDistanceUnitsString : QGroundControl.metersToAppSettingsDistanceUnits(_distance/1000).toFixed(1) + "k" + QGroundControl.appSettingsDistanceUnitsString

    QGCPalette {
        id: qgcPal
        colorGroupEnabled: enabled
    }


    MouseArea {
        anchors.fill:   waypoint
        onClicked:      _root.clicked()
    }

    QGCLabel {
        id:                     label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.leftMargin:     _margin
        anchors.top:            parent.top
        text:                   missionItem.sequenceNumber == 0 ? "Home" : missionItem.commandName
        color:                  _outerTextColor
    }
    Rectangle {
        id:                     waypoint
        width:                  parent.width
        height:                 parent.width
        radius:                 _radius*2
        anchors.top:            label.bottom
        color:                  _currentItem ? Qt.rgba(1,0.52,0,0.85):Qt.rgba(0.1133,0.5664,0.9063,0.85)


        QGCLabel {
            id:                     number
            anchors.top:            parent.top
            width:                  parent.width
            horizontalAlignment:    Text.AlignHCenter
            font.pointSize:         ScreenTools.largeFontPointSize
            font.bold:              true
            fontSizeMode:           Text.HorizontalFit
            color:                  "white"
            text:                   missionItem.sequenceNumber
        }
        Row {
           id:                        altitudedisplay
           anchors.bottom:            parent.bottom
           anchors.bottomMargin:       _margin*0.2
           width:  parent.width*0.9//_largeColumn.width
           spacing:    _margin*2
           anchors.horizontalCenter:  parent.horizontalCenter
           visible:                  missionItem.sequenceNumber != 0
           Image{
               anchors.verticalCenter: parent.verticalCenter
               width:    ScreenTools.mediumFontPointSize
               height:   ScreenTools.mediumFontPointSize
               source:   "/qmlimages/altitudeRelativewhite.svg"
           }

           QGCLabel {
               width:                  parent.width*0.5
               horizontalAlignment:    Text.AlignHCenter
               font.pointSize:         ScreenTools.mediumFontPointSize
               font.bold:              true
               color:                  "white"
//             fontSizeMode:           Text.HorizontalFit
               text:                   missionItem.coordinate.altitude.toFixed(1)+"m"
           }
        }
           Row {
              id:                       distancedisplay
              anchors.bottom:           altitudedisplay.top
              anchors.bottomMargin:     _margin*0.2
              width:                    parent.width*0.9//_largeColumn.width
              spacing:                  _margin*2
              anchors.horizontalCenter:  parent.horizontalCenter
              visible:                  _statusValid
              Image{
                  anchors.verticalCenter: parent.verticalCenter
                  width:    ScreenTools.mediumFontPointSize
                  height:   ScreenTools.mediumFontPointSize
                  source:   "/qmlimages/distance.svg"
              }

              QGCLabel {
                  width:                  parent.width*0.5
                  horizontalAlignment:    Text.AlignHCenter
                  font.pointSize:         ScreenTools.mediumFontPointSize
                  font.bold:              true
                  color:                  "white"
//                fontSizeMode:           Text.HorizontalFit
                  text:                   _distanceText//missionItem.distance
              }
        }
    }
} // Rectangle
