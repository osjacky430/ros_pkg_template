include_guard()

function (enable_interprocedural_optimization)
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
