﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "MissionControllerTest.h"
#include "LinkManager.h"
#include "MultiVehicleManager.h"
#include "SimpleMissionItem.h"
#include "MissionSettingsItem.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "AppSettings.h"

MissionControllerTest::MissionControllerTest(void)
    : _multiSpyMissionController(NULL)
    , _multiSpyMissionItem(NULL)
    , _missionController(NULL)
{
    
}

void MissionControllerTest::cleanup(void)
{
    delete _masterController;
    _masterController = NULL;

    delete _multiSpyMissionController;
    _multiSpyMissionController = NULL;

    delete _multiSpyMissionItem;
    _multiSpyMissionItem = NULL;

    MissionControllerManagerTest::cleanup();
}

void MissionControllerTest::_initForFirmwareType(MAV_AUTOPILOT firmwareType)
{
    MissionControllerManagerTest::_initForFirmwareType(firmwareType);

    // VisualMissionItem signals
    _rgVisualItemSignals[coordinateChangedSignalIndex] = SIGNAL(coordinateChanged(const QGeoCoordinate&));

    // MissionController signals
    _rgMissionControllerSignals[visualItemsChangedSignalIndex] =    SIGNAL(visualItemsChanged());
    _rgMissionControllerSignals[waypointLinesChangedSignalIndex] =  SIGNAL(waypointLinesChanged());

    // Master controller pulls offline vehicle info from settings
    qgcApp()->toolbox()->settingsManager()->appSettings()->offlineEditingFirmwareType()->setRawValue(firmwareType);
    _masterController = new PlanMasterController(this);
    _missionController = _masterController->missionController();

    _multiSpyMissionController = new MultiSignalSpy();
    Q_CHECK_PTR(_multiSpyMissionController);
    QCOMPARE(_multiSpyMissionController->init(_missionController, _rgMissionControllerSignals, _cMissionControllerSignals), true);

    _masterController->start(false /* flyView */);

    // All signals should some through on start
    QCOMPARE(_multiSpyMissionController->checkOnlySignalsByMask(visualItemsChangedSignalMask | waypointLinesChangedSignalMask), true);
    _multiSpyMissionController->clearAllSignals();

    QmlObjectListModel* visualItems = _missionController->visualItems();
    QVERIFY(visualItems);

    // Empty vehicle only has home position
    QCOMPARE(visualItems->count(), 1);

    // Mission Settings should be in first slot
    MissionSettingsItem* settingsItem = visualItems->value<MissionSettingsItem*>(0);
    QVERIFY(settingsItem);

    // Offline vehicle, so no home position
    QCOMPARE(settingsItem->coordinate().isValid(), false);

    // Empty mission, so no child items possible
    QCOMPARE(settingsItem->childItems()->count(), 0);

    // No waypoint lines
    QmlObjectListModel* waypointLines = _missionController->waypointLines();
    QVERIFY(waypointLines);
    QCOMPARE(waypointLines->count(), 0);
}

void MissionControllerTest::_testEmptyVehicleWorker(MAV_AUTOPILOT firmwareType)
{
    _initForFirmwareType(firmwareType);

    // FYI: A significant amount of empty vehicle testing is in _initForFirmwareType since that
    // sets up an empty vehicle

    QmlObjectListModel* visualItems = _missionController->visualItems();
    QVERIFY(visualItems);
    VisualMissionItem* visualItem = visualItems->value<VisualMissionItem*>(0);
    QVERIFY(visualItem);

    _setupVisualItemSignals(visualItem);
}

void MissionControllerTest::_testEmptyVehiclePX4(void)
{
    _testEmptyVehicleWorker(MAV_AUTOPILOT_PX4);
}

void MissionControllerTest::_testEmptyVehicleAPM(void)
{
    _testEmptyVehicleWorker(MAV_AUTOPILOT_ARDUPILOTMEGA);
}

void MissionControllerTest::_testAddWaypointWorker(MAV_AUTOPILOT firmwareType)
{
    _initForFirmwareType(firmwareType);

//    QGeoCoordinate coordinate(37.803784, -122.462276);
    QGeoCoordinate coordinate(30.5386437,114.3662806);

    _missionController->insertSimpleMissionItem(coordinate, _missionController->visualItems()->count());

    QCOMPARE(_multiSpyMissionController->checkOnlySignalsByMask(waypointLinesChangedSignalMask), true);

    QmlObjectListModel* visualItems = _missionController->visualItems();
    QVERIFY(visualItems);

    QCOMPARE(visualItems->count(), 2);

    MissionSettingsItem* settingsItem = visualItems->value<MissionSettingsItem*>(0);
    SimpleMissionItem* simpleItem = visualItems->value<SimpleMissionItem*>(1);
    QVERIFY(settingsItem);
    QVERIFY(simpleItem);

    QCOMPARE((MAV_CMD)simpleItem->command(), MAV_CMD_NAV_TAKEOFF);
    QCOMPARE(simpleItem->childItems()->count(), 0);

    // If the first item added specifies a coordinate, then planned home position will be set
    bool plannedHomePositionValue = firmwareType == MAV_AUTOPILOT_ARDUPILOTMEGA ? false : true;
    QCOMPARE(settingsItem->coordinate().isValid(), plannedHomePositionValue);

    // ArduPilot takeoff command has no coordinate, so should be child item
    QCOMPARE(settingsItem->childItems()->count(), firmwareType == MAV_AUTOPILOT_ARDUPILOTMEGA ? 1 : 0);

    // Check waypoint line from home to takeoff
    int expectedLineCount = firmwareType == MAV_AUTOPILOT_ARDUPILOTMEGA ? 0 : 1;
    QmlObjectListModel* waypointLines = _missionController->waypointLines();
    QVERIFY(waypointLines);
    QCOMPARE(waypointLines->count(), expectedLineCount);
}

