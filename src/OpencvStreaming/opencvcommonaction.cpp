#include "opencvcommonaction.h"

OpenCVcommonAction::OpenCVcommonAction()
{

}

OpenCVcommonAction::~OpenCVcommonAction()
{

}

void OpenCVcommonAction::action(Mat &imgin, Mat &imgout)
{
       cvtColor(imgin, imgout, CV_BGR2RGB);
//    imgout = cvCreateImage(cvGetSize(imgin), imgin->depth, imgin->nChannels);
//    cvCvtColor(imgin, imgout, CV_BGR2RGB);
//    rectangle(imgout,cvPoint(Rectbox.x,Rectbox.y),cvPoint(Rectbox.x+Rectbox.width,Rectbox.y+Rectbox.height),CV_RGB(0, 0, 255), 2, CV_AA);
}

