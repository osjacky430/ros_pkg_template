function (catkin_add_gcov_report)
  set(options VERBOSE)
  set(filterArgs ROOT_DIR FILTER GCOV_FILTER GCOV_EXCLUDE EXCLUDE_SRC EXCLUDE_DIR)
  set(targetArgs TARGET WORKING_DIR)
  set(multiValueArgs OUTPUT_DIR EXTRA_OPTIONS)

  cmake_parse_arguments("" "${options}" "${targetArgs}" "${filterArgs};${multiValueArgs}" ${ARGN})

  find_program(GCOVR gcovr REQUIRED)

  set(GCOVR_OUTPUT_EXTENSIONS ".xml" ".json" ".csv" ".html" ".txt")
  set(GCOVR_OUTPUT_FLAGS "--xml" "--json" "--csv" "--html" "--txt")
  set(output_list)
  foreach (output_file IN LISTS _OUTPUT_DIR)
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
    WORKING_DIRECTORY ${working_dir} BYPRODUCTS ${_OUTPUT_DIR})

endfunction ()

function (catkin_add_profiler_report)
  set(options DISPLAY ADD_PROF_DIR_MACRO)
  set(singleValueArgs EXE_TARGET OUTPUT_FORMAT WORKING_DIR OUTPUT_DIR PROF_FILE_PATH CPUPROFILE_FREQUENCY)
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

  find_program(PPROF pprof REQUIRED)
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
    if (NOT _OUTPUT_DIR)
      set(_OUTPUT_DIR ${WORKING_DIR})
    endif ()

    list(GET PPROF_OUTPUT_EXT ${position} output_ext)
    if (IS_DIRECTORY ${_OUTPUT_DIR})
      set(output_file "${path_to_exe}.${output_ext}")
    else ()
      set(output_file ${_OUTPUT_DIR})
    endif ()

    list(APPEND command_flag --${output_format} ${path_to_exe} ${PROF_FILE_PATH} > ${output_file})
  endif ()

  add_custom_target(run_profiler COMMAND ${CMAKE_COMMAND} -E env CPUPROFILE_FREQUENCY=${_CPUPROFILE_FREQUENCY} ${_EXE_COMMAND})
  add_custom_command(TARGET run_profiler POST_BUILD COMMAND ${PPROF} ${command_flag} WORKING_DIRECTORY ${WORKING_DIR})
endfunction ()
