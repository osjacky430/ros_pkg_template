include_guard()

include(Utility)

function (config_debug_output)
  # we use directory property since we normally want ALL our diagnostic errors of the targets to be colored
  add_compile_options($<$<AND:$<CXX_COMPILER_ID:GNU>,${MATCH_CLANG_COMPILER_ID_GENEX}>:-fdiagnostics-color=always>)
  add_compile_options($<$<AND:$<CXX_COMPILER_ID:MSVC>,$<VERSION_GREATER:$<CXX_COMPILER_VERSION>,1900>>:/diagnostics:column>)
endfunction ()

function (configure_project_setting)
  # Add build type Coverage (why CMAKE_CXX_FLAGS_DEBUG isn't -O0?!)
  if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    set(CMAKE_C_FLAGS_COVERAGE "-g -O0" CACHE STRING "")
    set(CMAKE_CXX_FLAGS_COVERAGE "-g -O0" CACHE STRING "")
  elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # set(CMAKE_C_FLAGS_COVERAGE "O0" CACHE STRING "")
    # set(CMAKE_CXX_FLAGS_COVERAGE "0" CACHE STRING "")

    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.29)
      # This is a temporary solution to suppress warnings from 3rd party library in MSVC
      # see https://gitlab.kitware.com/cmake/cmake/-/issues/17904, this will probably be fixed in 3.24
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /external:W0" PARENT_SCOPE)
      set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "/external:I " PARENT_SCOPE)
    endif ()
  endif ()

  # initialize project variables
  set(GENERATE_COVERAGE_REPORT OFF CACHE INTERNAL "Generate coverage report, this will be set according to build type")

  get_property(BUILDING_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if (BUILDING_MULTI_CONFIG)
    # Make sure that all supported configuration types have their
    # associated conan packages available. You can reduce this
    # list to only the configuration types you use, but only if one
    # is not forced-set on the command line for VS
    if (NOT "Coverage" IN_LIST CMAKE_CONFIGURATION_TYPES)
      set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES};Coverage" CACHE STRING "" FORCE)
    endif ()

    if (DEFINED CMAKE_BUILD_TYPE AND NOT CMAKE_BUILD_TYPE STREQUAL "")
      message(FATAL_ERROR "CMAKE_BUILD_TYPE='${CMAKE_BUILD_TYPE}' is defined and non-empty "
                          "(but should not be for a multi-configuration generator)")
    endif ()
  else ()
    # Since the recommended optimization flags differ between sanitizers, e.g. ASAN is recommended to build with -O1,
    # but UBSAN should be built with -O0, otherwise undefined behaviors can be optimized away. I don't think we should
    # set a build type for sanitizing
    set(AVAILABLE_BUILD_TYPE "Debug" "Release" "MinSizeRel" "RelWithDebInfo" "Coverage")

    # Set the possible values of build type for cmake-gui, ccmake
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${AVAILABLE_BUILD_TYPE})

    if (NOT CMAKE_BUILD_TYPE)
      message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")
      set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the type of build." FORCE)
    elseif (NOT CMAKE_BUILD_TYPE IN_LIST AVAILABLE_BUILD_TYPE)
      message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
    elseif (CMAKE_BUILD_TYPE STREQUAL "Coverage")
      set(GENERATE_COVERAGE_REPORT ON CACHE INTERNAL "Generate coverage report, this will be set according to build type")
    endif ()
  endif ()

  set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Generate compile_commands.json to make it easier to work with clang based tools")

  config_debug_output()
endfunction ()
