/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @author Don Gagne <don@thegagnes.com>

#include "ArduCopterFirmwarePlugin.h"
#include "QGCApplication.h"
#include "MissionManager.h"
#include "ParameterManager.h"

bool ArduCopterFirmwarePlugin::_remapParamNameIntialized = false;
FirmwarePlugin::remapParamNameMajorVersionMap_t ArduCopterFirmwarePlugin::_remapParamName;

APMCopterMode::APMCopterMode(uint32_t mode, bool settable) :
    APMCustomMode(mode, settable)
{
    QMap<uint32_t,QString> enumToString;
    enumToString.insert(STABILIZE, "自稳");
    enumToString.insert(ACRO,      "竞技");
    enumToString.insert(ALT_HOLD,  "定高");
    enumToString.insert(AUTO,      "任务");
    enumToString.insert(GUIDED,    "引导");
    enumToString.insert(LOITER,    "悬停");
    enumToString.insert(RTL,       "返航");
    enumToString.insert(CIRCLE,    "绕圈");
    enumToString.insert(POSITION,  "位置");
    enumToString.insert(LAND,      "降落");
    enumToString.insert(OF_LOITER, "OF Loiter");
    enumToString.insert(DRIFT,     "Drift");
    enumToString.insert(SPORT,     "Sport");
    enumToString.insert(FLIP,      "Flip");
    enumToString.insert(AUTOTUNE,  "自动调整");
    enumToString.insert(POS_HOLD,  "定点");
    enumToString.insert(BRAKE,     "刹车");
    enumToString.insert(THROW,     "抛飞");
    enumToString.insert(AVOID_ADSB,"避障");
    enumToString.insert(GUIDED_NOGPS,"无GPS引导");
    enumToString.insert(WAYPOINT_RTL,     "返航航线");
    setEnumToStringMapping(enumToString);
}

ArduCopterFirmwarePlugin::ArduCopterFirmwarePlugin(void)
{
    QList<APMCustomMode> supportedFlightModes;
    supportedFlightModes << APMCopterMode(APMCopterMode::STABILIZE ,true);
    supportedFlightModes << APMCopterMode(APMCopterMode::ACRO      ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::ALT_HOLD  ,true);
    supportedFlightModes << APMCopterMode(APMCopterMode::AUTO      ,true);
    supportedFlightModes << APMCopterMode(APMCopterMode::GUIDED    ,true);
    supportedFlightModes << APMCopterMode(APMCopterMode::LOITER    ,true);
    supportedFlightModes << APMCopterMode(APMCopterMode::RTL       ,true);
    supportedFlightModes << APMCopterMode(APMCopterMode::CIRCLE    ,true);
    supportedFlightModes << APMCopterMode(APMCopterMode::POSITION  ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::LAND      ,true);
    supportedFlightModes << APMCopterMode(APMCopterMode::OF_LOITER ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::DRIFT     ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::SPORT     ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::FLIP      ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::AUTOTUNE  ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::POS_HOLD  ,true);
    supportedFlightModes << APMCopterMode(APMCopterMode::BRAKE     ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::THROW  ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::AVOID_ADSB     ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::GUIDED_NOGPS  ,false);
    supportedFlightModes << APMCopterMode(APMCopterMode::WAYPOINT_RTL     ,true);
    setSupportedModes(supportedFlightModes);

    if (!_remapParamNameIntialized) {
        FirmwarePlugin::remapParamNameMap_t& remap = _remapParamName[3][4];

        remap["ATC_ANG_RLL_P"] =    QStringLiteral("STB_RLL_P");
        remap["ATC_ANG_PIT_P"] =    QStringLiteral("STB_PIT_P");
        remap["ATC_ANG_YAW_P"] =    QStringLiteral("STB_YAW_P");

        remap["ATC_RAT_RLL_P"] =    QStringLiteral("RATE_RLL_P");
        remap["ATC_RAT_RLL_I"] =    QStringLiteral("RATE_RLL_I");
        remap["ATC_RAT_RLL_IMAX"] = QStringLiteral("RATE_RLL_IMAX");
        remap["ATC_RAT_RLL_D"] =    QStringLiteral("RATE_RLL_D");
        remap["ATC_RAT_RLL_FILT"] = QStringLiteral("RATE_RLL_FILT_HZ");

        remap["ATC_RAT_PIT_P"] =    QStringLiteral("RATE_PIT_P");
        remap["ATC_RAT_PIT_I"] =    QStringLiteral("RATE_PIT_I");
        remap["ATC_RAT_PIT_IMAX"] = QStringLiteral("RATE_PIT_IMAX");
        remap["ATC_RAT_PIT_D"] =    QStringLiteral("RATE_PIT_D");
        remap["ATC_RAT_PIT_FILT"] = QStringLiteral("RATE_PIT_FILT_HZ");

        remap["ATC_RAT_YAW_P"] =    QStringLiteral("RATE_YAW_P");
        remap["ATC_RAT_YAW_I"] =    QStringLiteral("RATE_YAW_I");
        remap["ATC_RAT_YAW_IMAX"] = QStringLiteral("RATE_YAW_IMAX");
        remap["ATC_RAT_YAW_D"] =    QStringLiteral("RATE_YAW_D");
        remap["ATC_RAT_YAW_FILT"] = QStringLiteral("RATE_YAW_FILT_HZ");
    }
}

