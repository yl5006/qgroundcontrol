﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @author Don Gagne <don@thegagnes.com>

#include "MissionManager.h"
#include "Vehicle.h"
#include "FirmwarePlugin.h"
#include "MAVLinkProtocol.h"
#include "QGCApplication.h"
#include "MissionCommandTree.h"
#include "MissionCommandUIInfo.h"

QGC_LOGGING_CATEGORY(MissionManagerLog, "MissionManagerLog")

MissionManager::MissionManager(Vehicle* vehicle)
    : PlanManager(vehicle, MAV_MISSION_TYPE_MISSION)
{

}

MissionManager::~MissionManager()
{

}
void MissionManager::writeMissionItemsoffboard(const QList<MissionItem*>& missionItems)
{
    bool skipFirstItem = !_vehicle->firmwarePlugin()->sendHomePositionToVehicle();

    _clearAndDeleteMissionItems();

    int firstIndex = skipFirstItem ? 1 : 0;

    for (int i=firstIndex; i<missionItems.count(); i++) {
        MissionItem* item = new MissionItem(*missionItems[i]);
        _missionItems.append(item);

        item->setIsCurrentItem(i == firstIndex);

        if (skipFirstItem) {
            // Home is in sequence 0, remainder of items start at sequence 1
            item->setSequenceNumber(item->sequenceNumber() - 1);
            if (item->command() == MAV_CMD_DO_JUMP) {
                item->setParam8((int)item->param8() - 1);
            }
        }
    }
}
void MissionManager::writeArduPilotGuidedMissionItem(const QGeoCoordinate& gotoCoord, bool altChangeOnly)
{
    if (inProgress()) {
        qCDebug(MissionManagerLog) << "writeArduPilotGuidedMissionItem called while transaction in progress";
        return;
    }

    _transactionInProgress = TransactionWrite;

    mavlink_message_t       messageOut;
    mavlink_mission_item_t  missionItem;

    memset(&missionItem, 8, sizeof(missionItem));
    missionItem.target_system =     _vehicle->id();
    missionItem.target_component =  _vehicle->defaultComponentId();
    missionItem.seq =               0;
    missionItem.command =           MAV_CMD_NAV_WAYPOINT;
    missionItem.param1 =            0;
    missionItem.param2 =            0;
    missionItem.param3 =            0;
    missionItem.param4 =            0;
    missionItem.x =                 gotoCoord.latitude();
    missionItem.y =                 gotoCoord.longitude();
    missionItem.z =                 gotoCoord.altitude();
    missionItem.param8 =            0;
    missionItem.param9 =            0;
    missionItem.param10 =           0;
    missionItem.frame =             MAV_FRAME_GLOBAL_RELATIVE_ALT;
    missionItem.current =           altChangeOnly ? 3 : 2;
    missionItem.autocontinue =      true;

    _dedicatedLink = _vehicle->priorityLink();
    mavlink_msg_mission_item_encode_chan(qgcApp()->toolbox()->mavlinkProtocol()->getSystemId(),
                                         qgcApp()->toolbox()->mavlinkProtocol()->getComponentId(),
                                         _dedicatedLink->mavlinkChannel(),
                                         &messageOut,
                                         &missionItem);

    _vehicle->sendMessageOnLink(_dedicatedLink, messageOut);
    _startAckTimeout(AckGuidedItem);
    emit inProgressChanged(true);
}

