include_guard()

include(StaticAnalyzers)
include(StandardProjectSetting)
include(CompilerCache)
include(Linker)
include(Sanitizers)
include(Optimization)
include(CompilerWarning)
include(Coverage)

function (configure_project_option)
  set(groups WARNINGS CPP_CHECK CLANG_TIDY LINKER COMPILER_CACHE)
  cmake_parse_arguments(GRP "" "" "${groups}" ${ARGN})

  set(warning_args TARGET PROJECT_WARNINGS)
  set(linker_args TARGET LINKER_NAME LINKER_PATH)
  set(ccache_args CCACHE_BASE_DIR)
  cmake_parse_arguments(WARNING "" "${warning_args}" "" "${GRP_WARNINGS}")
  cmake_parse_arguments(LINKER "" "${linker_args}" "" "${GRP_LINKER}")
  cmake_parse_arguments(CCACHE "" "${ccache_args}" "" "${GRP_COMPILER_CACHE}")

  if (NOT TARGET WARNING_TARGET)
    add_library(${WARNING_TARGET} INTERFACE)
  endif ()

  if (NOT TARGET LINKER_TARGET)
    add_library(${LINKER_TARGET} INTERFACE)
  endif ()

  set_project_warnings(TARGET ${WARNING_TARGET} WARNINGS ${WARNING_PROJECT_WARNINGS})
  configure_linker(TARGET ${LINKER_TARGET} LINKER_NAME ${LINKER_LINKER_NAME} LINKER_PATH ${LINKER_LINKER_PATH}})
endfunction ()
