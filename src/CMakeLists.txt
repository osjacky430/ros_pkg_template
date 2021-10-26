# change to your own target name
add_executable(${PROJECT_NAME}_node main.cpp)

# to get rid of those "include_directories", remove this line if you don't care
# compiler warning about headers that are NOT created by you.
set_target_properties(${PROJECT_NAME}_node PROPERTIES INCLUDE_DIRECTORIES "")
target_link_libraries(${PROJECT_NAME}_node PRIVATE catkin_pkg Boost::program_options compiler_warning
                                                   $<$<BOOL:ENABLE_COVERAGE>:project_option>)
add_dependencies(${PROJECT_NAME}_node ${PROJECT_NAME}_generate_messages_cpp)
