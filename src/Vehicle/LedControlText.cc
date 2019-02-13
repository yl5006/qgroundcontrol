/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "LedControlText.h"
#include <QDebug>
#include "Vehicle.h"

#define lineA   0
#define lineB   1
#define lineAB  2
#define lineA_B 3
#define ledOff  0
#define ledOn   1
LedControl::LedControl(Vehicle* vehicle)
    :_vehicle(vehicle)
    ,_text("")
    ,_cancel(false)
{

}

LedControl::~LedControl()
{
    if(this->isRunning())
    {
        this->exit();
    }
}

void LedControl::run()
{
    int i=0;
    QStringList linelist= _text.split("\r");
    for(i=0;i<linelist.length();i++)
    {
        docommand(linelist[i]);
    }
    this->msleep(200);
    _vehicle->setLedLineStatus(lineAB,1.0,ledOff);
    if(_cancel)
    {
       return;
    }
    this->msleep(10000);
    _vehicle->setLedLineStatus(lineA_B,1.0,ledOff);
    if(_cancel)
    {
       return;
    }
    this->msleep(10000);
    _vehicle->setLedLineStatus(lineAB,0.0,ledOff);
}
int LedControl::docommand(QString cmd)
{
    QStringList cmdlist = cmd.split(" ");
    if(cmdlist.length()<2)
    {
        return -1;
    }
    if(cmdlist[0].compare("A"))
    {

    }else if(cmdlist[0].compare("B"))
    {

    }else if(cmdlist[0].compare("AB"))
    {

    }else if(cmdlist[0].compare("A_B"))
    {

    }else
    {
        return -2;
    }



}

void LedControl::SetText(QString text)
{
    _text = text;
}
void LedControl::SetLoop(bool cancel)
{
    _cancel = cancel;
}


