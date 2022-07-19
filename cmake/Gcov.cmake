include_guard()

#
# catkin_add_gcov_report(
#   REPORT_NAME file1 [file2 ...]
#   [VERBOSE]
#   [TARGET target]
#   [WORKING_DIR dir]
#   [GCOVR_EXE dir]
#   [GCOV_EXE dir]
#   [ROOT_DIR dir]
#   [ADD_TRACEFILE pattern [pattern2 ...]]
#   [KEEP_SRC pattern [pattern2 ...]]       # not yet implement
#   [EXCLUDE_SRC pattern [pattern2 ...]]
#   [EXCLUDE_DIR pattern [patern2 ...]]     # not yet implement
#   [GCOV_KEEP pattern [pattern2 ...]]      # not yet implement
#   [GCOV_EXCLUDE pattern [pattern2 ...]]
#   [EXTRA_OPTIONS [flag1 ...]]
# )
#
# This function is a helper function to integrate coverage report with catkin unit testing,
# the implementation mainly focus on flags that can be substitute by CMake variables. Those
# that are not listed should go to ``EXTRA_OPTIONS``.
#
# NOTE: This function should only be in top-level CMakeLists.txt due to the fact that
#       the custom target run_tests is created there.
#
# gcovr related options and its corresponding flags are listed below, for more explanation,
# refer to gcovr documentation
#
#   Options         gcovr flags     Note
#
# ``SONARQUBE``     --sonarqube     Output xml format in sonarqube favor
# ``COBERTURA``     --cobertura     Output xml format in cobertura favor
# ``COVERALLS``     --coveralls     Output json format in coveralls favor
# ``HTML_DETAILS``  --html-details  Using --html-details overrides any value of --html if it is present
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
#       This creates a custom target instead of running after catkin test, useful when you need to invoke gcovr multiple times
#
# ``EXTRA_OPTIONS``
#       This goes right behind the gcovr command
#
# Example: To be added
#
function (catkin_add_gcov_report)
  set(targetArgs TARGET WORKING_DIR)
  set(executableArgs GCOVR_EXE GCOV_EXE)
  set(filterArgs KEEP_SRC GCOV_KEEP GCOV_EXCLUDE EXCLUDE_SRC EXCLUDE_DIR)

  set(options VERBOSE SONARQUBE COVERALLS JSON_SUMMARY HTML_DETAILS)
  set(singleValueArgs ROOT_DIR ${targetArgs} ${executableArgs})
  set(multiValueArgs ${filterArgs} REPORT_NAME ADD_TRACEFILE EXTRA_OPTIONS)

  cmake_parse_arguments("" "${options}" "${singleValueArgs}" "${multiValueArgs}" ${ARGN})

  find_program(GCOVR gcovr PATHS ${_GCOVR_EXE}) # REQUIRED require CMake 3.18
  find_program(GCOV gcov PATHS ${_GCOV_EXE})
  if (GCOVR-NOTFOUND OR GCOV-NOTFOUND)
    message(FATAL_ERROR "Executables that are necessary for coverage reports (gcovr or gcov) are not found!")
  endif ()

  set(GCOVR_OUTPUT_EXTENSIONS ".xml" ".json" ".csv" ".html" ".txt")
  set(GCOVR_OUTPUT_FLAGS
      $<IF:$<BOOL:${_SONARQUBE}>,--sonarqube,--xml>
      $<IF:$<BOOL:${_COVERALLS}>,--coveralls,$<IF:$<BOOL:${_JSON_SUMMARY}>--json-summary,--json>> "--csv"
      $<IF:$<BOOL:${_HTML_DETAILS}>,--html-details,--html> "--txt")

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

  set(exclude_src_list $<$<BOOL:${_EXCLUDE_SRC}>:--exclude=$<JOIN:${_EXCLUDE_SRC},;--exclude=>>)
  set(gcov_filter_list $<$<BOOL:${_GCOV_EXCLUDE}>:--gcov-filter=$<JOIN:${_GCOV_EXCLUDE},;--gcov-filter=>>)
  set(working_dir $<IF:$<BOOL:${_WORKING_DIR}>,${_WORKING_DIR},${CMAKE_BINARY_DIR}>)
  set(root_dir -r $<IF:$<BOOL:${_ROOT_DIR}>,${_ROOT_DIR},${PROJECT_SOURCE_DIR}>)
  set(add_tracefile $<$<AND:$<BOOL:${_ADD_TRACEFILE}>,$<BOOL:${_TARGET}>>:--add-tracefile=$<JOIN:${_ADD_TRACEFILE},;--add-tracefile=>>)

  if (${_VERBOSE})
    list(APPEND _EXTRA_OPTIONS "-v")
  endif ()

  set(GCOV_CMD ${root_dir} ${_EXTRA_OPTIONS} ${output_list} ${exclude_src_list} ${gcov_filter_list} ${add_tracefile})
  if (_TARGET)
    add_custom_target(${_TARGET} COMMAND "$<$<CONFIG:Coverage>:${GCOVR};.;${GCOV_CMD}>" WORKING_DIRECTORY ${working_dir}
                      BYPRODUCTS ${_REPORT_NAME} COMMAND_EXPAND_LISTS)
  elseif (TARGET run_tests)
    message(STATUS "Coverage report will be generated after catkin test")
    add_custom_command(
      TARGET run_tests POST_BUILD # catkin target
      COMMAND "$<$<CONFIG:Coverage>:${GCOVR};.;${GCOV_CMD}>" WORKING_DIRECTORY ${working_dir} BYPRODUCTS ${_REPORT_NAME}
      COMMAND_EXPAND_LISTS)
  else ()
    message(FATAL_ERROR "No target for coverage report")
  endif ()
endfunction ()
