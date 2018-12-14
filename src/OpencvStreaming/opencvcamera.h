#ifndef OPENCVCAMERA_H
#define OPENCVCAMERA_H

#include <QObject>

#include "opencvcapture.h"
#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <lynmax4d/Export.h>

class OpenCVcamera : public OpenCVcapture
{
    Q_OBJECT
    Q_PROPERTY(int m_cameraId READ cameraId WRITE setCameraId NOTIFY cameraIdChanged)
public:
    OpenCVcamera(QObject *parent = NULL);
    ~OpenCVcamera();

    int cameraId() const;
    void setCameraId(int id);

    virtual void setRun(bool r);

    Mat getFrame();




signals:
    void cameraIdChanged();
    void runChanged();
    void frame(const QImage &img);
public slots:

protected:


protected slots:

private:
    int m_cameraId;
    int m_openedCameraId;
    Mat m_frame;
    char* buffer;
//    VideoCapture m_Capture;
    int bufferSize;
    int lastFrameNo;
    int width;
    int height;
    int rowPitch;
    int frameNo;
    int id;
    bool isKeyframe;
};

#endif // OPENCVCAMERA_H
