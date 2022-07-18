include_guard()

include(StaticAnalyzers)
include(StandardProjectSetting)
include(CompilerCache)
include(Linker)
include(Sanitizers)
include(Optimization)
include(CompilerWarning)
include(Coverage)

function (configure_ros_project_option)
  cmake_parse_arguments("" "" "TARGET" "" ${ARGN})

  target_include_directories(${_TARGET} SYSTEM INTERFACE ${catkin_INCLUDE_DIRS} ${CATKIN_DEVEL_PREFIX}/${CATKIN_GLOBAL_INCLUDE_DESTINATION})
  target_include_directories(${_TARGET} INTERFACE ${PROJECT_SOURCE_DIR}/include)
  target_link_libraries(${_TARGET} INTERFACE ${catkin_LIBRARIES})

  target_compile_options(
    ${_TARGET}
    # This is a temporary solution to suppress warnings from 3rd party library in MSVC
    # see https://gitlab.kitware.com/cmake/cmake/-/issues/17904, this will probably be fixed in 3.24
    INTERFACE $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<NOT:$<VERSION_LESS:$<CXX_COMPILER_VERSION>,19.14>>>:/external:W0 /external:anglebrackets>
              # vs 16.10 (19.29.30037) no longer need the /experimental:external flag to use the /external:*
              $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<VERSION_LESS:$<CXX_COMPILER_VERSION>,19.29.30037>>:/experimental:external>)
endfunction ()

function (configure_project_option)
  set(groups
      CATKIN_ROS
      WARNINGS
      CPP_CHECK
      CLANG_TIDY
      VS_ANALYSIS
      LINKER
      COMPILER_CACHE
      SANITIZER
      IPO)
  cmake_parse_arguments(GRP "" "" "${groups}" ${ARGN})

  cmake_parse_arguments(WARNING "" "TARGET;PROJECT_WARNINGS" "" "${GRP_WARNINGS}")
  cmake_parse_arguments(LINKER "" "TARGET;LINKER_NAME;LINKER_PATH" "" "${GRP_LINKER}")
  cmake_parse_arguments(CCACHE "" "CCACHE_BASE_DIR" "" "${GRP_COMPILER_CACHE}")
  cmake_parse_arguments(CPP_CHECK "" "" "SUPPRESS;EXTRA_OPTIONS" "${GRP_CPP_CHECK}")
  cmake_parse_arguments(CLANG_TIDY "" "" "EXTRA_ARG;EXTRA_OPTIONS" "${GRP_CLANG_TIDY}")
  cmake_parse_arguments(VS_ANALYSIS "" "" "RULE_SETS" "${GRP_VS_ANALYSIS}")
  cmake_parse_arguments(SANITIZER "" "TARGET" "" "${GRP_SANITIZER}")
  cmake_parse_arguments(IPO "" "" "DISABLE_FOR_CONFIG" "${GRP_IPO}")
  cmake_parse_arguments(CATKIN_ROS "" "TARGET" "" "${GRP_CATKIN_ROS}")

  foreach (target_name ${WARNING_TARGET} ${LINKER_TARGET} ${SANITIZER_TARGET} ${CATKIN_ROS_TARGET})
    if (NOT TARGET ${target_name})
      add_library(${target_name} INTERFACE)
      set_target_properties(${target_name} PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "")
    endif ()
  endforeach ()

  configure_project_setting()
  configure_compiler_cache(${CCACHE_CCACHE_BASE_DIR})
  configure_project_warnings(TARGET ${WARNING_TARGET} WARNINGS ${WARNING_PROJECT_WARNINGS})
  configure_linker(TARGET ${LINKER_TARGET} LINKER_NAME ${LINKER_LINKER_NAME} LINKER_PATH ${LINKER_LINKER_PATH})
  configure_sanitizers(TARGET ${SANITIZER_TARGET})
  configure_interprocedural_optimization(DISABLE_FOR_CONFIG ${IPO_DISABLE_FOR_CONFIG})

  if (${ENABLE_CPP_CHECK})
    configure_cppcheck(SUPPRESS ${CPP_CHECK_SUPPRESS} EXTRA_OPTIONS ${CPP_CHECK_EXTRA_OPTIONS})
  endif ()

  if (${ENABLE_CLANG_TIDY})
    configure_clang_tidy(EXTRA_ARG ${CLANG_TIDY_EXTRA_ARG} EXTRA_OPTIONS ${CLANG_TIDY_EXTRA_OPTIONS})
  endif ()

  if (${ENABLE_INCLUDE_WHAT_YOU_USE})
    configure_iwyu()
  endif ()

  if (CMAKE_GENERATOR MATCHES "Visual Studio" AND ${ENABLE_VS_ANALYSIS})
    configure_vs_analysis(RULE_SETS ${VS_ANALYSIS_RULE_SETS})
  endif ()

  configure_ros_project_option(TARGET ${CATKIN_ROS_TARGET})
endfunction ()
