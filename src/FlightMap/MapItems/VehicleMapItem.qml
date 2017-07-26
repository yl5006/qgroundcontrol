/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtLocation       5.3
import QtPositioning    5.3

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0

/// Marker for displaying a vehicle location on the map
MapQuickItem {
    property var    vehicle                ///< Vehicle object
    property var    map
    property double altitude:       Number.NaN                                      ///< NAN to not show
    property string callsign:       ""                                              ///< Vehicle callsign
    property double heading:        vehicle ? vehicle.heading.value : Number.NaN    ///< Vehicle heading, NAN for none          /// Size for icon
    property real   size:           ScreenTools.defaultFontPixelHeight * 3

    anchorPoint.x:  vehicleIcon.width  / 2
    anchorPoint.y:  vehicleIcon.height / 2
    visible:        vehicle && vehicle.coordinate.isValid

    property bool   _adsbVehicle:   vehicle ? false : true
    property real   _uavSize:       ScreenTools.defaultFontPixelHeight * 5
    property real   _adsbSize:      ScreenTools.defaultFontPixelHeight * 1.5
    property var    _map:           map
    property bool   _multiVehicle:  QGroundControl.multiVehicleManager.vehicles.count > 1
    sourceItem: Image {
        id:                 vehicleIcon
        source:             vehicle.multiRotor?"/qmlimages/airplaneCoper.svg":"/qmlimages/airplanePlane.svg"  /*isSatellite ? vehicle.vehicleImageOpaque : vehicle.vehicleImageOutline*/
        mipmap:             true
        width:              size
        sourceSize.width:   size
        fillMode:           Image.PreserveAspectFit
        transform: Rotation {
            origin.x:       vehicleIcon.width  / 2
            origin.y:       vehicleIcon.height / 2
            angle:          vehicle ? vehicle.heading.value : 0
        }
    }
}
