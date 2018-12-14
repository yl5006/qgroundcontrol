#ifndef OPENCVSHOWFRAME_H
#define OPENCVSHOWFRAME_H

#include <QQuickItem>
#include <QOpenGLContext>
#include <QSGTexture>
#include <QTimer>
#include <list>
#include <QImage>
#include <opencv/cv.h>
#include <opencv/highgui.h>
#include "opencvaction.h"
#include "opencvcannyaction.h"
#include "opencvcommonaction.h"
#include "tracker.h"
class OpenCVcapture;
class OpencvFaceRecognizer;
class OpenCVfaceDetectAction;

class OpenCVshowFrame : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(int m_frameRate READ frameRate WRITE setFrameRate NOTIFY frameRateChanged)
    Q_PROPERTY(bool m_run READ run WRITE setRun NOTIFY runChanged)
    Q_PROPERTY(QObject* m_capture READ capture WRITE setCapture NOTIFY captureChanged)
public:
    explicit OpenCVshowFrame(QQuickItem *parent = 0);
    ~OpenCVshowFrame();

    int frameRate() const;
    void setFrameRate(int rate);

    bool run() const;
    void setRun(bool r);

    QObject* capture() const;
    void setCapture(QObject *c);

    Q_INVOKABLE void addAction(QObject *act);

    Q_INVOKABLE void startPredict();

    Q_INVOKABLE void setLabel(int i);

    Q_INVOKABLE void startTrain();

signals:
    void frameRateChanged();
    void runChanged();
    void captureChanged();
    void who(int i);

protected slots:
    void updateFrame();

protected:
    QSGNode* updatePaintNode(QSGNode * old, UpdatePaintNodeData *);
    void mousePressEvent(QMouseEvent *event);
    void mouseMoveEvent(QMouseEvent *event);
    void mouseReleaseEvent(QMouseEvent *event);
private:
    int m_frameRate;
    bool m_run;
    bool m_bEnabled;
    bool m_bPressed;
    bool m_bMoved;
    float x_scale;
    float y_scale;
    QPoint currPt;
    QObject *m_capture;
    QTimer m_timer;
    std::list<QObject*> m_actions;
    Mat  doActions(Mat &img);
    QSGTexture *texture;
//    OpencvFaceRecognizer *f;
//    Tracker *f;
//    OpenCVfaceDetectAction *f;
    OpenCVcommonAction *f;
    QImage imgshow;
    uchar *imgData;
    Mat frame;
    Mat out;
};

#endif // OPENCVSHOWFRAME_H
