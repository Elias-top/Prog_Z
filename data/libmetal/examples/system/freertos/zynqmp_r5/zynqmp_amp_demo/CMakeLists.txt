collector_list  (_list PROJECT_INC_DIRS)
include_directories (${_list} ${CMAKE_CURRENT_SOURCE_DIR})

collector_list  (_list PROJECT_LIB_DIRS)
link_directories (${_list})

collector_list (_deps PROJECT_LIB_DEPS)

set (_linker_script ${CMAKE_CURRENT_SOURCE_DIR}/lscript.ld)

set (_src_common ${CMAKE_CURRENT_SOURCE_DIR}/init_${PROJECT_SYSTEM}.c)
set (_app0 libmetal_amp_demod)

if (DEFINED CMAKE_PROJECT_NAME)
  set (_app0 ${CMAKE_PROJECT_NAME})
endif(DEFINED CMAKE_PROJECT_NAME)

set (_src0 ${CMAKE_CURRENT_SOURCE_DIR}/libmetal_amp_demod.c)
list(APPEND _src0 ${CMAKE_CURRENT_SOURCE_DIR}/sys_init.c)
list(APPEND _src0 ${CMAKE_CURRENT_SOURCE_DIR}/shmem_demod.c)
list(APPEND _src0 ${CMAKE_CURRENT_SOURCE_DIR}/shmem_atomic_demod.c)
list(APPEND _src0 ${CMAKE_CURRENT_SOURCE_DIR}/ipi_shmem_demod.c)
list(APPEND _src0 ${CMAKE_CURRENT_SOURCE_DIR}/ipi_latency_demod.c)
list(APPEND _src0 ${CMAKE_CURRENT_SOURCE_DIR}/shmem_latency_demod.c)
list(APPEND _src0 ${CMAKE_CURRENT_SOURCE_DIR}/shmem_throughput_demod.c)

include(CheckSymbolExists)
check_symbol_exists(SDT "bspconfig.h" HAS_SYSTEM_DT)
check_symbol_exists(VERSAL_NET "bspconfig.h" IS_VERSAL_NET)
if (HAS_SYSTEM_DT)
  if (IS_VERSAL_NET)
    set (_linker_script ${CMAKE_CURRENT_SOURCE_DIR}/lscript_sdt_versal_net.ld)
  else()
    set (_linker_script ${CMAKE_CURRENT_SOURCE_DIR}/lscript_sdt.ld)
  endif(IS_VERSAL_NET)
endif(HAS_SYSTEM_DT)

if (DEFINED DEMO_LINK_FLAGS)
  set (_deps "${_deps} ${DEMO_LINK_FLAGS}")
endif()

get_property (_linker_options GLOBAL PROPERTY TEST_LINKER_OPTIONS)
add_executable (${_app0}.elf ${_src0})
get_property (_ec_flgs GLOBAL PROPERTY "PROJECT_EC_FLAGS")
target_compile_options (${_app0}.elf PUBLIC ${_ec_flgs})
target_link_libraries(${_app0}.elf -Wl,-Map=${_app0}.map -Wl,--gc-sections -T\"${_linker_script}\" -Wl,--start-group ${_deps} -Wl,--end-group)
install (TARGETS ${_app0}.elf RUNTIME DESTINATION bin)
