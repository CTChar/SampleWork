/*
 * main.cpp
 *
 *  Created on: Nov 12, 2014
 *      Author: chad
 */

#include <iostream>
#include <fstream>
#include <algorithm>
#include <opencv2/opencv.hpp>
//#include <vector>

using namespace cv;
using namespace std;

const bool DISPLAY_ON = true;

const int MY_WINDOW_TYPE = WINDOW_NORMAL;

const double CENTER_THETA_MAX = 45.0 * CV_PI / 180.0;
const int MAX_COL_COUNT = 24;
const int MAX_ROW_COUNT = 50;
const int SPLIT_COUNT = 3;

const double COL_COUNT_SHIFT = -1.4;
const double ROW_COUNT_SHIFT = -0.7;

const std::string FIG1 = "Original";
const std::string FIG2 = "Laplacian";
const std::string FIG3 = "Rotated";


//const std::string filelist = "/home/chad/SSD_Data/corn_ears/sweet_corn1_cut/filelist.txt";
//const std::string filelist = "/home/chad/SSD_Data/corn_ears/sweet_corn2/filelist.txt";
//const std::string filelist = "/home/chad/SSD_Data/corn_ears/sweet_corn3/filelist.txt";
const std::string filelist = "/home/chad/SSD_Data/corn_ears/sweet_corn4/filelist.txt";
//const std::string filelist = "/home/chad/SSD_Data/corn_ears/recornearimages/filelist.txt";

double compute_quantile(Mat& img, double quantile)
{
    Mat dimg;
    img.convertTo(dimg,CV_64F);
    int index = floor(quantile*dimg.rows*dimg.cols);
    //std::sort(dimg.begin<double>(),dimg.end<double>());
    std::nth_element(dimg.begin<double>(),dimg.begin<double>()+index,dimg.end<double>());

    double val = dimg.at<double>(index);

    return val;
}

template <class T>
T normalize_angle(T angle_in, T angle_ref)
{
    T delta = angle_in - angle_ref;
    while (delta >= CV_PI)
    {
        delta -= 2*CV_PI;
    }
    while (delta < -CV_PI)
    {
        delta += 2*CV_PI;
    }
    return angle_ref + delta;
}

template <class T>
void unwrap_phase(Mat& vec)
{
    bool first_time = true;
    T prev_val = 0;
    for (int i=0;i<vec.rows;i++)
    {
        T * vec_ptr = vec.ptr<T>(i);
        for (int j=0;j<vec.cols;j++)
        {
            if (first_time)
            {
                first_time = false;
                prev_val = vec_ptr[j];
            }
            T new_val = normalize_angle(vec_ptr[j],prev_val);
            vec_ptr[j] = new_val;
            prev_val = new_val;
        }
    }
}

double determine_orientation(Mat& mask)
{
    Mat ATA = Mat::zeros(2,2,CV_64FC1);
    Mat mu = Mat::zeros(2,1,CV_64FC1);

    double count = 0;
    double *pATA = ATA.ptr<double>(0);
    double *pmu = mu.ptr<double>(0);
    for (int i=0;i<mask.rows;i++)
    {
        unsigned char * pmask = mask.ptr<unsigned char>(i);
        for (int j=0;j<mask.cols;j++)
        {
            if (pmask[j])
            {
                count++;
                pmu[0] += i;
                pmu[1] += j;
                pATA[0] += i*i;
                pATA[1] += i*j;
                pATA[3] += j*j;
            }
        }
    }
    pATA[2] = pATA[1];

    ATA = ATA/count;
    mu = mu/count;
    ATA = ATA - mu*mu.t();

    Mat evals, evecs;
    eigen(ATA,evals,evecs);
    double * pevals = evals.ptr<double>(0);
    double * pevecs = evecs.ptr<double>(0);
    double angle;

    if (fabs(pevals[0]) > fabs(pevals[1]))
    {
        angle = -atan(pevecs[1]/pevecs[0]);
    }
    else
    {
        angle = -atan(pevecs[3]/pevecs[2]);
    }

    return angle;
}

void get_corn_mask(Mat& img, Mat& mask)
{
    Mat binary;
    threshold(img, binary, 128, 255, THRESH_BINARY | THRESH_OTSU);
    erode(binary,binary,Mat::ones(5,5,CV_8U));
    std::vector<std::vector<cv::Point> > contours;
    findContours(binary, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);

    double max_area = 0;
    int max_i = -1;
    for (int i = 0; i < (int) contours.size(); i++)
    {
        double area = contourArea(contours[i]);
        if (area > max_area)
        {
            max_area = area;
            max_i = i;
        }
    }
    mask = Mat::zeros(img.size(), CV_8U);
    if (max_i >= 0)
    {
        std::vector<cv::Point> hull;
//        drawContours(mask, contours, max_i, Scalar::all(255), -1);
        convexHull(contours[max_i], hull);
        fillConvexPoly(mask, hull, Scalar::all(255));
    }
}

