#include "ros_pkg_template/ros_pkg_template.hpp"

#include <boost/program_options.hpp>

#include <dynamic_reconfigure/server.h>
#include <geometry_msgs/Twist.h>
#include <ros/ros.h>
#include <ros_pkg_template/Factorial.h>
#include <ros_pkg_template/RosPkgTemplateExampleConfig.h>
#include <ros_pkg_template/example.h>

#include <atomic>
#include <iostream>
#include <memory>
#include <string>

namespace po = boost::program_options;

// cppcheck-suppress constParameter
bool factorial_service(ros_pkg_template::FactorialRequest& t_req, ros_pkg_template::FactorialResponse& t_resp) {
  try {
    t_resp.result = ros_pkg_template::factorial(t_req.number);
  } catch (std::exception& t_e) {
    std::cerr << "Encounter error: " << t_e.what() << '\n';
    return false;
  }

  return true;
}

int main(int argc, char** argv) {
  using namespace std::string_literals;

  ros::init(argc, argv, "ros_pkg_template"s);
  ros::NodeHandle nh{"ros_pkg_template"s};

  bool publish = false;
  bool service = false;
  po::options_description desc;
  desc.add_options()                                                   //
    ("help", "Show this help message and exit")                        //
    ("publish", po::bool_switch(&publish), "publish example message")  //
    ("service", po::bool_switch(&service), "advertise example service");

  po::variables_map vm;
  po::store(po::command_line_parser(argc, argv).options(desc).run(), vm);
  po::notify(vm);

  if (vm.count("help"s) != 0U) {
    std::cout << desc << '\n';
    return EXIT_SUCCESS;
  }

  constexpr double DEFAULT_X_VALUE = 1.0;
  constexpr double DEFAULT_Z_VALUE = 0.5;
  std::atomic<double> x_value{DEFAULT_X_VALUE};
  std::atomic<double> z_value{DEFAULT_Z_VALUE};

  using ExampleConfigure       = ros_pkg_template::RosPkgTemplateExampleConfig;
  using ExampleConfigureServer = dynamic_reconfigure::Server<ExampleConfigure>;

  auto dsrv_{std::make_unique<ExampleConfigureServer>(nh)};
  if (publish) {
    dsrv_->setCallback([&x_value, &z_value](ExampleConfigure& t_cfg, std::uint32_t /**/) {
      if (not std::isnan(t_cfg.x_velocity)) {
        x_value = t_cfg.x_velocity;
        std::cout << "x_velocity: " << t_cfg.x_velocity << '\n';
      } else {
        t_cfg.x_velocity = x_value;
        std::cerr << "Bad x velocity\n";
      }

      if (not std::isnan(t_cfg.z_velocity)) {
        z_value = t_cfg.z_velocity;
        std::cout << "z_velocity: " << t_cfg.z_velocity << '\n';
      } else {
        t_cfg.z_velocity = z_value;
        std::cerr << "Bad z velocity\n";
      }
    });
  }

  auto pub = publish ? nh.advertise<ros_pkg_template::example>("example_pub"s, 1) : ros::Publisher{};
  auto ser = service ? nh.advertiseService("factorial_service"s, &factorial_service) : ros::ServiceServer{};

  constexpr double LOOP_FREQUENCY = 20.0;
  for (ros::Rate loop_rate{LOOP_FREQUENCY}; ros::ok(); ros::spinOnce(), loop_rate.sleep()) {
    if (publish) {
      ros_pkg_template::example msg;
      msg.speed.angular.z = z_value;
      msg.speed.linear.x  = x_value;
      pub.publish(msg);
    }
  }

  return EXIT_SUCCESS;
}