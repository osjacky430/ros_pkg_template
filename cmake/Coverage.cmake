include_guard()

include(Utility)
include(Gcov)

function (configure_coverage)
  cmake_parse_arguments("" "" "TARGET" "" ${ARGN})

  if (NOT _TARGET)
    message(FATAL_ERROR "No target specified")
  endif ()

  set(match_clang_or_gcc $<OR:${MATCH_CLANG_COMPILER_ID_GENEX},$<CXX_COMPILER_ID:GNU>>)
  target_compile_options(${_TARGET} PRIVATE $<$<AND:$<CONFIG:Coverage>,${match_clang_or_gcc}>:--coverage>)
  target_link_libraries(${_TARGET} PRIVATE $<$<AND:$<CONFIG:Coverage>,${match_clang_or_gcc}>:--coverage>)
endfunction ()
