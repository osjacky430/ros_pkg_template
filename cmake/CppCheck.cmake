include_guard()

function (configure_cppcheck)
  cmake_parse_arguments("" "" "" "SUPPRESS;EXTRA_OPTIONS" ${ARGN})

  find_program(CPP_CHECK cppcheck)
  if (CPP_CHECK)
    if (NOT "${CMAKE_CXX_STANDARD}" STREQUAL "")
      set(CPPCHECK_STD_FLAG --std=c++${CMAKE_CXX_STANDARD})
    endif ()

    if (WARNINGS_AS_ERRORS)
      set(CPPCHECK_WERR --error-exitcode=2)
    endif ()

    # if (CMAKE_GENERATOR MATCHES ".*Visual Studio.*")
    #   set(CPPCHECK_TEMPLATE --template="vs")
    # else ()
    #   set(CPPCHECK_TEMPLATE --template="gcc")
    # endif ()

    list(TRANSFORM _SUPPRESS PREPEND "--suppress")
    set(CMAKE_CXX_CPPCHECK
        ${CPP_CHECK}
        --suppress=internalAstError
        --suppress=unmatchedSuppression
        --enable=style,performance,warning,portability
        --inconclusive
        --inline-suppr
        --project=${CMAKE_BINARY_DIR}/compile_commands.json
        ${CPPCHECK_WERR}
        ${CPPCHECK_STD_FLAG}
        ${_SUPPRESS}
        ${_EXTRA_OPTIONS}
        CACHE STRING "Command for cppcheck analyzer" FORCE)
  else ()
    message(WARNING "cppcheck requested but executable not found")
  endif ()
endfunction ()
