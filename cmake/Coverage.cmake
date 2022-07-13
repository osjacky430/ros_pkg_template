include_guard()

include(Gcov)

function (configure_coverage)
  cmake_parse_arguments("" "" "TARGET" "" "${ARGV}")

  if (NOT _TARGET)
    message(FATAL_ERROR "No target specified")
  endif ()

  target_compile_options(${_TARGET} PRIVATE $<$<CONFIG:Coverage>:--coverage>)
  target_link_libraries(${_TARGET} PRIVATE $<$<CONFIG:Coverage>:--coverage>)
endfunction ()
