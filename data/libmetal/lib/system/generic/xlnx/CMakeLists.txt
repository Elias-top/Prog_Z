if ("${PROJECT_MACHINE}" STREQUAL "microblaze_generic")
  add_subdirectory(microblaze_generic)
else()
  collect (PROJECT_LIB_SOURCES sys.c)
endif()

collect (PROJECT_LIB_HEADERS sys.h)

collect (PROJECT_LIB_SOURCES irq.c)

if (CMAKE_C_FLAGS MATCHES "SDT")
  collect (PROJECT_LIB_HEADERS sys_devicetree.h)
endif (CMAKE_C_FLAGS MATCHES "SDT")