void extract_corn_center(Mat& img, Mat& mask, Mat& output)
{
    int N = img.rows;
    vector<double> r(N);
    vector<double> xc(N);

    // determine radius and center of each row
    double max_r = 0;
    for (int i = 0; i < N; i++)
    {
        unsigned char * m_ptr = mask.ptr<unsigned char>(i);
        int start = -1;
        int stop = -1;
        for (int j = 0; j < mask.cols; j++)
        {
            if (m_ptr[j] > 0)
            {
                if (start < 0)
                {
                    start = j;
                }
                stop = j;
            }
        }

        if (start >= 0)
        {
            r[i] = 0.5 * (stop - start);
            max_r = std::max(max_r, r[i]);
            xc[i] = 0.5 * (start + stop);
        }
        else
        {
            r[i] = 0;
            xc[i] = 0;
        }
    }

    int first_i = -1;
    int last_i = -1;
    for (int i = 0; i < N; i++)
    {
        if (r[i] > 0.25 * max_r)
        {
            if (first_i < 0)
            {
                first_i = i;
            }
            last_i = i;
        }
    }

    // apply transformation
    int output_cols = (int) round(2 * max_r * CENTER_THETA_MAX);
    int output_rows = last_i - first_i + 1;
    output = Mat::zeros(output_rows, output_cols, CV_8UC1);
    for (int i = first_i; i <= last_i; i++)
    {
        if (r[i] > 0.25 * max_r)
        {
            unsigned char * out_ptr = output.ptr<unsigned char>(i - first_i);
            unsigned char * img_ptr = img.ptr<unsigned char>(i);
            for (int j = 0; j < output_cols; j++)
            {
                double theta = CENTER_THETA_MAX * 2.0 * (double) (j - output_cols / 2) / (double) output_cols;
                double ximg = r[i] * sin(theta) + xc[i];
                int j0 = (int) floor(ximg);
                int j1 = j0 + 1;
                double scale = ximg - j0;
                if (j1 < 0)
                {
                    // completely outside of image, do nothing (already initialized to 0)
                }
                else if (j1 == 0)
                {
                    // far left edge, interpolation not possible
                    out_ptr[j] = img_ptr[j1];
                }
                else if (j0 >= img.cols)
                {
                    // completely outside of image, do nothing (already initialized to 0)
                }
                else if (j0 == img.cols)
                {
                    // far right edge, interpolation not possible
                    out_ptr[j] = img_ptr[j0];
                }
                else
                {
                    // interpolate to get value
                    out_ptr[j] = (1.0 - scale) * img_ptr[j0] + scale * img_ptr[j1];
                }
            }
        }
    }
}

double find_peak(Mat& vec, int min_freq = 0, int max_freq = INT_MAX)
{
    bool found_min = false;

    double * vec_ptr = vec.ptr<double>(0);
    double max_val = -1;
    int max_i = -1;
    for (int i = min_freq + 1; i < std::min(max_freq, vec.rows * vec.cols / 2); i++)
    {
        if (!found_min && vec_ptr[i] > vec_ptr[i - 1])
        {
            found_min = true;
        }
        if (found_min && vec_ptr[i] > max_val)
        {
            max_val = vec_ptr[i];
            max_i = i;
        }
    }

    return max_i;
}

