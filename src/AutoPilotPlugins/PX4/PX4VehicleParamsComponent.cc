﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "PX4VehicleParamsComponent.h"
#include "PX4AutoPilotPlugin.h"
#include "AirframeComponent.h"

PX4VehicleParamsComponent::PX4VehicleParamsComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
//    , _name("FlyParams")
      , _name(tr("机参"))
{
}

QString PX4VehicleParamsComponent::name(void) const
{
    return _name;
}

QString PX4VehicleParamsComponent::description(void) const
{
    return tr("Tuning Setup is used to tune the flight characteristics of the Vehicle.");
}

QString PX4VehicleParamsComponent::iconResource(void) const
{
    return "/qmlimages/subMenuButtonImage.png";
}

bool PX4VehicleParamsComponent::requiresSetup(void) const
{
    return false;
}

bool PX4VehicleParamsComponent::setupComplete(void) const
{
    return true;
}

QStringList PX4VehicleParamsComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl PX4VehicleParamsComponent::setupSource(void) const
{
    QString qmlFile;

    switch (_vehicle->vehicleType()) {
        case MAV_TYPE_FIXED_WING:
            qmlFile = "qrc:/qml/PX4VehicleParamsComponentPlane.qml";
            break;
        case MAV_TYPE_QUADROTOR:
        case MAV_TYPE_COAXIAL:
        case MAV_TYPE_HELICOPTER:
        case MAV_TYPE_HEXAROTOR:
        case MAV_TYPE_OCTOROTOR:
        case MAV_TYPE_TRICOPTER:
            qmlFile = "qrc:/qml/PX4VehicleParamsComponentCopter.qml";
            break;
        case MAV_TYPE_VTOL_DUOROTOR:
        case MAV_TYPE_VTOL_QUADROTOR:
        case MAV_TYPE_VTOL_TILTROTOR:
        case MAV_TYPE_VTOL_RESERVED2:
        case MAV_TYPE_VTOL_RESERVED3:
        case MAV_TYPE_VTOL_RESERVED4:
        case MAV_TYPE_VTOL_RESERVED5:
            qmlFile = "qrc:/qml/PX4VehicleParamsComponentVTOL.qml";
            break;
        default:
            break;
    }

    return QUrl::fromUserInput(qmlFile);
}

QUrl PX4VehicleParamsComponent::summaryQmlSource(void) const
{
    return QUrl();
}
