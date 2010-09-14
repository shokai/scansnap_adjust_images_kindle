#include "cv.h"
#include "highgui.h"
#include <boost/program_options.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/fstream.hpp>
#include <iostream>
using namespace boost;
using namespace std;
namespace fs = boost::filesystem;

IplImage *adjust_image(IplImage *img, program_options::variables_map argmap){
  const int w = img->width;
  const int h = img->height;
  IplImage *img_gray = cvCreateImage(cvSize(w,h), IPL_DEPTH_8U, 1);
  cvCvtColor(img, img_gray, CV_BGR2GRAY);

  // 2値化
  IplImage *img_bin = cvCreateImage(cvSize(w,h), IPL_DEPTH_8U, 1);
  cvThreshold(img_gray, img_bin, argmap["threshold"].as<int>(), 255, CV_THRESH_BINARY);

  // 文字を太らせる
  cvErode(img_bin, img_bin, NULL, 1);

  // リサイズ
  int width = argmap["width"].as<int>();
  int height = argmap["height"].as<int>();
  IplImage *img_resized;
  double scale = ((double)h)/w;
  if(((double)height)/width < scale){ // 縦長
    img_resized = cvCreateImage(cvSize((int)(height/scale), height), IPL_DEPTH_8U, 1);
  }
  else{ // 横長
    img_resized = cvCreateImage(cvSize(width, (int)(scale*width)), IPL_DEPTH_8U, 1);
  }
  cvResize(img_bin, img_resized, CV_INTER_LINEAR);
  
  //IplImage *img_frame = cvCreateImage(cvSize(WIDTH, HEIGHT), IPL_DEPTH_8U, 1);
  
  return img_resized;
}

int main(int argc, char* argv[]) {
  program_options::options_description opts("options");
  opts.add_options()
    ("help", "ヘルプを表示")
    ("width,w", program_options::value<int>(), "output width")
    ("height,h", program_options::value<int>(), "output height")
    ("threshold,t", program_options::value<int>(), "binarize threshold")
    ("input,i", program_options::value<string>(), "input directory name")
    ("output,o", program_options::value<string>(), "output directory name")
    ("cleft,cl", program_options::value<int>(), "crop left (pixel)")
    ("cright,cr", program_options::value<int>(), "crop right (pixel)")
    ("ctop,ct", program_options::value<int>(), "crop top (pixel)")
    ("cbottom,cb", program_options::value<int>(), "crop bottom (pixel)");
  program_options::variables_map argmap;
  program_options::store(parse_command_line(argc, argv, opts), argmap);
  program_options::notify(argmap);
  if (argmap.count("help") || !argmap.count("input") || !argmap.count("output") ||
      !argmap.count("threshold")) {
    cerr << "[input, output] required" << endl;
    cerr << opts << endl;
    return 1;
  }

  string in_dir = argmap["input"].as<string>();
  fs::path path = complete(fs::path(in_dir, fs::native));
  fs::directory_iterator end;
  for (fs::directory_iterator i(path); i!=end; i++){
    string img_fullname = in_dir + i->leaf();
    cout << img_fullname << endl;
    IplImage *img, *img_result;
    img = cvLoadImage(img_fullname.c_str());
    if(!img){
      cerr << "image file load error" << endl;
    }
    else{
      img_result = adjust_image(img, argmap);
      string out_filename = argmap["output"].as<string>() + "/" + i->leaf();
      cvSaveImage(out_filename.c_str(), img_result);
      cvReleaseImage(&img);
      cvReleaseImage(&img_result);
    }    
  }
}
