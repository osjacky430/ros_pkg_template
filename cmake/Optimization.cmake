include_guard()

option(ENABLE_IPO "Enable Interprocedural Optimization (IPO), a.k.a Link Time Optimizaition (LTO)" OFF)

function (configure_interprocedural_optimization)
  if (NOT ${ENABLE_IPO})
    return()
  endif ()

  if (POLICY CMP0069)
    cmake_policy(SET CMP0069 NEW)
  endif ()

  cmake_parse_arguments("" "" "TARGET" "" ${ARGN})
  if (${IPO_IS_REASONABLE})
    include(CheckIPOSupported)
    check_ipo_supported(RESULT result OUTPUT output LANGUAGES CXX)
    if (result)
      # TODO set this option in `package_project` function.
      message(STATUS "CMAKE_INTERPROCEDURAL_OPTIMIZATION is set to ON, consider setting"
                     " it for other projects that link to IPO-enabled static library")
      set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON PARENT_SCOPE)
      set_target_properties(${_TARGET} PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)
    else ()
      message(WARNING "Interprocedural Optimization is not supported. Reason: ${output}")
    endif ()
  endif ()
endfunction ()
