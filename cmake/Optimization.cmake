function (enable_interprocedural_optimization)
  if (${CMAKE_VERSION} VERSION_LESS "3.18.0")
    message(WARNING "Consider upgrading CMake to the latest version.
      CMake ${CMAKE_VERSION} does not support ENABLE_INTERPROCEDURAL_OPTIMIZATION.")
    return()
  endif ()

  cmake_parse_arguments("" "" "TARGET" "" "${ARGV}")
  if (CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    include(CheckIPOSupported)
    check_ipo_supported(RESULT result OUTPUT output)
    if (result)
      # TODO set this option in `package_project` function.
      message(STATUS "Consider setting `CMAKE_INTERPROCEDURAL_OPTIMIZATION` to ON
        for other projects that link to IPO-enabled static library")
      set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON PARENT_SCOPE)
      set_target_properties(${_TARGET} PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)
    else ()
      message(WARNING "Interprocedural Optimization is not supported. Reason: ${output}")
    endif ()
  endif ()
endfunction ()
