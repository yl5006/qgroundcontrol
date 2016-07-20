#ifndef OPENCVTRACKER_H
#define OPENCVTRACKER_H
#include "opencvaction.h"
#include <vector>

#include "typedef.h"

class Tracker : public OpenCVaction
{
    Q_OBJECT
public:
    Tracker(QObject *parent = 0);
    ~Tracker();

    void action(Mat &imgin, Mat &imgout);

private:
    Mat Maskframe;
    Mat H_prev;
    GridAdaptedFeatureDetector detector;
    const int DESIRED_FTRS = 500;
    bool init=false;
    vector<Point2f> train_pts;
    vector<Point2f> query_pts;
    vector<KeyPoint> train_kpts;
    vector<KeyPoint> query_kpts;
    Mat train_desc;
    Mat query_desc;
    BriefDescriptorExtractor brief;
    BFMatcher desc_matcher;
    vector<DMatch> matches;
    vector<unsigned char> match_mask;

    void drawMatchesRelative(const vector<KeyPoint>& train, const vector<KeyPoint>& query,std::vector<cv::DMatch>& matches, Mat& img,const vector<unsigned char>& mask = vector<
            unsigned char>());
    void keypoints2points(const vector<KeyPoint>& in, vector<Point2f>& out);
    void points2keypoints(const vector<Point2f>& in, vector<KeyPoint>& out);
    void warpKeypoints(const Mat& H, const vector<KeyPoint>& in, vector<KeyPoint>& out);
    void matches2points(const vector<KeyPoint>& train, const vector<KeyPoint>& query,const std::vector<cv::DMatch>& matches, std::vector<cv::Point2f>& pts_train,std::vector<Point2f>& pts_query);
    void resetH(Mat&H);

    int x;
    int y;
};

#endif // OPENCVTRACKER_H
