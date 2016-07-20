#ifndef OPENCVCOMMONACTION_H
#define OPENCVCOMMONACTION_H

#include "opencvaction.h"


class OpenCVcommonAction : public OpenCVaction
{
    Q_OBJECT
public:
    OpenCVcommonAction();
    ~OpenCVcommonAction();
    void action(Mat &imgin, Mat &imgout);
};

#endif // OPENCVCOMMONACTION_H