void MissionManager::generateResumeMission(int resumeIndex)
{
    if (_vehicle->isOfflineEditingVehicle()) {
        return;
    }

    if (inProgress()) {
        qCDebug(MissionManagerLog) << "generateResumeMission called while transaction in progress";
        return;
    }

    for (int i=0; i<_missionItems.count(); i++) {
        MissionItem* item = _missionItems[i];
        if (item->command() == MAV_CMD_DO_JUMP) {
            qgcApp()->showMessage(tr("Unable to generate resume mission due to MAV_CMD_DO_JUMP command."));
            return;
        }
    }

    // Be anal about crap input
    resumeIndex = qMax(0, qMin(resumeIndex, _missionItems.count() - 1));

    // Adjust resume index to be a location based command
    const MissionCommandUIInfo* uiInfo = qgcApp()->toolbox()->missionCommandTree()->getUIInfo(_vehicle, _missionItems[resumeIndex]->command());
    if (!uiInfo || uiInfo->isStandaloneCoordinate() || !uiInfo->specifiesCoordinate()) {
        // We have to back up to the last command which the vehicle flies through
        while (--resumeIndex > 0) {
            uiInfo = qgcApp()->toolbox()->missionCommandTree()->getUIInfo(_vehicle, _missionItems[resumeIndex]->command());
            if (uiInfo && (uiInfo->specifiesCoordinate() && !uiInfo->isStandaloneCoordinate())) {
                // Found it
                break;
            }

        }
    }
    resumeIndex = qMax(0, resumeIndex);

    QList<MissionItem*> resumeMission;

    QList<MAV_CMD> includedResumeCommands;

    // If any command in this list occurs before the resumeIndex it will be added to the front of the mission
    includedResumeCommands << MAV_CMD_DO_CONTROL_VIDEO
                           << MAV_CMD_DO_SET_ROI
                           << MAV_CMD_DO_DIGICAM_CONFIGURE
                           << MAV_CMD_DO_DIGICAM_CONTROL
                           << MAV_CMD_DO_MOUNT_CONFIGURE
                           << MAV_CMD_DO_MOUNT_CONTROL
                           << MAV_CMD_DO_SET_CAM_TRIGG_DIST
                           << MAV_CMD_DO_FENCE_ENABLE
                           << MAV_CMD_IMAGE_START_CAPTURE
                           << MAV_CMD_IMAGE_STOP_CAPTURE
                           << MAV_CMD_VIDEO_START_CAPTURE
                           << MAV_CMD_VIDEO_STOP_CAPTURE
                           << MAV_CMD_DO_CHANGE_SPEED
                           << MAV_CMD_SET_CAMERA_MODE
                           << MAV_CMD_NAV_TAKEOFF;

    bool addHomePosition = _vehicle->firmwarePlugin()->sendHomePositionToVehicle();

    int prefixCommandCount = 0;
    for (int i=0; i<_missionItems.count(); i++) {
        MissionItem* oldItem = _missionItems[i];
        if ((i == 0 && addHomePosition) || i >= resumeIndex || includedResumeCommands.contains(oldItem->command())) {
            if (i < resumeIndex) {
                prefixCommandCount++;
            }
            MissionItem* newItem = new MissionItem(*oldItem, this);
            newItem->setIsCurrentItem(false);
            resumeMission.append(newItem);
        }
    }
    prefixCommandCount = qMax(0, qMin(prefixCommandCount, resumeMission.count()));  // Anal prevention against crashes

    // De-dup and remove no-ops from the commands which were added to the front of the mission
    bool foundROI = false;
    bool foundCameraSetMode = false;
    bool foundCameraStartStop = false;
    prefixCommandCount--;   // Change from count to array index
    while (prefixCommandCount >= 0) {
        MissionItem* resumeItem = resumeMission[prefixCommandCount];
        switch (resumeItem->command()) {
        case MAV_CMD_SET_CAMERA_MODE:
            // Only keep the last one
            if (foundCameraSetMode) {
                resumeMission.removeAt(prefixCommandCount);
            }
            foundCameraSetMode = true;
            break;
        case MAV_CMD_DO_SET_ROI:
            // Only keep the last one
            if (foundROI) {
                resumeMission.removeAt(prefixCommandCount);
            }
            foundROI = true;
            break;
        case MAV_CMD_DO_SET_CAM_TRIGG_DIST:
        case MAV_CMD_IMAGE_STOP_CAPTURE:
        case MAV_CMD_VIDEO_START_CAPTURE:
        case MAV_CMD_VIDEO_STOP_CAPTURE:
            // Only keep the first of these commands that are found
            if (foundCameraStartStop) {
                resumeMission.removeAt(prefixCommandCount);
            }
            foundCameraStartStop = true;
            break;
        case MAV_CMD_IMAGE_START_CAPTURE:
            if (resumeItem->param3() != 0) {
                // Remove commands which do not trigger by time
                resumeMission.removeAt(prefixCommandCount);
                break;
            }
            if (foundCameraStartStop) {
                // Only keep the first of these commands that are found
                resumeMission.removeAt(prefixCommandCount);
            }
            foundCameraStartStop = true;
            break;
        default:
            break;
        }

        prefixCommandCount--;
    }

    // Adjust sequence numbers and current item
    int seqNum = 0;
    for (int i=0; i<resumeMission.count(); i++) {
        resumeMission[i]->setSequenceNumber(seqNum++);
    }
    int setCurrentIndex = addHomePosition ? 1 : 0;
    resumeMission[setCurrentIndex]->setIsCurrentItem(true);

    // Send to vehicle
    _clearAndDeleteWriteMissionItems();
    for (int i=0; i<resumeMission.count(); i++) {
        _writeMissionItems.append(new MissionItem(*resumeMission[i], this));
    }
    _resumeMission = true;
    _writeMissionItemsWorker();

    // Clean up no longer needed resume items
    for (int i=0; i<resumeMission.count(); i++) {
        resumeMission[i]->deleteLater();
    }
}
