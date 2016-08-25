#ifndef OPENCVFACEDETECTACTION_H
#define OPENCVFACEDETECTACTION_H
#include "opencvaction.h"
#include <vector>

#include "typedef.h"

class OpenCVfaceDetectAction : public OpenCVaction
{
    Q_OBJECT
public:
    OpenCVfaceDetectAction(QObject *parent = 0);
    ~OpenCVfaceDetectAction();

    void action(Mat &imgin, Mat &imgout);

private:
    CascadeClassifier m_cascade;


};

#endif // OPENCVFACEDETECTACTION_H