void MissionControllerTest::_testAddWayppointAPM(void)
{
    _testAddWaypointWorker(MAV_AUTOPILOT_ARDUPILOTMEGA);
}


void MissionControllerTest::_testAddWayppointPX4(void)
{
    _testAddWaypointWorker(MAV_AUTOPILOT_PX4);
}

#if 0
void MissionControllerTest::_testOfflineToOnlineWorker(MAV_AUTOPILOT firmwareType)
{
    // Start offline and add item
    _missionController = new MissionController();
    Q_CHECK_PTR(_missionController);
    _missionController->start(false /* flyView */);
    _missionController->insertSimpleMissionItem(QGeoCoordinate(37.803784, -122.462276), _missionController->visualItems()->count());

    // Go online to empty vehicle
    MissionControllerManagerTest::_initForFirmwareType(firmwareType);

#if 1
    // Due to current limitations, offline items will go away
    QCOMPARE(_missionController->visualItems()->count(), 1);
#else
    //Make sure our offline mission items are still there
    QCOMPARE(_missionController->visualItems()->count(), 2);
#endif
}

void MissionControllerTest::_testOfflineToOnlineAPM(void)
{
    _testOfflineToOnlineWorker(MAV_AUTOPILOT_ARDUPILOTMEGA);
}

void MissionControllerTest::_testOfflineToOnlinePX4(void)
{
    _testOfflineToOnlineWorker(MAV_AUTOPILOT_PX4);
}
#endif

void MissionControllerTest::_setupVisualItemSignals(VisualMissionItem* visualItem)
{
    delete _multiSpyMissionItem;

    _multiSpyMissionItem = new MultiSignalSpy();
    Q_CHECK_PTR(_multiSpyMissionItem);
    QCOMPARE(_multiSpyMissionItem->init(visualItem, _rgVisualItemSignals, _cVisualItemSignals), true);
}

void MissionControllerTest::_testGimbalRecalc(void)
{
    _initForFirmwareType(MAV_AUTOPILOT_PX4);
    _missionController->insertSimpleMissionItem(QGeoCoordinate(0, 0), 1);
    _missionController->insertSimpleMissionItem(QGeoCoordinate(0, 0), 2);
    _missionController->insertSimpleMissionItem(QGeoCoordinate(0, 0), 3);
    _missionController->insertSimpleMissionItem(QGeoCoordinate(0, 0), 4);

    // No specific gimbal yaw set yet
    for (int i=1; i<_missionController->visualItems()->count(); i++) {
        VisualMissionItem* visualItem = _missionController->visualItems()->value<VisualMissionItem*>(i);
        QVERIFY(qIsNaN(visualItem->missionGimbalYaw()));
    }

    // Specify gimbal yaw on settings item should generate yaw on all items
    MissionSettingsItem* settingsItem = _missionController->visualItems()->value<MissionSettingsItem*>(0);
    settingsItem->cameraSection()->setSpecifyGimbal(true);
    settingsItem->cameraSection()->gimbalYaw()->setRawValue(0.0);
    for (int i=1; i<_missionController->visualItems()->count(); i++) {
        VisualMissionItem* visualItem = _missionController->visualItems()->value<VisualMissionItem*>(i);
        QCOMPARE(visualItem->missionGimbalYaw(), 0.0);
    }
}

void MissionControllerTest::_testLoadJsonSectionAvailable(void)
{
    _initForFirmwareType(MAV_AUTOPILOT_PX4);
    _masterController->loadFromFile(":/unittest/SectionTest.plan");

    QmlObjectListModel* visualItems = _missionController->visualItems();
    QVERIFY(visualItems);
    QCOMPARE(visualItems->count(), 5);

    // Check that only waypoint items have camera and speed sections
    for (int i=1; i<visualItems->count(); i++) {
        SimpleMissionItem* item = visualItems->value<SimpleMissionItem*>(i);
        QVERIFY(item);
        if ((int)item->command() == MAV_CMD_NAV_WAYPOINT) {
            QCOMPARE(item->cameraSection()->available(), true);
            QCOMPARE(item->speedSection()->available(), true);
        } else {
            QCOMPARE(item->cameraSection()->available(), false);
            QCOMPARE(item->speedSection()->available(), false);
        }

    }
}
