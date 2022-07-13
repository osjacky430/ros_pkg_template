include_guard()

#
# add_profiler_report(
#   OUTPUT_FORMAT fmt
#   EXE_COMMAND command [arg1 ...]
#   [DISPLAY]
#   [ADD_PRF_DIR_MACRO]
#   [CPUPROFILE_FREQUENCY freq]
#   [EXTRA_OPTIONS opt1 [opt2 ...]]
#   [DEPEND dep1 [dep2 ...]]
# )
#
# This function is a helper function to setup profiler report. the implementation mainly focus on flags
# that can be substitute by CMake variables. Those that are not listed should go to ``EXTRA_OPTIONS``.
#
#   Options                  pprof flags           Note
#
# ``DISPLAY``               --gv/evince/web        Only work with postscript, pdf, svg
# ``OUTPUT_FORMAT``         --text/callgrind/
#                             ps/pdf/svg/dot/raw
#
# ``CPUPROFILE_FREQUENCY``  NA                     environmental variable gperftool uses
#
# Non pprof related options
#
# ``EXE_COMMAND``
#       Command to invoke EXE_TARGET. Note that catkin related command will not work, e.g. catkin run_tests --this
#
# ``ADD_PROF_DIR_MACRO``
#       This option will add compile definition of .prof file path (PROF_FILE_PATH) to the EXE_TARGET
#
# ``DEPEND``
#       File level dependency. This is useful when, for example, EXE_COMMAND is a shell script containing multiple targets,
#       it will ensure the target are built before run_profiler
#
# ``EXE_TARGET``
#       The target to link profiler and add compile definitions
#
# ``EXTRA_OPTIONS``
#       This goes right behind the gcovr command
#
# To generate profiler report, run `catkin build --this --catkin-make-args run_profiler`.
#
function (add_profiler_report)
  set(options DISPLAY ADD_PROF_DIR_MACRO)
  set(singleValueArgs EXE_TARGET OUTPUT_FORMAT CPUPROFILE_FREQUENCY)
  set(multiValueArgs EXTRA_OPTIONS EXE_COMMAND DEPEND)

  cmake_parse_arguments("PROF" "${options}" "${singleValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT PROF_EXE_COMMAND)
    message(FATAL_ERROR "Must specify the command to invoke the executable you want to profile!")
  endif ()

  find_program(PPROF pprof)
  if (PPROF-NOTFOUND)
    message(FATAL_ERROR "pprof is required for profiling!")
  endif ()

  target_link_libraries(${PROF_EXE_TARGET} PUBLIC profiler)
  target_compile_definitions(
    ${PROF_EXE_TARGET} PRIVATE ENABLE_PROFILING=true
                               $<$<BOOL:PROF_ADD_PROF_DIR_MACRO>:PROF_FILE_PATH="$<TARGET_FILE:${PROF_EXE_TARGET}>>.prof")
  set(command_flag)

  set(PPROF_OUTPUT_TYPE_FLAGS "text" "callgrind" "ps" "pdf" "svg" "dot" "raw")
  set(PPROF_OUTPUT_EXT "txt" "callgrind" "ps" "pdf" "svg" "dot" "raw")
  set(PPROF_DISPLAYABLE_TYPE "-" "-" "--gv" "--evince" "--web" "-" "-")
  string(TOLOWER ${PROF_OUTPUT_FORMAT} output_format)
  list(FIND PPROF_OUTPUT_TYPE_FLAGS ${output_format} position)
  if (${position} EQUAL -1)
    message(FATAL_ERROR "${output_format} is not one of the supported format: ${PPROF_OUTPUT_TYPE_FLAGS}")
  endif ()

  if (PROF_DISPLAY)
    list(GET PPROF_DISPLAYABLE_TYPE ${position} flag)
    if (${flag} STREQUAL "-")
      message(FATAL_ERROR "The output format is not one of the displayable filetype: ps, pdf, svg")
    endif ()

    list(APPEND command_flag ${flag})
  else ()
    list(GET PPROF_OUTPUT_EXT ${position} output_ext)
  endif ()

  list(APPEND command_flag --${output_format})
  add_custom_target(run_profiler COMMAND ${CMAKE_COMMAND} -E env CPUPROFILE_FREQUENCY=${PROF_CPUPROFILE_FREQUENCY} ${PROF_EXE_COMMAND}
                    DEPENDS ${PROF_DEPEND})
  add_custom_command(
    TARGET run_profiler POST_BUILD
    COMMAND ${PPROF} ${command_flag} $<TARGET_FILE_NAME:${PROF_EXE_TARGET}> $<TARGET_FILE_NAME:${PROF_EXE_TARGET}>.prof
            $<$<BOOL:PROF_OUTPUT_FORMAT>:$<ANGLE-R>$<TARGET_FILE_NAME:${PROF_EXE_TARGET}>.${output_ext}>
    WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROF_EXE_TARGET}>)
endfunction ()
