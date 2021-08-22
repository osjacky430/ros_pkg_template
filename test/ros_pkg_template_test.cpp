#include <gtest/gtest.h>

#include "ros_pkg_template/ros_pkg_template.hpp"

TEST(factorial, value_match) {
  EXPECT_EQ(ros_pkg_template::factorial(0), 1);
  EXPECT_EQ(ros_pkg_template::factorial(1), 1);
  EXPECT_EQ(ros_pkg_template::factorial(2), 2);
  EXPECT_EQ(ros_pkg_template::factorial(3), 6);
  EXPECT_EQ(ros_pkg_template::factorial(4), 24);
  EXPECT_EQ(ros_pkg_template::factorial(5), 120);
  EXPECT_EQ(ros_pkg_template::factorial(6), 720);
}

TEST(factorial, negative_value_will_throw) {
  EXPECT_THROW(ros_pkg_template::factorial(-1), std::invalid_argument);
  EXPECT_THROW(ros_pkg_template::factorial(std::numeric_limits<int>::min()), std::invalid_argument);
}
