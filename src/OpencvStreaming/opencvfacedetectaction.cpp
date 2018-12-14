#include "opencvfacedetectaction.h"
#include <QDebug>
#include <QTime>

OpenCVfaceDetectAction::OpenCVfaceDetectAction(QObject *parent): OpenCVaction(parent)
{
    if( !m_cascade.load("haarcascade_frontalface_alt.xml") )
    {
        qDebug() << "load Cascade fail!";
    }
}

OpenCVfaceDetectAction::~OpenCVfaceDetectAction()
{
}

void OpenCVfaceDetectAction::action(Mat &imgin, Mat &imgout)
{
      std::vector<Rect> faces;

      cvtColor(imgin, imgout, CV_BGR2RGB);
      cvtColor(imgin, frame_gray, CV_BGR2GRAY );
      equalizeHist( frame_gray, frame_gray );

      //-- Detect faces
      m_cascade.detectMultiScale( frame_gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, Size(30, 30) );

      for( size_t i = 0; i < faces.size(); i++ )
      {
        Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
        ellipse( imgout, center, Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, Scalar( 255, 255, 255 ), 4, 8, 0 );

//        Mat faceROI = frame_gray( faces[i] );
//        std::vector<Rect> eyes;

//        //-- In each face, detect eyes
//        eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0 |CV_HAAR_SCALE_IMAGE, Size(30, 30) );

//        for( size_t j = 0; j < eyes.size(); j++ )
//         {
//           Point center( faces[i].x + eyes[j].x + eyes[j].width*0.5, faces[i].y + eyes[j].y + eyes[j].height*0.5 );
//           int radius = cvRound( (eyes[j].width + eyes[j].height)*0.25 );
//           circle( imgout, center, radius, Scalar( 255, 0, 0 ), 4, 8, 0 );
//         }
      }
}

