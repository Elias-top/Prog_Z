
collect(PROJECT_LIB_DEPS freertos)
collect(PROJECT_LIB_DEPS metal)
collect(PROJECT_LIB_DEPS xil)
collect(PROJECT_LIB_DEPS c)
collect(PROJECT_LIB_DEPS m)

get_property (HAS_SYSTEM_DT GLOBAL PROPERTY HAS_SYSTEM_DT)
if (HAS_SYSTEM_DT)
  # SDT flow has broken up libxil into multiple libs. Below libs are required
  # for compilation.
  collect(PROJECT_LIB_DEPS xilstandalone)
  collect(PROJECT_LIB_DEPS xiltimer)
endif(HAS_SYSTEM_DT)

set (_lib "xil")
find_library (_lib_path ${_lib})
if (NOT CMAKE_C_FLAGS MATCHES "SDT")
  if (NOT _lib_path)
      message ( "external library ${_lib_path} not found" )
      message ( "hint: you may need to pass -DCMAKE_LIBRARY_PATH=<path>" )
      message ( FATAL_ERROR "library ${_lib} is required to build the examples" )
  endif (NOT _lib_path)
endif (NOT CMAKE_C_FLAGS MATCHES "SDT")
get_filename_component (_lib_path ${_lib_path} DIRECTORY)
collect (PROJECT_LIB_DIRS ${_lib_path})

add_subdirectory(zynqmp_amp_demo)
