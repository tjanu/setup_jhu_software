project(rasta C)
cmake_minimum_required(VERSION 2.8)

set(INSTALL_BIN_DIR bin CACHE PATH "Installation directory for binaries")
set(INSTALL_LIB_DIR lib CACHE PATH "Installation directory for libraries")
set(INSTALL_INCLUDE_DIR include CACHE PATH "Installation directory for headers")
set(INSTALL_DATA_DIR share CACHE PATH "Installation directory for docs/data")
set(INSTALL_MAN_DIR man/man1 CACHE PATH "Installation directory for man pages")

# make relative paths absolute (sadly necessary)
foreach(p LIB BIN INCLUDE DATA MAN)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var}_ABSOLUTE "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()

set(RASTA_VERSION "\"v2_6\"")
add_definitions(-DRASTA_VERSION=${RASTA_VERSION})
set(RASTA_BUILD_LIB_SPEC "-L${CMAKE_BINARY_DIR} -lrasta")
set(RASTA_INSTALL_LIB_SPEC "-L${INSTALL_LIB_DIR} -lrasta")
set(RASTA_BUILD_INC_SPEC "-I${CMAKE_BINARY_DIR} -I${CMAKE_SOURCE_DIR}")
set(RASTA_INSTALL_INC_SPEC "-I${INSTALL_INCLUDE_DIR}")
set(RASTA_SRC_DIR ${CMAKE_SOURCE_DIR})
set(CC ${CMAKE_C_COMPILER})
set(CFLAGS ${CMAKE_C_FLAGS})
set(LDFLAGS ${CMAKE_C_FLAGS})

configure_file(rastaConfig.sh.in ${CMAKE_BINARY_DIR}/rastaConfig.sh @ONLY)

set(libs
)

set(hdrs
    rasta.h
)

include(TestBigEndian)
TEST_BIG_ENDIAN(is_big_endian)

if(is_big_endian)
  add_definitions(-DWORDS_BIGENDIAN)
endif()

configure_file(${CMAKE_SOURCE_DIR}/config.h.in ${CMAKE_BINARY_DIR}/config.h COPYONLY)
include_directories(${CMAKE_BINARY_DIR})

set(srcs
    rasta.c
    init.c
    anal.c
    powspec.c
    noise_est.c
    mapping.c
    audspec.c
    nl_audspec.c
    rasta_filt.c
    inverse_nl.c
    post_audspec.c
    deltas_c.c
    mul_vfmf_vf.c
    lpccep.c
    fft.c
    io.c
    fvecsubs.c
    svecsubs.c
    debug.c
    invcep.c
)

add_library(rasta STATIC ${srcs})
target_link_libraries(rasta ${libs})
set_target_properties(rasta PROPERTIES PUBLIC_HEADER ${hdrs})

install(TARGETS rasta
RUNTIME DESTINATION "${INSTALL_LIB_DIR}" COMPONENT bin
LIBRARY DESTINATION "${INSTALL_LIB_DIR}" COMPONENT shlib
ARCHIVE DESTINATION "${INSTALL_LIB_DIR}" COMPONENT lib
PUBLIC_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}" COMPONENT dev
)
install(PROGRAMS ${CMAKE_BINARY_DIR}/rastaConfig.sh
DESTINATION ${INSTALL_LIB_DIR}
COMPONENT lib
)
