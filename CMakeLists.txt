cmake_minimum_required(VERSION 3.5.1) # default cmake version for ubuntu 16.04
project(ros_pkg_template VERSION 0.1.0 LANGUAGES CXX) # DESCRIPTION is only valid after 3.9

# change this to your desire standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (MSVC AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.29)
  # This is a temporary solution to suppress warnings from 3rd party library in MSVC
  # see https://gitlab.kitware.com/cmake/cmake/-/issues/17904, this will probably be fixed in 3.24
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /external:W0")
  set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "/external:I ")
endif ()

find_package(catkin REQUIRED COMPONENTS roscpp message_generation geometry_msgs dynamic_reconfigure)

if (WIN32)
  # This workspace did not take precedence over ros root workspace, which results in wrong googletest dll being loaded.
  # And since I can't find a clean way to manipulate googletest build process (unless I embedded it into my project?),
  # it is impossible for me to determine where those artifacts will be after they were built.
  catkin_add_env_hooks(set_path SHELLS bat DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tool/env-hook)
endif ()

add_library(catkin_pkg INTERFACE)
target_include_directories(catkin_pkg SYSTEM INTERFACE ${catkin_INCLUDE_DIRS} ${CATKIN_DEVEL_PREFIX}/${CATKIN_GLOBAL_INCLUDE_DESTINATION})
target_include_directories(catkin_pkg INTERFACE ${PROJECT_SOURCE_DIR}/include)
target_link_libraries(catkin_pkg INTERFACE ${catkin_LIBRARIES})

find_package(Boost REQUIRED COMPONENTS program_options)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
include(StaticAnalyzers)
include(StandardProjectSetting)
include(CompilerCache)
include(Linker)
include(Sanitizers)
include(CompilerWarning)
include(Coverage)

add_library(compiler_warning INTERFACE)
set_project_warnings(TARGET compiler_warning)

add_library(project_option INTERFACE)
enable_sanitizers(TARGET project_option)

configure_project_setting()
configure_static_analyzer()
configure_compiler_cache()
configure_linker(TARGET project_option LINKER mold LINKER_PATH /usr/local/libexec/mold)

## Generate messages in the 'msg' folder
add_message_files(FILES example.msg)

## Generate services in the 'srv' folder
add_service_files(FILES Factorial.srv)

## Generate actions in the 'action' folder
# add_action_files(
#   FILES
#   Action1.action
#   Action2.action
# )

## Generate added messages and services with any dependencies listed here
generate_messages(DEPENDENCIES geometry_msgs)

################################################
## Declare ROS dynamic reconfigure parameters ##
################################################

## To declare and build dynamic reconfigure parameters within this
## package, follow these steps:
## * In the file package.xml:
##   * add a build_depend and a exec_depend tag for "dynamic_reconfigure"
## * In this file (CMakeLists.txt):
##   * add "dynamic_reconfigure" to
##     find_package(catkin REQUIRED COMPONENTS ...)
##   * uncomment the "generate_dynamic_reconfigure_options" section below
##     and list every .cfg file to be processed

## Generate dynamic reconfigure parameters in the 'cfg' folder
generate_dynamic_reconfigure_options(cfg/RosPkgTemplateExample.cfg)

###################################
## catkin specific configuration ##
###################################
## The catkin_package macro generates cmake config files for your package
## Declare things to be passed to dependent projects
## INCLUDE_DIRS: uncomment this if your package contains header files
## LIBRARIES: libraries you create in this project that dependent projects also need
## CATKIN_DEPENDS: catkin_packages dependent projects also need
## DEPENDS: system dependencies of this project that dependent projects also need
catkin_package(
  #  INCLUDE_DIRS include
  #  LIBRARIES ros_pkg_template
  #  CATKIN_DEPENDS roscpp
  #  DEPENDS system_lib
)

add_subdirectory(src)
add_subdirectory(test)

if (GENERATE_COVERAGE_REPORT)
  # I can't imagine a case where user specified CMAKE_BUILD_TYPE=Coverage but doesn't want to generate coverage report.
  # yet there is no recommended way to check if current build type is coverage or not.
  catkin_add_gcov_report(REPORT_NAME ${COVERAGE_REPORT_NAME} GCOV_EXCLUDE ".*test.*" ".*src.*" HTML_DETAILS
                         EXTRA_OPTIONS --exclude-unreachable-branches --exclude-throw-branches)
endif ()

#############
## Install ##
#############

# all install targets should use catkin DESTINATION variables
# See http://ros.org/doc/api/catkin/html/adv_user_guide/variables.html

## Mark executable scripts (Python etc.) for installation
## in contrast to setup.py, you can choose the destination
# catkin_install_python(PROGRAMS
#   scripts/my_python_script
#   DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
# )

## Mark executables for installation
## See http://docs.ros.org/melodic/api/catkin/html/howto/format1/building_executables.html
# install(TARGETS ${PROJECT_NAME}_node
#   RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
# )

## Mark libraries for installation
## See http://docs.ros.org/melodic/api/catkin/html/howto/format1/building_libraries.html
# install(TARGETS ${PROJECT_NAME}
#   ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
#   LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
#   RUNTIME DESTINATION ${CATKIN_GLOBAL_BIN_DESTINATION}
# )

## Mark cpp header files for installation
# install(DIRECTORY include/${PROJECT_NAME}/
#   DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
#   FILES_MATCHING PATTERN "*.h"
#   PATTERN ".svn" EXCLUDE
# )

## Mark other files for installation (e.g. launch and bag files, etc.)
# install(FILES
#   # myfile1
#   # myfile2
#   DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
# )
