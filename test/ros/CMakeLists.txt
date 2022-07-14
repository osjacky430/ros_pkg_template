find_package(rostest REQUIRED)

add_library(${PROJECT_NAME}_main_rostest test_main.cpp)
target_link_libraries(${PROJECT_NAME}_main_rostest PUBLIC catkin_pkg project_option gtest project_warning)

add_rostest(ros_pkg_template_test.test)
add_executable(${PROJECT_NAME}_rostest ros_pkg_template_rostest.cpp)
target_link_libraries(${PROJECT_NAME}_rostest PRIVATE ${PROJECT_NAME}_main_rostest)
