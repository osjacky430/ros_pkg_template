#include <gtest/gtest.h>
#include <ros/ros.h>

int main(int argc, char** argv) {
  ros::init(argc, argv, "ros_pkg_template_rostest");
  ros::NodeHandle nh("ros_pkg_template_rostest");

  ros::AsyncSpinner spinner_{0};
  ::testing::InitGoogleTest(&argc, argv);

  spinner_.start();
  return RUN_ALL_TESTS();
}