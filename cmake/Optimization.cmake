include_guard()

option(ENABLE_IPO "Enable Interprocedural Optimization (IPO), a.k.a Link Time Optimizaition (LTO)" OFF)

function (configure_interprocedural_optimization)
  if (POLICY CMP0069)
    cmake_policy(SET CMP0069 NEW)
  endif ()

  include(CheckIPOSupported)
  check_ipo_supported(RESULT result OUTPUT output LANGUAGES CXX)
  if (result)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON PARENT_SCOPE)
  else ()
    message(WARNING "Interprocedural Optimization is not supported. Reason: ${output}")
  endif ()
endfunction ()
