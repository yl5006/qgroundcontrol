﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "PositionManager.h"
#include "QGCApplication.h"
#include "QGCCorePlugin.h"
#include "GPSManager.h"
QGCPositionManager::QGCPositionManager(QGCApplication* app, QGCToolbox* toolbox)
    : QGCTool           (app, toolbox)
    , _updateInterval   (0)
    , _currentSource    (NULL)
	, _gpsManager		(NULL)
    , _defaultSource    (NULL)
    , _nmeaSource       (NULL)
    , _simulatedSource  (NULL)
{

}

QGCPositionManager::~QGCPositionManager()
{
    delete(_simulatedSource);
    delete(_nmeaSource);
}

void QGCPositionManager::setToolbox(QGCToolbox *toolbox)
{
   QGCTool::setToolbox(toolbox);
   //-- First see if plugin provides a position source
   _defaultSource = toolbox->corePlugin()->createPositionSource(this);
   if(!_defaultSource) {
       //-- Otherwise, create a default one
       _defaultSource = QGeoPositionInfoSource::createDefaultSource(this);
       qDebug() << _defaultSource;
   }
   _simulatedSource = new SimulatedPosition();

   // Enable this to get a simulated target on desktop
   // if (_defaultSource == nullptr) {
   //     _defaultSource = _simulatedSource;
   // }
   _gpsManager  =    _toolbox->gpsManager();
   setPositionSource(QGCPositionSource::InternalGPS);
}

void QGCPositionManager::setNmeaSourceDevice(QIODevice* device)
{
    if (_nmeaSource) {
        delete _nmeaSource;
    }
    _nmeaSource = new QNmeaPositionInfoSource(QNmeaPositionInfoSource::RealTimeMode, this);
    _nmeaSource->setDevice(device);
    setPositionSource(QGCPositionManager::NmeaGPS);
}

void QGCPositionManager::_positionUpdated(const QGeoPositionInfo &update)
{
    emit lastPositionUpdated(update.isValid(), QVariant::fromValue(update.coordinate()));
    emit positionInfoUpdated(update);
}

void QGCPositionManager::GPSPositionUpdate(GPSPositionMessage msg)
{
    QGeoCoordinate msggps;
    msggps.setLatitude(msg.position_data.lat*1e-7);
    msggps.setLongitude(msg.position_data.lon*1e-7);
    qDebug() << QString("GPS: got position update: alt=%1, long=%2, lat=%3").arg(msg.position_data.alt).arg(msg.position_data.lon).arg(msg.position_data.lat);
    emit lastPositionUpdated(true, QVariant::fromValue(msggps));
}

int QGCPositionManager::updateInterval() const
{
    return _updateInterval;
}

void QGCPositionManager::setPositionSource(QGCPositionManager::QGCPositionSource source)
{
    if (_currentSource != nullptr) {
        _currentSource->stopUpdates();
        disconnect(_currentSource);
    }

    if (qgcApp()->runningUnitTests()) {
        // Units test on travis fail due to lack of position source
        return;
    }

    switch(source) {
    case QGCPositionManager::Log:
        break;
    case QGCPositionManager::Simulated:
        _currentSource = _simulatedSource;
        break;
    case QGCPositionManager::NmeaGPS:
        _currentSource = _nmeaSource;
        break;
    case QGCPositionManager::InternalGPS:
		connect(_gpsManager, &GPSManager::positionUpdated, this, &QGCPositionManager::GPSPositionUpdate);
		break;
    default:        
        _currentSource = _defaultSource;
        break;
    }

    if (_currentSource != nullptr) {
        _updateInterval = _currentSource->minimumUpdateInterval();
        _currentSource->setPreferredPositioningMethods(QGeoPositionInfoSource::SatellitePositioningMethods);
        _currentSource->setUpdateInterval(_updateInterval);
        connect(_currentSource, &QGeoPositionInfoSource::positionUpdated,       this, &QGCPositionManager::_positionUpdated);
        connect(_currentSource, SIGNAL(error(QGeoPositionInfoSource::Error)),   this, SLOT(_error(QGeoPositionInfoSource::Error)));
        _currentSource->startUpdates();
    }
}

void QGCPositionManager::_error(QGeoPositionInfoSource::Error positioningError)
{
    qWarning() << "QGCPositionManager error" << positioningError;
}
