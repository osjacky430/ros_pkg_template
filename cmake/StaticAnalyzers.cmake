option(ENABLE_CLANG_TIDY "Enable static analysis with clang-tidy" OFF)
option(ENABLE_INCLUDE_WHAT_YOU_USE "Enable static analysis with include-what-you-use" OFF)
option(ENABLE_CPP_CHECK "Enable static analysis with cppcheck" OFF)
option(ENABLE_VS_ANALYSIS "Enable static analysis with visual studio IDE" OFF)

include(CppCheck)
include(ClangTidy)

function (configure_iwyu)
  find_program(INCLUDE_WHAT_YOU_USE include-what-you-use)
  if (INCLUDE_WHAT_YOU_USE)
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE} -Wno-unknown-warning-option PARENT_SCOPE)
  else ()
    message(WARNING "include-what-you-use requested but executable not found")
  endif ()
endfunction ()

# need more information
function (configure_vs_analysis)
  set(singleValueArgs TARGET)
  set(multiValueArgs RULE_SETS)
  cmake_parse_arguments("" "" "" "${multiValueArgs}" "${ARGV}")

  if (CMAKE_GENERATOR MATCHES "Visual Studio")

  endif ()
endfunction ()

macro (configure_static_analyzer)
  if (ENABLE_INCLUDE_WHAT_YOU_USE)
    configure_iwyu()
  endif ()

  if (ENABLE_CLANG_TIDY)
    configure_clang_tidy()
  endif ()

  if (ENABLE_CPP_CHECK)
    configure_cppcheck()
  endif ()
endmacro ()
