function (config_debug_output)
  # we use directory property since we normally want ALL our diagnostic errors of the targets to be colored
  add_compile_options($<$<CXX_COMPILER_ID:GNU>:-fdiagnostics-color=always>)
  add_compile_options($<$<AND:$<CXX_COMPILER_ID:MSVC>,$<VERSION_GREATER:$<CXX_COMPILER_VERSION>,1900>>:/diagnostics:column>)

  if (CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    add_compile_options(-fcolor-diagnostics)
  endif ()
endfunction ()

macro (configure_project_setting)
  if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    # todo: consider create a custom build type for code coverage, check compiler instrumentation flag

    # Since the recommended optimization flags differ between sanitizers, e.g. ASAN is recommended to build with -O1,
    # but UBSAN should be built with -O0, otherwise undefined behaviors can be optimized away. I don't think we should
    # set a build type for sanitizing
    message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the type of build." FORCE)

    # Set the possible values of build type for cmake-gui, ccmake
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
  endif ()

  # Generate compile_commands.json to make it easier to work with clang based tools
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

  get_property(BUILDING_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if (BUILDING_MULTI_CONFIG)
    if (NOT CMAKE_BUILD_TYPE)
      # Make sure that all supported configuration types have their
      # associated conan packages available. You can reduce this
      # list to only the configuration types you use, but only if one
      # is not forced-set on the command line for VS
      message(TRACE "Setting up multi-config build types")
      set(CMAKE_CONFIGURATION_TYPES Debug Release RelWithDebInfo MinSizeRel CACHE STRING "Enabled build types" FORCE)
    else ()
      message(TRACE "User chose a specific build type, so we are using that")
      set(CMAKE_CONFIGURATION_TYPES ${CMAKE_BUILD_TYPE} CACHE STRING "Enabled build types" FORCE)
    endif ()
  endif ()

  config_debug_output()
endmacro ()
