include_guard()

function (configure_cppcheck)
  set(multiValueArgs SUPPRESS EXTRA_OPTIONS)
  cmake_parse_arguments("" "" "" "${multiValueArgs}" ${ARGN})

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

    foreach (suppress IN LISTS _SUPPRESS)
      list(APPEND CPPCHECK_SUPPRESS --suppress=${suppress})
    endforeach ()

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
        ${CPPCHECK_TEMPLATE}
        ${CPPCHECK_SUPPRESS}
        ${_EXTRA_OPTIONS}
        PARENT_SCOPE)
  else ()
    message(WARNING "cppcheck requested but executable not found")
  endif ()
endfunction ()
