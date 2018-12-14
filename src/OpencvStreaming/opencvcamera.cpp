#include "opencvcamera.h"
//#include <QSGSimpleTextureNode>
//#include <QQuickWindow>
//#include <QTimer>
#include <QDebug>


OpenCVcamera::OpenCVcamera(QObject *parent): OpenCVcapture(parent),
    m_cameraId(0),
    bufferSize(0),
    isKeyframe(false),
    lastFrameNo(-1),
    m_openedCameraId(-1)
{
}



OpenCVcamera::~OpenCVcamera()
{
//    if (m_Capture.isOpened()) {
//        m_Capture.release();
//    }
    m_frame = NULL;
}

int OpenCVcamera::cameraId() const
{
    return m_cameraId;
}


void OpenCVcamera::setCameraId(int id)
{
    m_cameraId = id;
}



void userLogFunction(const char* msg, int level)
{
    printf("[Log-%d] %s\n", level, msg);
}


void OpenCVcamera::setRun(bool r)
{
    m_run = r;
    if (m_run) {
//        if (!m_Capture.isOpened()) {
//            m_Capture.open(m_cameraId);//rtmp://live.hkstv.hk.lxdns.com/live/hks
//              rtmp://v68822e58.live.126.net/live/c91658fee21c4706884286dc3120c5ac
//            m_openedCameraId = m_cameraId;
//        } else if (m_cameraId != m_openedCameraId){
//            m_Capture.release();
//            m_Capture.open(m_cameraId);
//            m_openedCameraId = m_cameraId;
//        }
        // Obtain video attributes from created ID
         printf("Plugin %s: %d\n", getPluginName(), getPluginVersion());
         setUserLogFunction(userLogFunction);
         id = startVideoStreamFromDevice(0, bufferSize);
         getVideoFrameAttributes(id, &width, &height, &rowPitch);
         qDebug()<<bufferSize<<width<<height<< id;

    } else {
//        if (m_Capture.isOpened()) {
//            m_Capture.release();
//            //m_cameraId = 0;
//            m_openedCameraId = -1;
//        }
         finishVideoStream(id);
    }
}

Mat OpenCVcamera::getFrame()
{
//    if (m_Capture.isOpened()) {
//        m_Capture >> m_frame;
//    } else {
//        m_frame = NULL;
//    }
// Obtain video frame from created ID
    getVideoFrameAttributes(id, &width, &height, &rowPitch);
    if (width > 0 && height > 0)
    {

    buffer = getVideoBuffer(id, &bufferSize, &frameNo, &isKeyframe);
    if (frameNo <= lastFrameNo) return m_frame; else lastFrameNo = frameNo;
    m_frame = cv::Mat(height, width, CV_8UC3, buffer, rowPitch);
    }
    return m_frame;
}







