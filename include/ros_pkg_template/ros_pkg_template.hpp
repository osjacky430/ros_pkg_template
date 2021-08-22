#ifndef ROS_PKG_TEMPLATE_HPP_
#define ROS_PKG_TEMPLATE_HPP_

#include <limits>
#include <stdexcept>

namespace ros_pkg_template {

/**
 * @brief Buggy factorial, probably
 *
 * @param t_num Input number
 * @return result of factorial
 */
inline auto factorial(int const t_num) {
  if (t_num == 0 or t_num == 1) {
    return 1;
  }

  if (t_num < 0) {
    throw std::invalid_argument("Factorial of the negative number is not defined for this use case");
  }

  return t_num * factorial(t_num - 1);
}

}  // namespace ros_pkg_template

#endif