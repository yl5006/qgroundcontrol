#ifndef OPENCVACTION_H
#define OPENCVACTION_H

#include <QObject>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "highgui.h"
#include "cv.h"
using namespace cv;
class OpenCVaction : public QObject
{
    Q_OBJECT
public:
    explicit OpenCVaction(QObject *parent = 0);
    virtual ~OpenCVaction();
    virtual void action(Mat &imgin, Mat &imgout) = 0;
    Rect Rectbox;
    bool select;
signals:

public slots:
};

#endif // OPENCVACTION_H
