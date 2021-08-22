# change to your own target name
add_executable(roscpp_pkg_template_node main.cpp)
target_link_libraries(roscpp_pkg_template_node PRIVATE catkin_pkg Boost::program_options compiler_warning
                                                       $<$<BOOL:ENABLE_COVERAGE>:project_option>)

add_dependencies(roscpp_pkg_template_node ${PROJECT_NAME}_generate_messages_cpp)
