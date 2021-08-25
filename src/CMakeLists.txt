# change to your own target name
add_executable(roscpp_pkg_template_node main.cpp)

# to get rid of those "include_directories", remove this line if you don't care
# compiler warning about headers that are NOT created by you.
set_target_properties(roscpp_pkg_template_node PROPERTIES INCLUDE_DIRECTORIES "")
target_link_libraries(roscpp_pkg_template_node PRIVATE catkin_pkg Boost::program_options compiler_warning
                                                       $<$<BOOL:ENABLE_COVERAGE>:project_option>)
add_dependencies(roscpp_pkg_template_node ${PROJECT_NAME}_generate_messages_cpp)
