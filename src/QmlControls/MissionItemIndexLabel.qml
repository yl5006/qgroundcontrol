import QtQuick                  2.5
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2

import QGroundControl.ScreenTools 1.0
import QGroundControl.Palette     1.0


//Rectangle {    
Item {
    id: root
    property alias  label:      _label.text
    property bool   checked:    false
    property bool   small:      false

    signal clicked
    property bool   simple:      false
    width:          _width*1.5
    height:         _width*1.5
//  radius:         _width / 2
//  border.width:   small ? 1 : 2
//  border.color:   "white"
//    color:         checked ? "green" : qgcPal.mapButtonHighlight

    property real _width: small ? ScreenTools.defaultFontPixelHeight * ScreenTools.smallFontPointRatio * 1.75 : ScreenTools.defaultFontPixelHeight * 1.75
    QGCPalette { id: qgcPal }

    function getsouceimg(command)
    {
        switch(command){
            case 203:    //MAV_CMD_DO_DIGICAM_CONTROL
            case 206:    //MAV_CMD_DO_SET_CAM_TRIGG_DIST
            case 214:    //MAV_CMD_DO_CAM
            case 215:    //MAV_CMD_DO_CAM
               return   checked  ? "/qmlimages/WayCamera.svg" : "/qmlimages/WayCamera0.svg"
            case 20:   //MAV_CMD_NAV_RETURN_TO_LAUNCH
            case 216:   //MAV_CMD_NAV_RETURN_TO_LAUNCH
               return   checked  ? "/qmlimages/gohome.svg" : "/qmlimages/gohome0.svg"
            case 80:   //MAV_CMD_NAV_ROI
                return   checked  ? "/qmlimages/Waypoint.svg" : "/qmlimages/Waypoint0.svg"
            case 84:   //MAV_CMD_NAV_VTOL_TAKEOFF
            case 85:   //MAV_CMD_NAV_VTOL_LAND
                return   checked  ? "/qmlimages/votlchange.svg" : "/qmlimages/votlchange0.svg"
            case 177:  //MAV_CMD_DO_JUMP
                return   checked  ? "/qmlimages/jump.svg" : "/qmlimages/jump0.svg"
            case 178:  //MAV_CMD_DO_CHANGE_SPEED
            case 183:  //MAV_CMD_DO_SET_SERVO
               return   checked  ? "/qmlimages/WaySet.svg" : "/qmlimages/WaySet0.svg"
            default:
               return   checked  ? "/qmlimages/Waypoint.svg" : "/qmlimages/Waypoint0.svg"
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
    }
    Image {
        id:         waypoint
        source:     simple?"/qmlimages/Waypoint0.svg":getsouceimg(missionItem.command)
        mipmap:     true
        fillMode:   Image.PreserveAspectFit
        anchors.fill: parent
    }
    Rectangle {
        id:             point
        width:          _width/2
        height:         _width/2
        radius:         _width / 2
        color:              Qt.rgba(0,0,0,0.0)
        anchors.topMargin: _width/3
        anchors.top:     parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        QGCLabel {
            id:                     _label
            anchors.fill:           parent
            horizontalAlignment:    Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter
            color:                  "white"
            font.pointSize:         small ? ScreenTools.smallFontPointSize : ScreenTools.defaultFontPointSize
        }
    }
}
