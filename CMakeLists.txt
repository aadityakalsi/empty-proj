# project

cmake_minimum_required (VERSION 2.8)

# -- Set project name
set(PROJ_NAME empty-proj)

project (${PROJ_NAME})

# -- Set install dirs
if (DEFINED ENV{INSTALL_BASE_DIR})
  set(PROJ_INSTALL_DIR $ENV{INSTALL_BASE_DIR})
else()
  set(PROJ_INSTALL_DIR ${CMAKE_SOURCE_DIR}/install)
endif()

set(CPACK_PACKAGE_VERSION "0.1.1")
set(CPACK_PACKAGE_VERSION_MAJOR "0")
set(CPACK_PACKAGE_VERSION_MINOR "1")
set(CPACK_PACKAGE_VERSION_PATCH "1")
set(CPACK_PACKAGE_CONTACT )

set(PROJ_LICENSE_FILE COPYING)
set(PROJ_README_FILE  README.txt)

# -- Include the tests in the bin folder?
set(INCLUDE_TEST_IN_BIN FALSE)

# -- Include the magic ProjTools
include("cmake/ProjTools.cmake")

# -- Add the subdirectories
set(PROJ_SUBDIRS  unittest; doc; tools; test)

# add all subdirs
foreach(subdir ${PROJ_SUBDIRS})
  add_subdirectory(${subdir})
endforeach(subdir)

