#include <gtest/gtest.h>

#include <dynamic_reconfigure/client.h>
#include <ros_pkg_template/RosPkgTemplateExampleConfig.h>

TEST(dynamic_reconfigure, invalid_velocity_wont_be_published) {
  dynamic_reconfigure::Client<ros_pkg_template::RosPkgTemplateExampleConfig> cfg_client{"/ros_pkg_template"};

  ros_pkg_template::RosPkgTemplateExampleConfig cfg;
  cfg_client.getCurrentConfiguration(cfg);

  auto const original_x = cfg.x_velocity;
  cfg.x_velocity        = std::numeric_limits<double>::quiet_NaN();
  cfg_client.setConfiguration(cfg);
  EXPECT_EQ(cfg.x_velocity, original_x);

  auto const original_z = cfg.z_velocity;
  cfg.z_velocity        = std::numeric_limits<double>::quiet_NaN();
  cfg_client.setConfiguration(cfg);
  EXPECT_EQ(cfg.z_velocity, original_z);
}