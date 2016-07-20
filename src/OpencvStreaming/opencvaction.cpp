#include "opencvaction.h"

OpenCVaction::OpenCVaction(QObject *parent) : QObject(parent),
    Rectbox(0,0,0,0),
    select(false)
{

}

OpenCVaction::~OpenCVaction()
{

}

