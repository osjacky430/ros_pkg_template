include_guard()

#
# configure_linker(
#   TARGET target
#   LINKER linker
#   [LINKER_PATH dir]
# )
#
# This function configures linker by checking if the linker is supported by compiler, if yes,
# link the target with -fuse-ld=linker, otherwise it links the target with -B/linker/path if
# compiler support -B option and LINKER_PATH is specified.
#
function (configure_linker)
  set(singleValueArgs TARGET LINKER_NAME LINKER_PATH)
  cmake_parse_arguments("" "" "${singleValueArgs}" "" ${ARGN})

  if (NOT _LINKER_NAME OR NOT _TARGET)
    message(FATAL_ERROR "No linker or target specified!")
  endif ()

  include(CheckCXXCompilerFlag)

  set(_linker_flag "-fuse-ld=${_LINKER_NAME}")
  check_cxx_compiler_flag(${_linker_flag} _cxx_supports_linker)
  if (_cxx_supports_linker)
    target_link_options(${_TARGET} INTERFACE ${_linker_flag})
  elseif (_LINKER_PATH AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    # tell compiler which `ld` it should use by -B option
    find_program(LD_PROGRAM ld HINTS ${_LINKER_PATH})
    if (LD_PROGRAM)
      message(STATUS "Configure linker by \"-B${_LINKER_PATH}\" since \"${_LINKER_NAME}\" is not supported by -fuse-ld")
      target_link_options(${_TARGET} INTERFACE "-B${_LINKER_PATH}")
    else ()
      message(STATUS "Neither do the compiler support -fuse-ld=${_LINKER_NAME} nor does ${_LINKER_PATH} contains `ld` for -B option,
          using default linker.")
    endif ()
  endif ()
endfunction ()
