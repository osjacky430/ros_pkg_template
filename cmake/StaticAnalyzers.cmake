include_guard()

option(ENABLE_CLANG_TIDY "Enable static analysis with clang-tidy" OFF)
option(ENABLE_INCLUDE_WHAT_YOU_USE "Enable static analysis with include-what-you-use" OFF)
option(ENABLE_CPP_CHECK "Enable static analysis with cppcheck" OFF)
option(ENABLE_VS_ANALYSIS "Enable static analysis with visual studio IDE" OFF)

include(Utility)
include(CppCheck)
include(ClangTidy)

function (configure_iwyu)
  find_program(INCLUDE_WHAT_YOU_USE include-what-you-use)
  if (INCLUDE_WHAT_YOU_USE)
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE} -Wno-unknown-warning-option CACHE STRING "Command for iwyu analyzer" FORCE)
  else ()
    message(WARNING "include-what-you-use requested but executable not found")
  endif ()
endfunction ()

# need more information
function (configure_vs_analysis)
  cmake_parse_arguments("" "" "" "RULE_SETS" ${ARGN})
  get_all_targets(targets)
  # todo: modify cmake_format file so that it can parse this correctly
  foreach (target IN LISTS ${_targets_list})
    set_target_properties(
      ${target}
      PROPERTIES
        VS_GLOBAL_EnableMicrosoftCodeAnalysis true #
        VS_GLOBAL_CodeAnalysisRuleSet "$<IF:$<BOOL:${_RULE_SETS}>,${_RULE_SETS},\"AllRules.ruleset\">" #
        VS_GLOBAL_EnableClangTidyCodeAnalysis "$<IF:$<BOOL:${CMAKE_CXX_CLANG_TIDY}>,true,false>"
        # TODO(disabled) This is set to false deliberately. The compiler warnings are already given in the CompilerWarnings.cmake file
        # VS_GLOBAL_RunCodeAnalysis false
    )
  endforeach ()
endfunction ()
