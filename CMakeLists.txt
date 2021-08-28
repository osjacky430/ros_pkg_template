cmake_minimum_required(VERSION 3.5.1) # default cmake version for ubuntu 16.04
project(ros_pkg_template VERSION 0.1.0 LANGUAGES CXX) # DESCRIPTION is only valid after 3.9

# change this to your desire standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(catkin REQUIRED COMPONENTS roscpp message_generation geometry_msgs dynamic_reconfigure)

add_library(catkin_pkg INTERFACE)
target_include_directories(catkin_pkg SYSTEM INTERFACE ${catkin_INCLUDE_DIRS} ${CATKIN_DEVEL_PREFIX}/${CATKIN_GLOBAL_INCLUDE_DESTINATION})
target_include_directories(catkin_pkg INTERFACE ${PROJECT_SOURCE_DIR}/include)
target_link_libraries(catkin_pkg INTERFACE ${catkin_LIBRARIES})

find_package(Boost REQUIRED COMPONENTS program_options)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
include(StaticAnalyzers)
include(StandardProjectSetting)
include(CCache)

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

include(CompilerWarning)
add_library(compiler_warning INTERFACE)
set_project_warnings(compiler_warning)

include(Sanitizers)
add_library(project_option INTERFACE)
enable_sanitizers(project_option)

include(CatkinExtension)

add_subdirectory(src)
add_subdirectory(test)

if (ENABLE_COVERAGE)
  catkin_add_gcov_report(REPORT_NAME ${COVERAGE_REPORT_NAME} GCOV_EXCLUDE ".*test.*"
                         EXTRA_OPTIONS --xml-pretty --exclude-unreachable-branches --exclude-throw-branches)
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
