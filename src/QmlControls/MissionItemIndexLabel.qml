import QtQuick          2.3
import QtQuick.Controls 1.2

import QGroundControl.ScreenTools 1.0
import QGroundControl.Palette     1.0

Canvas {
    id:     root

    width:  _width
    height: _height

    signal clicked

    property string label                       ///< Label to show to the side of the index indicator
    property int    index:                  0   ///< Index to show in the indicator, 0 will show label instead
    property bool   checked:                false
    property bool   small:                  false
    property var    color:                  checked ? "green" : qgcPal.mapButtonHighlight
    property real   anchorPointX:           _height / 2
    property real   anchorPointY:           _height / 2
    property bool   specifiesCoordinate:    true
    property real   gimbalYaw
    property real   vehicleYaw
    property bool   showGimbalYaw:          false

    property int    simpleindex:                  0   ///
    property real   _width:             showGimbalYaw ? Math.max(_gimbalYawWidth, labelControl.visible ? labelControl.width : indicator.width) : (labelControl.visible ? labelControl.width : indicator.width)
    property real   _height:            showGimbalYaw ? _gimbalYawWidth : (labelControl.visible ? labelControl.height : indicator.height)
    property real   _gimbalYawRadius:   ScreenTools.defaultFontPixelHeight
    property real   _gimbalYawWidth:    _gimbalYawRadius * 2
    property real   _indicatorRadius:   small ? (ScreenTools.defaultFontPixelHeight * ScreenTools.smallFontPointRatio * 1.25 / 2) : (ScreenTools.defaultFontPixelHeight * 0.66)
    property real   _gimbalRadians:     degreesToRadians(vehicleYaw + gimbalYaw - 90)
    property real   _labelMargin:       0//2
    property real   _labelRadius:       _indicatorRadius + _labelMargin
    property string _label:             index === 0 ? "" : label
    property string _index:             index === 0 ? label : index

    onColorChanged:         requestPaint()
    onShowGimbalYawChanged: requestPaint()
    onGimbalYawChanged:     requestPaint()
    onVehicleYawChanged:    requestPaint()

    QGCPalette { id: qgcPal }

    function degreesToRadians(degrees) {
        return (Math.PI/180)*degrees
    }
	
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

    function paintGimbalYaw(context) {
        if (showGimbalYaw) {
            context.save()
            context.globalAlpha = 0.75
            context.beginPath()
            context.moveTo(anchorPointX, anchorPointY)
            context.arc(anchorPointX, anchorPointY, _gimbalYawRadius,  _gimbalRadians + degreesToRadians(45), _gimbalRadians + degreesToRadians(-45), true /* clockwise */)
            context.closePath()
            context.fillStyle = "white"
            context.fill()
            context.restore()
        }
    }

    onPaint: {
        var context = getContext("2d")
        context.clearRect(0, 0, width, height)
        paintGimbalYaw(context)
    }

    Rectangle {
        id:                     labelControl
        anchors.leftMargin:     -((_labelMargin * 2) + indicator.width)
        anchors.rightMargin:    -(_labelMargin * 2)
        anchors.fill:           labelControlLabel
        color:                  "black"
        opacity:                0.3
        radius:                 _labelRadius
        visible:                _label.length !== 0 && !small
    }

    QGCLabel {
        id:                     labelControlLabel
        anchors.topMargin:      -_labelMargin
        anchors.bottomMargin:   -_labelMargin
        anchors.leftMargin:     _labelMargin
        anchors.left:           indicator.right
        anchors.top:            indicator.top
        anchors.bottom:         indicator.bottom
        color:                  "white"
        text:                   _label
        verticalAlignment:      Text.AlignVCenter
        visible:                labelControl.visible
    }

    Image {
        id:         waypoint
        source:     simpleindex==0?getsouceimg(missionItem.command):"/qmlimages/Waypoint0.svg"
        mipmap:     true
        fillMode:   Image.PreserveAspectFit
        anchors.fill: indicator
    }
    Rectangle {
        id:                             indicator
        anchors.horizontalCenter:       parent.left
        anchors.verticalCenter:         parent.top
        anchors.horizontalCenterOffset: anchorPointX
        anchors.verticalCenterOffset:   anchorPointY
        width:                          _indicatorRadius * 4 //2
        height:                         width
        color:                          "transparent"//root.color
        radius:                         _indicatorRadius

        QGCLabel {
            anchors.fill:           parent
            anchors.topMargin:      _indicatorRadius*0.8
            horizontalAlignment:    Text.AlignHCenter
          //  verticalAlignment:      Text.AlignVCenter
            color:                  "white"
            font.pointSize:         ScreenTools.defaultFontPointSize*1.1
            fontSizeMode:           Text.HorizontalFit
            text:                   _index
        }
    }

    QGCMouseArea {
        fillItem:   parent
        onClicked:  parent.clicked()
    }
}
