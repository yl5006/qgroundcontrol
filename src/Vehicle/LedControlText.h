/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#pragma once

#include <QString>
#include <QThread>
#include <QByteArray>

#include <atomic>
#include "Vehicle.h"
class Vehicle;
/**
 ** class LedControl
*/
class LedControl : public QThread
{
    Q_OBJECT
public:
    LedControl(Vehicle* vehicle);
    ~LedControl();
    int docommand(QString cmd);
    void SetText(QString text);    
    void SetLoop(bool loop);
signals:

protected:
    Vehicle*    _vehicle;
    QString _text;
    bool _cancel;
    void run();
};
