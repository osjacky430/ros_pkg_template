cmake_minimum_required(VERSION 3.23.0 FATAL_ERROR)
project(ros_pkg_template VERSION 0.1.0 LANGUAGES CXX)

# change this to your desire standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
include(ProjectOption)

find_package(catkin REQUIRED COMPONENTS roscpp message_generation geometry_msgs dynamic_reconfigure)

# cmake-format: off
configure_project_option(
  WARNINGS
    TARGET project_warning
  LINKER
    TARGET project_option
    LINKER_NAME mold
    LINKER_PATH /usr/local/libexec/mold
  SANITIZER
    TARGET project_option
  IPO
    DISABLE_FOR_CONFIG Debug Coverage
  CLANG_TIDY
    EXTRA_ARG -DROSCONSOLE_MIN_SEVERITY=ROSCONSOLE_SEVERITY_NONE
  CATKIN_ROS
    TARGET catkin_pkg
  COMPILER_CACHE
    LAUNCHER ccache
)
# cmake-format: on

if (WIN32)
  # This workspace did not take precedence over ros root workspace, which results in wrong googletest dll being loaded.
  # And since I can't find a clean way to manipulate googletest build process (unless I embedded it into my project?),
  # it is impossible for me to determine where those artifacts will be after they were built.
  catkin_add_env_hooks(set_path SHELLS bat DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tool/env-hook)
endif ()

find_package(Boost REQUIRED COMPONENTS program_options)

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

if (COVERAGE_REPORT_NAME)
  catkin_add_gcov_report(REPORT_NAME ${COVERAGE_REPORT_NAME} HTML_DETAILS EXTRA_OPTIONS --exclude-unreachable-branches
                                                                                        --exclude-throw-branches)
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
