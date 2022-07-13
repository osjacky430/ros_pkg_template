include_guard()

function (config_debug_output)
  # we use directory property since we normally want ALL our diagnostic errors of the targets to be colored
  add_compile_options($<$<CXX_COMPILER_ID:GNU>:-fdiagnostics-color=always>)
  add_compile_options($<$<AND:$<CXX_COMPILER_ID:MSVC>,$<VERSION_GREATER:$<CXX_COMPILER_VERSION>,1900>>:/diagnostics:column>)

  if (CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    add_compile_options(-fcolor-diagnostics)
  endif ()
endfunction ()

macro (configure_project_setting)
  # Add build type Coverage
  set(CMAKE_C_FLAGS_COVERAGE "-g -O0" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_COVERAGE "-g -O0" CACHE STRING "")

  get_property(BUILDING_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if (BUILDING_MULTI_CONFIG)
    # Make sure that all supported configuration types have their
    # associated conan packages available. You can reduce this
    # list to only the configuration types you use, but only if one
    # is not forced-set on the command line for VS

    if (NOT "Coverage" IN_LIST CMAKE_CONFIGURATION_TYPES)
      list(APPEND CMAKE_CONFIGURATION_TYPES Coverage)
    endif ()

    if (CMAKE_BUILD_TYPE AND NOT ${CMAKE_BUILD_TYPE} IN_LIST CMAKE_CONFIGURATION_TYPES)
      list(APPEND CMAKE_CONFIGURATION_TYPES ${CMAKE_BUILD_TYPE})
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
    endif ()
  endif ()

  # Generate compile_commands.json to make it easier to work with clang based tools
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

  config_debug_output()
endmacro ()
