include_guard()

function (configure_clang_tidy)
  cmake_parse_arguments("" "" "" "EXTRA_ARG;EXTRA_OPTIONS" ${ARGN})

  find_program(CLANG_TIDY clang-tidy)
  if (CLANG_TIDY)
    if (NOT "${CMAKE_CXX_STANDARD}" STREQUAL "")
      if ("${CMAKE_CXX_CLANG_TIDY_DRIVER_MODE}" STREQUAL "cl")
        set(CLANG_TIDY_STD_CPP --extra-arg=/std:c++${CMAKE_CXX_STANDARD})
      else ()
        set(CLANG_TIDY_STD_CPP --extra-arg=-std=c++${CMAKE_CXX_STANDARD})
      endif ()
    endif ()

    list(TRANSFORM _EXTRA_ARG PREPEND "--extra-arg=")
    set(CLANG_TIDY_EXRTA_ARGS "--extra-arg=-Wno-unknown-warning-option" "${_EXTRA_ARG}")

    set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY} ${CLANG_TIDY_STD_CPP} "${CLANG_TIDY_EXRTA_ARGS}" -p=${CMAKE_BINARY_DIR}
                             --config-file=${PROJECT_SOURCE_DIR}/.clang-tidy ${_EXTRA_OPTIONS}
        CACHE STRING "Command for clang-tidy analyzer" FORCE)
  else ()
    message(WARNING "clang-tidy requested but executable not found")
  endif ()
endfunction ()
