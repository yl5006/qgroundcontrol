#include "opencvshowframe.h"
#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <opencv2/contrib/contrib.hpp>
#include "opencvcapture.h"
#include <QSGTexture>
#include <QSGSimpleTextureNode>
#include <QQuickWindow>

#include "opencvfacedetectaction.h"
#include "opencvfacerecognizer.h"

//using namespace cv;
OpenCVshowFrame::OpenCVshowFrame(QQuickItem *parent) : QQuickItem(parent),
    m_frameRate(16),
    m_run(false),
    m_bEnabled(true),
    m_bPressed(false),
    m_bMoved(false),
    x_scale(1.0),
    y_scale(1.0),
    m_capture(NULL)
{
    m_timer.setInterval(1000 / m_frameRate);
    connect(&m_timer, &QTimer::timeout, this, &OpenCVshowFrame::updateFrame);
    setAcceptedMouseButtons(Qt::LeftButton);
    setFlag(QQuickItem::ItemHasContents);
   // m_actions.push_back(new OpenCVcommonAction());
    f = new Tracker();
   // f.Rectbox
    m_actions.push_back(f);

 /*OpenCVfaceDetectAction **/
 //   f = new OpenCVfaceDetectAction();
 //  m_actions.push_back(f);
 //connect(f, &OpenCVfaceDetectAction::a, this, &OpenCVshowFrame::a);

 // using namespace cv;
 //Ptr<FaceRecognizer> r = createFisherFaceRecognizer();

 /*OpencvFaceRecognizer **/
  //fr = new OpencvFaceRecognizer(this);
//    fr->loadRecognizer();

//   connect(f, &OpenCVfaceDetectAction::train, fr, &OpencvFaceRecognizer::train);
//   connect(f, &OpenCVfaceDetectAction::predict, fr, &OpencvFaceRecognizer::predict);

//    connect(fr, &OpencvFaceRecognizer::who, this, &OpenCVshowFrame::who);
}
void OpenCVshowFrame:: mousePressEvent(QMouseEvent* event)
  {
    m_bMoved = false;
    if(!m_bEnabled || !(event->button() & acceptedMouseButtons()))
        {
            OpenCVshowFrame::mousePressEvent(event);
        }
        else
        {
    //        qDebug() << "mouse pressed" <<event->pos();
            m_bPressed = true;
            event->setAccepted(true);
            currPt=event->pos();

        }
  }
void OpenCVshowFrame::mouseReleaseEvent(QMouseEvent* event)
{
    if(!m_bEnabled || !(event->button() & acceptedMouseButtons()))
    {
        OpenCVshowFrame::mousePressEvent(event);
    }
    else
    {
    //    qDebug() << "mouse released"<<event->pos();
        m_bPressed = false;
        m_bMoved = false;
        f->select=true;
    }
}
void OpenCVshowFrame:: mouseMoveEvent(QMouseEvent* event)
{
    if(!m_bEnabled || !m_bPressed )
        {
            OpenCVshowFrame::mousePressEvent(event);
        }
        else
        {
            f->Rectbox.x = MIN(event->x()/x_scale, currPt.x()/x_scale);
            f->Rectbox.y = MIN(event->y()/y_scale, currPt.y()/y_scale);
            f->Rectbox.width =  std::abs(event->x()/x_scale - currPt.x()/x_scale);
            f->Rectbox.height = std::abs(event->y()/y_scale - currPt.y()/y_scale);
   //         qDebug() << "mouse move"<<event->pos();
        }
}
OpenCVshowFrame::~OpenCVshowFrame()
{
    for (auto ite = m_actions.begin(); ite != m_actions.end(); ++ite) {
        (*ite)->deleteLater();
    }
    m_actions.clear();
}

int OpenCVshowFrame::frameRate() const
{
    return m_frameRate;
}

void OpenCVshowFrame::startPredict()
{
 //   f->startPredict();
}

void OpenCVshowFrame::setLabel(int i)
{
 //   f->setLabel(i);
}

void OpenCVshowFrame::startTrain()
{
 //   f->startTrain();
}

void OpenCVshowFrame::setFrameRate(int rate)
{
    if (rate <= 0) {
        rate = 24;
    }
    m_frameRate = rate;
    if (m_timer.isActive()) {
        m_timer.stop();
        m_timer.start(1000 / m_frameRate);
    } else {
        m_timer.setInterval(1000 / m_frameRate);
    }
}

bool OpenCVshowFrame::run() const
{
    return m_run;
}

void OpenCVshowFrame::setRun(bool r)
{
    m_run = r;
    if (m_run) {
        if (!m_timer.isActive())
            m_timer.start();
    } else {
        if (m_timer.isActive())
            m_timer.stop();
    }
}

QObject* OpenCVshowFrame::capture() const
{
    return m_capture;
}

void OpenCVshowFrame::setCapture(QObject *c)
{
    m_capture = c;
}

void OpenCVshowFrame::updateFrame()
{
    OpenCVcapture *cap = static_cast<OpenCVcapture*>(m_capture);
    if (cap->run()) {
        update();
    }
}


void OpenCVshowFrame::addAction(QObject *act)
{
    m_actions.push_back(act);
}

Mat  OpenCVshowFrame::doActions(Mat &img)
{
    Mat out;
    if (m_actions.empty()) {
    } else {
        for (auto ite = m_actions.begin(); ite != m_actions.end(); ++ite) {
            OpenCVaction *act = static_cast<OpenCVaction*>(*ite);           
            act->action(img, out);
        }
    }
    return out;
}


QImage::Format OpenCVshowFrame::format(int depth, int nChannels)
{
    QImage::Format re = QImage::Format_Invalid;
    do {
        if (depth == 8 && nChannels == 1) {
            re = QImage::Format_RGB888;
            break;
        }
        if (nChannels == 3) {
            re = QImage::Format_RGB888;
            break;
        }

    }while(0);

    return re;
}


QSGNode* OpenCVshowFrame::updatePaintNode(QSGNode *old, UpdatePaintNodeData *)
{
    QSGSimpleTextureNode *texture = static_cast<QSGSimpleTextureNode*>(old);
    if (texture == NULL) {
        texture = new QSGSimpleTextureNode();
    }
    QImage img;
    Mat frame;
    if (m_capture) {
        frame = static_cast<OpenCVcapture*>(m_capture)->getFrame();
    }
    if (!frame.empty()) {
        frame = doActions(frame);
        uchar *imgData = frame.data;
        x_scale=(float)window()->width()/frame.cols;
        y_scale=(float)window()->height()/frame.rows;
   //     qDebug()<<"x_scale"<<x_scale<<"y_scale"<<y_scale;
        img = QImage(imgData, frame.cols, frame.rows, QImage::Format_RGB888);
    } else {
        img = QImage(boundingRect().size().toSize(), QImage::Format_RGB888);
    }
    QSGTexture *t = window()->createTextureFromImage(img.scaled(boundingRect().size().toSize()));
    if (t) {
        QSGTexture *tt = texture->texture();
        if (tt) {
            tt->deleteLater();
        }
        texture->setRect(boundingRect());
        texture->setTexture(t);
    }
    return texture;
}