int ArduCopterFirmwarePlugin::remapParamNameHigestMinorVersionNumber(int majorVersionNumber) const
{
    // Remapping supports up to 3.4
    return majorVersionNumber == 3 ? 4: Vehicle::versionNotSetValue;
}

bool ArduCopterFirmwarePlugin::isCapable(const Vehicle* vehicle, FirmwareCapabilities capabilities)
{
    Q_UNUSED(vehicle);

    uint32_t vehicleCapabilities = SetFlightModeCapability | GuidedModeCapability | PauseVehicleCapability;

    return (capabilities & vehicleCapabilities) == capabilities;
}

void ArduCopterFirmwarePlugin::guidedModeRTL(Vehicle* vehicle)
{
    vehicle->setFlightMode("RTL");
}

void ArduCopterFirmwarePlugin::guidedModeLand(Vehicle* vehicle)
{
    vehicle->setFlightMode("Land");
}

void ArduCopterFirmwarePlugin::guidedModeTakeoff(Vehicle* vehicle, double altitudeRel)
{
    vehicle->sendMavCommand(vehicle->defaultComponentId(),
                            MAV_CMD_NAV_TAKEOFF,
                            true, // show error
                            0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f,
                            altitudeRel);
}

void ArduCopterFirmwarePlugin::guidedModeGotoLocation(Vehicle* vehicle, const QGeoCoordinate& gotoCoord)
{
    if (qIsNaN(vehicle->altitudeRelative()->rawValue().toDouble())) {
        qgcApp()->showMessage(QStringLiteral("Unable to go to location, vehicle position not known."));
        return;
    }

    QGeoCoordinate coordWithAltitude = gotoCoord;
    coordWithAltitude.setAltitude(vehicle->altitudeRelative()->rawValue().toDouble());
    vehicle->missionManager()->writeArduPilotGuidedMissionItem(coordWithAltitude, false /* altChangeOnly */);
}

void ArduCopterFirmwarePlugin::guidedModeChangeAltitude(Vehicle* vehicle, double altitudeRel)
{
    if (qIsNaN(vehicle->altitudeRelative()->rawValue().toDouble())) {
        qgcApp()->showMessage(QStringLiteral("Unable to change altitude, vehicle altitude not known."));
        return;
    }

    mavlink_message_t msg;
    mavlink_set_position_target_local_ned_t cmd;

    memset(&cmd, 0, sizeof(mavlink_set_position_target_local_ned_t));

    cmd.target_system = vehicle->id();
    cmd.target_component = vehicle->defaultComponentId();
    cmd.coordinate_frame = MAV_FRAME_LOCAL_OFFSET_NED;
    cmd.type_mask = 0xFFF8; // Only x/y/z valid
    cmd.x = 0.0f;
    cmd.y = 0.0f;
    cmd.z = -(altitudeRel - vehicle->altitudeRelative()->rawValue().toDouble());

    MAVLinkProtocol* mavlink = qgcApp()->toolbox()->mavlinkProtocol();
    mavlink_msg_set_position_target_local_ned_encode_chan(mavlink->getSystemId(),
                                                          mavlink->getComponentId(),
                                                          vehicle->priorityLink()->mavlinkChannel(),
                                                          &msg,
                                                          &cmd);

    vehicle->sendMessageOnLink(vehicle->priorityLink(), msg);
}

bool ArduCopterFirmwarePlugin::isPaused(const Vehicle* vehicle) const
{
    return vehicle->flightMode() == "Brake";
}

void ArduCopterFirmwarePlugin::pauseVehicle(Vehicle* vehicle)
{
    vehicle->setFlightMode("Brake");
}

void ArduCopterFirmwarePlugin::setGuidedMode(Vehicle* vehicle, bool guidedMode)
{
    if (guidedMode) {
        vehicle->setFlightMode("Guided");
    } else {
        pauseVehicle(vehicle);
    }
}

bool ArduCopterFirmwarePlugin::multiRotorCoaxialMotors(Vehicle* vehicle)
{
    Q_UNUSED(vehicle);
    return _coaxialMotors;
}

bool ArduCopterFirmwarePlugin::multiRotorXConfig(Vehicle* vehicle)
{
    return vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, "FRAME")->rawValue().toInt() != 0;
}

QString ArduCopterFirmwarePlugin::geoFenceRadiusParam(Vehicle* vehicle)
{
    Q_UNUSED(vehicle);
    return QStringLiteral("FENCE_RADIUS");
}

QString ArduCopterFirmwarePlugin::takeControlFlightMode(void)
{
    return QStringLiteral("Stabilize");
}
