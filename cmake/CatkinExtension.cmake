#
# catkin_add_gcov_report(
#   REPORT_NAME file1 [file2 ...]
#   [VERBOSE]
#   [TARGET target]
#   [WORKING_DIR dir]
#   [GCOVR_EXE dir]
#   [GCOV_EXE dir]
#   [ROOT_DIR dir]                          # not yet implement
#   [KEEP_SRC pattern [pattern2 ...]]       # not yet implement
#   [EXCLUDE_SRC pattern [pattern2 ...]]
#   [EXCLUDE_DIR pattern [patern2 ...]]     # not yet implement
#   [GCOV_KEEP pattern [pattern2 ...]]      # not yet implement
#   [GCOV_EXCLUDE pattern [pattern2 ...]]
#   [EXTRA_OPTIONS [flag1 ...]]
# )
#
# This function is a helper function to integrate coverage report with catkin unit testing,
# it is intended to provide user a handy way to generate coverage report, the implementation
# mainly focus on flags that can be substitute by CMake variables. Those that are not listed
# should go to ``EXTRA_OPTIONS``.
#
# NOTE: This function should only be in top-level CMakeLists.txt due to the fact that
#       the custom target run_tests is created here.
#
# gcovr related options and its corresponding flags are listed below, for more explanation,
# refer to gcovr documentation
#
#   Options         gcovr flags     Note
#
# ``VERBOSE``       --verbose
# ``ROOT_DIR``      --root          Default to ${PROJECT_SOURCE_DIR}
# ``KEEP_SRC``      --filter
# ``GCOV_KEEP``     --gcov-filter
# ``GCOV_EXCLUDE``  --gcov-exclude
# ``EXCLUDE_SRC``   --exclude
# ``EXCLUDE_DIR``   --exclude-directories
#
# Non gcovr related options:
#
# ``REPORT_NAME``
#        The output file of the gcov report, this function will extract the extension and append
#        suitable flags for each extensions. For example: passing "coverage.xml" will append
#        "--xml" to gcovr
#
# ``WORKING_DIR``
#       Working directory of gcovr program, default to ${CMAKE_BINARY_DIR}
#
# ``GCOVR_EXE``, ```GCOV_EXE```
#       Search path of gcovr/gcov, currently only support gcov, not llvm-cov
#
# ``TARGET``
#       This adds dependency of target to run_tests, i.e., target will be built before
#       run_tests, this is useful when you have custom test (rostest with argument is
#       one of the examples, even though I think this isn't the right way to do it), or
#       some setup that needs to be done before run_tests
#
# ``EXTRA_OPTIONS``
#       This goes right behind the gcovr command
#
# TODO: maybe we dont need to make it function, just make it a script?
#
function (catkin_add_gcov_report)
  set(options VERBOSE)
  set(filterArgs ROOT_DIR KEEP_SRC GCOV_KEEP GCOV_EXCLUDE EXCLUDE_SRC EXCLUDE_DIR)
  set(targetArgs TARGET WORKING_DIR)
  set(executableArgs GCOVR_EXE GCOV_EXE)
  set(multiValueArgs REPORT_NAME EXTRA_OPTIONS)

  cmake_parse_arguments("" "${options}" "${targetArgs};${executableArgs}" "${filterArgs};${multiValueArgs}" ${ARGN})

  find_program(GCOVR gcovr PATHS ${_GCOVR_EXE}) # REQUIRED require CMake 3.18
  find_program(GCOV gcov PATHS ${_GCOV_EXE})
  if (GCOVR-NOTFOUND OR GCOV-NOTFOUND)
    message(FATAL_ERROR "Executables that are necessary for coverage reports (gcovr or gcov) are not found!")
  endif ()

  set(GCOVR_OUTPUT_EXTENSIONS ".xml" ".json" ".csv" ".html" ".txt")
  set(GCOVR_OUTPUT_FLAGS "--xml" "--json" "--csv" "--html" "--txt")
  set(output_list)
  if (NOT _REPORT_NAME)
    message(FATAL_ERROR "no report name specified")
  endif ()
  foreach (output_file IN LISTS _REPORT_NAME)
    get_filename_component(extension ${output_file} EXT)
    list(FIND GCOVR_OUTPUT_EXTENSIONS ${extension} position)
    if (${position} EQUAL -1)
      message(FATAL_ERROR "${extension} is not supported by gcovr, supported format: ${GCOVR_OUTPUT_EXTENSIONS}")
    else ()
      list(GET GCOVR_OUTPUT_FLAGS ${position} flag)
      list(APPEND output_list "${flag}" "${output_file}")
    endif ()

  endforeach ()

  set(gcov_filter_list)
  foreach (gcov_filter IN LISTS _GCOV_EXCLUDE)
    list(APPEND gcov_filter_list "--gcov-exclude=\"${gcov_filter}\"")
  endforeach ()

  set(exclude_src_list)
  foreach (exclude_src IN LISTS _EXCLUDE_SRC)
    list(APPEND exclude_src_list "-e" "${exclude_src}")
  endforeach ()

  if (TARGET ${_TARGET})
    add_dependencies(run_tests ${_TARGET})
  endif ()

  if (NOT ${_WORKING_DIR})
    set(working_dir ${CMAKE_BINARY_DIR})
  endif ()

  if (${_VERBOSE})
    list(APPEND _EXTRA_OPTIONS "-v")
  endif ()

  add_custom_command(
    TARGET run_tests # catkin target
    POST_BUILD COMMAND ${GCOVR} . -r ${PROJECT_SOURCE_DIR} ${_EXTRA_OPTIONS} ${output_list} ${gcov_filter_list} ${exclude_src_list}
    WORKING_DIRECTORY ${working_dir} BYPRODUCTS ${_REPORT_NAME})

