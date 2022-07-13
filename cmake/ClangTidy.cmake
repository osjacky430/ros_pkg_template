include_guard()

function (configure_clang_tidy)
  set(multiValueArgs EXTRA_ARG EXTRA_OPTIONS)
  cmake_parse_arguments("" "" "" "${multiValueArgs}" "${ARGV}")

  find_program(CLANG_TIDY clang-tidy)
  if (CLANG_TIDY)
    if (NOT "${CMAKE_CXX_STANDARD}" STREQUAL "")
      if ("${CMAKE_CXX_CLANG_TIDY_DRIVER_MODE}" STREQUAL "cl")
        set(CLANG_TIDY_STD_CPP -extra-arg=/std:c++${CMAKE_CXX_STANDARD})
      else ()
        set(CLANG_TIDY_STD_CPP -extra-arg=-std=c++${CMAKE_CXX_STANDARD})
      endif ()
    endif ()

    set(CLANG_TIDY_EXRTA_ARGS -extra-arg=-Wno-unknown-warning-option)
    foreach (extra_arg IN LISTS _EXTRA_ARG)
      list(APPEND CLANG_TIDY_EXRTA_ARGS -extra-arg=${extra_arg})
    endforeach ()

    set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY} ${CLANG_TIDY_STD_CPP} ${CLANG_TIDY_EXRTA_ARGS} -p=${CMAKE_BINARY_DIR}
                             --config-file=${PROJECT_SOURCE_DIR}/.clang-tidy ${_EXTRA_OPTIONS} PARENT_SCOPE)
  else ()
    message(WARNING "clang-tidy requested but executable not found")
  endif ()
endfunction ()