double get_count(Mat& gimg_rot, int N, int min_count = 0, int max_count = INT_MAX, double * median = NULL, Mat* phase_out = NULL)
{
    // Compute Sobel edges
    Mat edges;
    Sobel(gimg_rot, edges, CV_32F, 1, 0, 3);
    Mat win;
    createHanningWindow(win,edges.size(),CV_32F);
    edges = edges.mul(win);

    // compute FFT
    Mat padded;
    if (N <= edges.cols)
    {
        padded = edges;
    }
    else
    {
        copyMakeBorder(edges, padded, 0, 0, 0, N - edges.cols, BORDER_CONSTANT, Scalar::all(0));
    }
    Mat planes[] = { Mat_<float>(padded), Mat::zeros(padded.size(), CV_32F) };
    Mat complexImg;
    merge(planes, 2, complexImg);
    dft(complexImg, complexImg, DFT_ROWS);
    split(complexImg, planes);
    Mat mag;
    Mat phase;
    cartToPolar(planes[0],planes[1],mag,phase);
    //    magnitude(planes[0], planes[1], mag);

    // smooth and accumulate FFT
    GaussianBlur(mag, mag, cv::Size(15, 1), 0, 0);
    pow(mag, 2, mag);
    Mat vec;
    reduce(mag, vec, 0, REDUCE_SUM, CV_64F);


    // find peak
    double freq_to_count = (double) edges.cols / (double) (vec.rows * vec.cols);
    int max_freq = (int) std::min((double) INT_MAX, round((double) max_count / freq_to_count));
    int min_freq = (int) std::max((double) 0, round((double) min_count / freq_to_count));
    double peak_loc = find_peak(vec, min_freq, max_freq);
    if (peak_loc < 0)
    {
        return 0;
    }

    if (median)
    {
        int peak_loc_int = (int)round(peak_loc);
        Mat phase_vec = phase.col(peak_loc_int);
        Mat raw_phase_vec = phase_vec;
        unwrap_phase<float>(phase_vec);
        *median = compute_quantile(phase_vec, 0.5);
        if (phase_out)
        {
            GaussianBlur(phase_vec, *phase_out, cv::Size(1, 15), 0, 0);
//            blur(phase_vec, *phase_out, Size(1, 15));
//            medianBlur(phase_vec, *phase_out, 5);
//            phase_vec.copyTo(*phase_out);
        }

    }


    // compute count
    return peak_loc * freq_to_count;
}

