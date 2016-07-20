#include "tracker.h"
#include <QDebug>
#include <QTime>
#include <QVector>
Tracker::Tracker(QObject *parent): OpenCVaction(parent)
{
    detector= GridAdaptedFeatureDetector(new FastFeatureDetector(10, true), DESIRED_FTRS, 4, 4);
    H_prev = Mat::eye(3, 3, CV_32FC1);
    desc_matcher=BFMatcher(NORM_HAMMING);
}

Tracker::~Tracker()
{
}
//Takes a descriptor and turns it into an xy point
void Tracker::keypoints2points(const vector<KeyPoint>& in, vector<Point2f>& out)
    {
        out.clear();
        out.reserve(in.size());
        for (size_t i = 0; i < in.size(); ++i)
        {
            out.push_back(in[i].pt);
        }
    }

    //Takes an xy point and appends that to a keypoint structure
void Tracker::points2keypoints(const vector<Point2f>& in, vector<KeyPoint>& out)
    {
        out.clear();
        out.reserve(in.size());
        for (size_t i = 0; i < in.size(); ++i)
        {
            out.push_back(KeyPoint(in[i], 1));
        }
    }

    //Uses computed homography H to warp original input points to new planar position
void Tracker::warpKeypoints(const Mat& H, const vector<KeyPoint>& in, vector<KeyPoint>& out)
    {
        vector<Point2f> pts;
        keypoints2points(in, pts);
        vector<Point2f> pts_w(pts.size());
        Mat m_pts_w(pts_w);
        perspectiveTransform(Mat(pts), m_pts_w, H);
        points2keypoints(pts_w, out);
    }

    //Converts matching indices to xy points
void Tracker::matches2points(const vector<KeyPoint>& train, const vector<KeyPoint>& query,
        const std::vector<cv::DMatch>& matches, std::vector<cv::Point2f>& pts_train,
        std::vector<Point2f>& pts_query)
    {

        pts_train.clear();
        pts_query.clear();
        pts_train.reserve(matches.size());
        pts_query.reserve(matches.size());

        size_t i = 0;

        for (; i < matches.size(); i++)
        {

            const DMatch & dmatch = matches[i];

            pts_query.push_back(query[dmatch.queryIdx].pt);
            pts_train.push_back(train[dmatch.trainIdx].pt);

        }

    }

void Tracker::resetH(Mat&H)
    {
        H = Mat::eye(3, 3, CV_32FC1);
    }
void Tracker::drawMatchesRelative(const vector<KeyPoint>& train, const vector<KeyPoint>& query,std::vector<cv::DMatch>& matches, Mat& img,const vector<unsigned char>& mask)
    {
    int j=0;
    Point2f pt_move(0, 0);
    for (int i = 0; i < (int)matches.size(); i++)
    {
        if (mask.empty() || mask[i])
        {
            Point2f pt_new = query[matches[i].queryIdx].pt;
            Point2f pt_old = train[matches[i].trainIdx].pt;
            Point2f pt_move1  = query[matches[i].queryIdx].pt - train[matches[i].trainIdx].pt;
            pt_move = pt_move + pt_move1;
            j++;
            cv::line(img, pt_new, pt_old, Scalar(125, 255, 125), 1);
              //cv::circle(img, pt_new, 2, Scalar(255, 0, 125), 1);

        }
    }
    pt_move.x = pt_move.x /j;
    pt_move.y = pt_move.y /j;
    Rectbox.x = Rectbox.x + (int)pt_move.x;
    Rectbox.y = Rectbox.y + (int)pt_move.y;
//    train_kpts = query_kpts;
//    query_desc.copyTo(train_desc);
//    for (int i = 0; i < frame.cols; i++)
//        for (int j = 0; j < frame.rows; j++)
//            maskframe.at<uchar>(Point(i, j)) = 0;
//    rectangle(maskframe, Rectbox, Scalar(255, 255, 255), -1, 8, 0);
//    ref_live = true;
//    qDebug() << "move " << (int)pt_move.x << "," << (int)pt_move.y << "j:" << j << endl;
}

void Tracker::action(Mat &imgin, Mat &imgout)
{
    if(!init)
    {
        Maskframe = cvCreateMat(imgin.rows, imgin.cols, CV_8UC1);
        init=true;
    }
    for (int i = 0; i<imgin.cols; i++)
         for (int j = 0; j<imgin.rows; j++)
             Maskframe.at<uchar>(Point(i, j)) = 0;

    Mat gray;
    cvtColor(imgin, imgout, CV_BGR2RGB);
    cvtColor(imgin, gray, COLOR_RGB2GRAY);
    rectangle(Maskframe, Rectbox, Scalar(255, 255, 255), -1, 8, 0);
    detector.detect(gray, query_kpts, Maskframe); //Find interest points
    brief.compute(gray, query_kpts, query_desc); //Compute brief descriptors at each keypoint location
    if (!train_kpts.empty())
    {

        vector<KeyPoint> test_kpts;
        warpKeypoints(H_prev.inv(), query_kpts, test_kpts);

        Mat mask = windowedMatchingMask(test_kpts, train_kpts, 25,25);
        desc_matcher.match(query_desc, train_desc, matches, mask);
//		drawKeypoints(frame, test_kpts, frame, Scalar(255, 0, 0), DrawMatchesFlags::DRAW_OVER_OUTIMG);

        matches2points(train_kpts, query_kpts, matches, train_pts, query_pts);

        if (matches.size() > 5)
        {
            Mat H = findHomography(train_pts, query_pts, RANSAC, 4, match_mask);
            if (countNonZero(Mat(match_mask)) > 15)
            {
                H_prev = H;

            }
            else
                resetH(H_prev);
            drawMatchesRelative(train_kpts, query_kpts, matches, imgout, match_mask);
        }
        else
            resetH(H_prev);

    }

//    else
//    {
//        H_prev = Mat::eye(3, 3, CV_32FC1);
//        Mat out;
//        drawKeypoints(gray, query_kpts, out);
//        imgout = out;
//    }
    rectangle(imgout, Rectbox, Scalar(0, 0, 255), 3);
    train_kpts = query_kpts;
    query_desc.copyTo(train_desc);

//    if (init&&select)
//    {
//        select = false;
//        train_kpts = query_kpts;
//        query_desc.copyTo(train_desc);
//    }
//    imgout = cvCreateImage(cvGetSize(imgin), imgin->depth, imgin->nChannels);
//    cvCvtColor(imgin, imgout, CV_BGR2RGB);
//    cvRectangle(imgout,cvPoint(Rectbox.x,Rectbox.y),cvPoint(Rectbox.x+Rectbox.width,Rectbox.y+Rectbox.height),CV_RGB(0, 0, 255), 2, CV_AA);


//    IplImage* gray = cvCreateImage(cvGetSize(imgin), 8, 1);
//    IplImage* small_img = cvCreateImage(cvSize(cvRound(imgin->width / m_scale),
//                                               cvRound(imgin->height / m_scale)), 8, 1);

//    cvCvtColor(imgin, gray, CV_BGR2GRAY);
//    cvResize(gray, small_img, CV_INTER_LINEAR);


//    cvReleaseImage(&gray);
//    cvReleaseImage(&small_img);


}
