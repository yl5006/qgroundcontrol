#include "opencvcannyaction.h"

OpenCVcannyAction::OpenCVcannyAction(QObject *parent): OpenCVaction(parent)
{

}

OpenCVcannyAction::~OpenCVcannyAction()
{

}

void OpenCVcannyAction::action(Mat &imgin, Mat &imgout)
{

    Mat pIplImageCanny;
    cvtColor(imgin, pIplImageCanny, CV_RGB2GRAY);
    Canny(pIplImageCanny, imgout, 15, 145, 3);
}