endfunction ()

#
# add_profiler_report(
#   REPORT_NAME file
#   EXE_COMMAND command [arg1 ...]
#   [DISPLAY]
#   [ADD_PRF_DIR_MACRO]
#   [CPUPROFILE_FREQUENCY freq]
#   [WORKING_DIR dir]
#   [PROF_FILE_PATH dir]
# )
#
function (add_profiler_report)
  set(options DISPLAY ADD_PROF_DIR_MACRO)
  set(singleValueArgs EXE_TARGET OUTPUT_FORMAT WORKING_DIR REPORT_NAME PROF_FILE_PATH CPUPROFILE_FREQUENCY)
  set(multiValueArgs EXTRA_OPTIONS EXE_COMMAND)

  cmake_parse_arguments("" "${options}" "${singleValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT _EXE_COMMAND)
    message(FATAL_ERROR "Must specify the command to invoke the executable you want to profile!")
  endif ()

  if (NOT _WORKING_DIR)
    set(WORKING_DIR ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_BIN_DESTINATION})
  else ()
    get_filename_component(WORKING_DIR ${_WORKING_DIR} ABSOLUTE)
  endif ()

  find_program(PPROF pprof)
  if (PPROF-NOTFOUND)
    message(FATAL_ERROR "pprof is required to for profiling!")
  endif ()

  get_target_property(executable_name ${_EXE_TARGET} OUTPUT_NAME)
  if (${executable_name} STREQUAL "executable_name-NOTFOUND")
    set(path_to_exe "${WORKING_DIR}/${_EXE_TARGET}")
  else ()
    set(path_to_exe "${WORKING_DIR}/${executable_name}")
  endif ()

  if (NOT _PROF_FILE_PATH)
    set(PROF_FILE_PATH ${path_to_exe}.prof)
  elseif (NOT IS_ABSOLUTE ${_PROF_FILE_PATH})
    get_filename_component(PROF_FILE_PATH ${_PROF_FILE_PATH} ABSOLUTE BASE_DIR ${WORKING_DIR})
  endif ()

  target_link_libraries(${_EXE_TARGET} PUBLIC profiler)
  target_compile_definitions(${_EXE_TARGET} PRIVATE ENABLE_PROFILING=true)
  if (_ADD_PROF_DIR_MACRO)
    target_compile_definitions(${_EXE_TARGET} PRIVATE PROF_FILE_PATH="${PROF_FILE_PATH}")
  endif ()

  set(command_flag)

  set(PPROF_OUTPUT_TYPE_FLAGS "text" "callgrind" "ps" "pdf" "svg" "dot" "raw")
  set(PPROF_OUTPUT_EXT "txt" "callgrind" "ps" "pdf" "svg" "dot" "raw")
  set(PPROF_DISPLAYABLE_TYPE "-" "-" "--gv" "--evince" "--web" "-" "-")
  string(TOLOWER ${_OUTPUT_FORMAT} output_format)
  list(FIND PPROF_OUTPUT_TYPE_FLAGS ${output_format} position)
  if (${position} EQUAL -1)
    message(FATAL_ERROR "${output_format} is not one of the supported format: ${PPROF_OUTPUT_TYPE_FLAGS}")
  endif ()

  if (_DISPLAY)
    list(GET PPROF_DISPLAYABLE_TYPE ${position} flag)
    if (${flag} STREQUAL "-")
      message(FATAL_ERROR "The output format is not one of the displayable filetype: ps, pdf, svg")
    endif ()

    list(APPEND command_flag ${flag})
  else ()
    if (NOT _REPORT_NAME)
      set(_REPORT_NAME ${WORKING_DIR})
    endif ()

    list(GET PPROF_OUTPUT_EXT ${position} output_ext)
    if (IS_DIRECTORY ${_REPORT_NAME})
      set(output_file "${path_to_exe}.${output_ext}")
    else ()
      set(output_file ${_REPORT_NAME})
    endif ()

    list(APPEND command_flag --${output_format} ${path_to_exe} ${PROF_FILE_PATH} > ${output_file})
  endif ()

  add_custom_target(run_profiler COMMAND ${CMAKE_COMMAND} -E env CPUPROFILE_FREQUENCY=${_CPUPROFILE_FREQUENCY} ${_EXE_COMMAND})
  add_custom_command(TARGET run_profiler POST_BUILD COMMAND ${PPROF} ${command_flag} WORKING_DIRECTORY ${WORKING_DIR})
endfunction ()
