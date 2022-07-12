function (_configure_ccache)
  set(singleValueArgs BASE_DIR)
  cmake_parse_arguments("" "" "${singleValueArgs}" "" "${ARGV}")

  find_program(CCACHE_BINARY ccache)
  if (NOT _BASE_DIR)
    execute_process(COMMAND catkin locate OUTPUT_VARIABLE _BASE_DIR ERROR_VARIABLE CATKIN_ERR)
    string(REGEX REPLACE "\n" "" _BASE_DIR "${_BASE_DIR}")
  endif ()

  if (CATKIN_ERR)
    message(STATUS "Can't identify catkin workspace root directory, nor did user provide one, using default config")
  endif ()

  # see https://ccache.dev/manual/4.6.1.html base_dir
  if (CCACHE_BINARY)
    message(STATUS "ccache found and enabled")
    set(ccacheEnv
        CCACHE_CPP2=true CCACHE_BASEDIR=${_BASE_DIR}
        # This comes with a theoretical risk of a race condition, but for typical scenarios,
        # that race condition is highly unlikely
        CCACHE_SLOPINESS=include_file_ctime,include_file_mtime,time_macros)
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CMAKE_COMMAND} -E env ${ccacheEnv} ${CCACHE_BINARY} CACHE STRING "CXX compiler cache used")
    set(CMAKE_C_COMPILER_LAUNCHER ${CMAKE_COMMAND} -E env ${ccacheEnv} ${CCACHE_BINARY} CACHE STRING "C compiler cache used")
  else ()
    message(WARNING "ccache is enabled but was not found. Not using it")
  endif ()
endfunction ()

function (configure_compiler_cache)
  if (NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    message(FATAL_ERROR "configure_compiler_cache() is intended to be called at top level CMakeLists.txt")
    return()
  endif ()

  set(CACHE_OPTION "ccache" CACHE STRING "Compiler cache to be used")
  set(CACHE_OPTION_VALUES "ccache" "sccache")
  set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})

  list(FIND CACHE_OPTION_VALUES ${CACHE_OPTION} CACHE_OPTION_INDEX)
  if (NOT ${CACHE_OPTION_INDEX} EQUAL 0)
    if (${CACHE_OPTION_INDEX} EQUAL -1)
      message(STATUS "Using custom compiler cache system: '${CACHE_OPTION}', explicitly supported entries are ${CACHE_OPTION_VALUES}")
    endif ()

    find_program(CACHE_BINARY ${CACHE_OPTION})
    if (CACHE_BINARY)
      message(STATUS "${CACHE_OPTION} found and enabled")
      set(CMAKE_CXX_COMPILER_LAUNCHER ${CACHE_BINARY} CACHE STRING "CXX compiler cache used")
      set(CMAKE_C_COMPILER_LAUNCHER ${CACHE_BINARY} CACHE STRING "C compiler cache used")
    else ()
      message(WARNING "${CACHE_OPTION} is enabled but was not found. Not using it")
    endif ()
  else ()
    _configure_ccache(${ARGV})
  endif ()
endfunction ()
