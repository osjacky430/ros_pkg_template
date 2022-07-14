add_subdirectory(ros)

catkin_add_gtest(${PROJECT_NAME}_test ros_pkg_template_test.cpp)
target_link_libraries(${PROJECT_NAME}_test catkin_pkg gtest_main project_option project_warning)