void single_corn(std::string& filename, double& col_count, int& col_count_int, double& row_count, int& row_count_int)
{
    setUseOptimized(true);
    int start_tick = (int)getTickCount();
    if (DISPLAY_ON)
    {
        //namedWindow(FIG1, MY_WINDOW_TYPE);
        //namedWindow(FIG3, MY_WINDOW_TYPE);
    }

    Mat img = imread(filename, 1);
    if (img.cols > 1024)
    {
        Mat temp_img;
        double scale = 1024.0/(double)img.cols;
        resize(img,temp_img,cv::Size(),scale,scale,INTER_AREA);
        img = temp_img;
    }
    if (DISPLAY_ON)
    {
        //imshow(FIG1, img);
    }

    Mat yimg;
    Mat planes[3];

    split(img, planes);
    yimg = 0.5 * planes[1] + 0.5 * planes[2] - 0.5 * planes[0];
    if (DISPLAY_ON)
    {
        //namedWindow("yellow", MY_WINDOW_TYPE);
        //imshow("yellow", yimg);
    }

    if (DISPLAY_ON)
    {
        //namedWindow("corn mask", MY_WINDOW_TYPE);
        //namedWindow("corn center", MY_WINDOW_TYPE);
    }
    Mat mask;
    get_corn_mask(yimg, mask);
    if (DISPLAY_ON)
    {
        //imshow("corn mask", mask);
    }

    double angle = determine_orientation(mask);
    //std::cout << angle * 180 / CV_PI << std::endl;

    Mat M = getRotationMatrix2D(cv::Point(img.cols / 2, img.rows / 2), angle * 180 / CV_PI, 1);
    Mat img_rot;
    Mat gimg_rot;
    Mat mask_rot;
    warpAffine(img, img_rot, M, cv::Size(img.cols, img.rows));
    warpAffine(mask, mask_rot, M, cv::Size(mask.cols, mask.rows));
    cvtColor(img_rot, gimg_rot, COLOR_BGR2GRAY);

    Mat corn_center;
    Mat map_x;
    Mat map_y;
    extract_corn_center(gimg_rot, mask_rot, corn_center);
    if (corn_center.rows > 512)
    {
        Mat temp_img;
        double scale = 512.0/(double)corn_center.rows;
        resize(corn_center,temp_img,cv::Size(),scale,scale,INTER_AREA);
        corn_center = temp_img;
    }
    if (DISPLAY_ON)
    {
        //imshow(FIG3, img_rot);
        //imshow("corn center", corn_center);
    }

    int N = max(512, getOptimalDFTSize(corn_center.cols));
    int max_col_sub_count = (int) round(MAX_COL_COUNT / (CV_PI / CENTER_THETA_MAX));
    double phase;
    Mat phase_vec;
    double col_sub_count = get_count(corn_center, N, 0, max_col_sub_count, &phase, &phase_vec);
    col_count = col_sub_count * (CV_PI / CENTER_THETA_MAX) + COL_COUNT_SHIFT;
//    double shift = normalize_angle<double>(phase,0)/(2.0*CV_PI);
    Mat marked_img;
    cvtColor(corn_center,marked_img,COLOR_GRAY2BGR);
    double width = corn_center.cols/col_sub_count;
    for (int i=-1;i<(int)floor(col_sub_count)+2;i++)
    {
/*
        int line_x = (int)round((i - shift)*width);
        float * phase_vec_ptr = phase_vec.ptr(0);
        if (line_x >= 0 && line_x < corn_center.cols)
        {
            line(marked_img,cv::Point(line_x,0),cv::Point(line_x,corn_center.rows-1),Scalar(0,0,255),1,4);
        }
*/
        double line_x = i*width;
        float * phase_vec_ptr = phase_vec.ptr<float>(0);
        for (int j=1;j<phase_vec.rows*phase_vec.cols;j++)
        {
            double shift1 = phase_vec_ptr[j-1]/(2.0*CV_PI)*width;
            double shift2 = phase_vec_ptr[j]/(2.0*CV_PI)*width;
            line(marked_img,cv::Point((int)round(line_x - shift1),(j-1)),cv::Point((int)round(line_x - shift2),j),Scalar(0,0,255),1,8);
        }
    }

    int sub_rows = (corn_center.rows + SPLIT_COUNT - 1) / SPLIT_COUNT;
    row_count = ROW_COUNT_SHIFT;
    int max_row_sub_count = MAX_ROW_COUNT / SPLIT_COUNT;
    int min_row_sub_count = 0;
    for (int i2 = 0; i2 < SPLIT_COUNT; i2++)
    {
        int i = (i2 + SPLIT_COUNT / 2) % SPLIT_COUNT;
        int start_row = i * sub_rows;
        int stop_row = std::min((i + 1) * sub_rows - 1, corn_center.rows - 1);
        Mat sub_img = corn_center.rowRange(start_row, stop_row).t();
        N = max(512, getOptimalDFTSize(sub_img.cols));
        double sub_count = get_count(sub_img, N, min_row_sub_count, max_row_sub_count, &phase, &phase_vec);
        row_count += sub_count;
        if (i2 == 0)
        {
            min_row_sub_count = (int) round(0.5 * sub_count);
        }
        double shift = normalize_angle<double>(phase,0)/(2.0*CV_PI);
        width = sub_img.cols / sub_count;
        for (int i = -1; i < (int) floor(sub_count) + 2; i++)
        {
            int line_y = (int) round((i - shift) * width + start_row);
            if (line_y >= start_row && line_y <= stop_row)
            {
                line(marked_img, cv::Point(0, line_y), cv::Point(corn_center.cols - 1, line_y), Scalar(0, 0, 255), 1, 4);
            }
/*
            double line_y = i*width + start_row;
            if (line_y >= start_row && line_y <= stop_row)
            {
                float * phase_vec_ptr = phase_vec.ptr<float>(0);
                for (int j = 1; j < phase_vec.rows * phase_vec.cols; j++)
                {
                    double shift1 = phase_vec_ptr[j - 1] / (2.0 * CV_PI) * width;
                    double shift2 = phase_vec_ptr[j] / (2.0 * CV_PI) * width;
                    line(marked_img, cv::Point((j - 1), (int) round(line_y - shift1)),
                            cv::Point(j, (int) round(line_y - shift2)), Scalar(0, 0, 255), 1, 8);
                }
            }
*/
        }

    }
    if (DISPLAY_ON)
    {
        //namedWindow("marked corn center", MY_WINDOW_TYPE);
        //imshow("marked corn center", marked_img);
    }

    col_count_int = 2 * (int) round(0.5 * col_count);
    row_count_int = (int) round(row_count);
    int kernel_count = col_count_int * row_count_int;

    int stop_tick = (int)getTickCount();

    //std::cout << "col_count = " << col_count << " (" << col_count_int << ")" << std::endl;
    //std::cout << "row_count = " << row_count << " (" << row_count_int << ")" << std::endl;
    //std::cout << "kernel_count = " << kernel_count << std::endl;
    //std::cout << "elapsed_time = " << (stop_tick - start_tick) / getTickFrequency() << "s" << std::endl;

    if (DISPLAY_ON)
    {
        //waitKey(0);
    }
}

/*
int main(void)
{
    std::ifstream input_list(filelist.c_str(), std::ifstream::in);
    int lastindex = filelist.find_last_of(".");
    std::string new_filename = filelist.substr(0, lastindex) + "_output.txt";
    std::ofstream output_list(new_filename.c_str(), std::ofstream::out);

    char str_ptr[1024];
    input_list.getline(str_ptr, 1024);
    while(input_list.good())
    {
        double col_count, row_count;
        int col_count_int, row_count_int;
        std::string filename(str_ptr);
        single_corn(filename, col_count, col_count_int, row_count, row_count_int);
        input_list.getline(str_ptr, 1024);
        output_list << filename << ", " << col_count << ", " << col_count_int << ", " << row_count << ", " << row_count_int << std::endl;
    }
    input_list.close();
    output_list.close();
}
 */

