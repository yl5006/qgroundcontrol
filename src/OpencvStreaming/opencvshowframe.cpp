#include "opencvshowframe.h"
#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <opencv2/contrib/contrib.hpp>
#include "opencvcapture.h"
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
    texture(nullptr),
    m_capture(NULL)
{
    m_timer.setInterval( 1000 / m_frameRate);
    connect(&m_timer, &QTimer::timeout, this, &OpenCVshowFrame::updateFrame);
    setAcceptedMouseButtons(Qt::LeftButton);
    setFlag(QQuickItem::ItemHasContents);
   // m_actions.push_back(new OpenCVcommonAction());
//    f = new OpenCVcommonAction();
   // f.Rectbox
//   m_actions.push_back(f);

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
//        f->select=true;
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
//            f->Rectbox.x = MIN(event->x()/x_scale, currPt.x()/x_scale);
//            f->Rectbox.y = MIN(event->y()/y_scale, currPt.y()/y_scale);
//            f->Rectbox.width =  std::abs(event->x()/x_scale - currPt.x()/x_scale);
//            f->Rectbox.height = std::abs(event->y()/y_scale - currPt.y()/y_scale);
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
    if (m_actions.empty()) {
    } else {
        for (auto ite = m_actions.begin(); ite != m_actions.end(); ++ite) {
            OpenCVaction *act = static_cast<OpenCVaction*>(*ite);           
            act->action(img, out);
        }
    }
    return out;
}

QSGNode* OpenCVshowFrame::updatePaintNode(QSGNode *old, UpdatePaintNodeData *)
{

    QSGSimpleTextureNode *storedTextureNode  = static_cast<QSGSimpleTextureNode*>(old);
    if (storedTextureNode  == NULL) {
        storedTextureNode  = new QSGSimpleTextureNode();
    }
    if (m_capture) {
        frame = static_cast<OpenCVcapture*>(m_capture)->getFrame();
    }
    if (!frame.empty()) {
//        frame = doActions(frame);
        cvtColor(frame, out, CV_BGR2RGB);
        imgData = out.data;
//      x_scale=(float)window()->width()/frame.cols;
//      y_scale=(float)window()->height()/frame.rows;
        imgshow = QImage(const_cast<const uchar *>(imgData), frame.cols, frame.rows, QImage::Format_RGB888);
    } else {
        imgshow.load(":/res/thumb.png");
    }
//    if( texture ) {
//        texture->deleteLater();
//        texture = nullptr;
//    }
    //.scaled(boundingRect().size().toSize())
    //会出现QImage: out of memory, returning null image
 //   if(boundingRect().size().toSize().width()<600)
    {
        texture = window()->createTextureFromImage(imgshow.scaled(boundingRect().size().toSize(),Qt::KeepAspectRatioByExpanding));
    }
    if (texture) {
           QSGTexture *tt = storedTextureNode->texture();
           if (tt) {
               tt->deleteLater();
           }
           storedTextureNode->setRect(boundingRect());
           storedTextureNode->setTexture(texture);
       }
//    else
//    {
//        texture = window()->createTextureFromImage(imgshow.scaled(QSize(600,338)), QQuickWindow::TextureOwnsGLTexture);
//    }
//    if(texture)
//    {
//        QSGTexture *tt = storedTextureNode->texture();
//        if(tt) {
//            tt->deleteLater();
//        }
//    }
    // Ensure texture lives in rendering thread so it will be deleted only once it's no longer associated with
    // the texture node
//    texture->moveToThread( window()->openglContext()->thread() );

//    // Put this new texture into our QSG node and mark the node dirty so it'll be redrawn
//    storedTextureNode->setTexture( texture );
//    storedTextureNode->setRect( boundingRect() );
//    storedTextureNode->setTextureCoordinatesTransform(QSGSimpleTextureNode::NoTransform);

//    storedTextureNode->markDirty( QSGNode::DirtyForceUpdate );
//    if (texture) {
//        QSGTexture *tt = texture->texture();
//        if (tt) {
//            tt->deleteLater();
//        }
//        texture->setRect(boundingRect());
//        texture->setTexture(t);
//    }
//    return storedTextureNode;
    return storedTextureNode;
}
