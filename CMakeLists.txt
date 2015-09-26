# project

cmake_minimum_required(VERSION 3.0)

set(CPACK_PACKAGE_VERSION "0.1.1")
set(CPACK_PACKAGE_VERSION_MAJOR "0")
set(CPACK_PACKAGE_VERSION_MINOR "1")
set(CPACK_PACKAGE_VERSION_PATCH "1")
set(CPACK_PACKAGE_CONTACT )

set(PROJ_LICENSE_FILE COPYING)
set(PROJ_README_FILE  README.txt)

# -- Include the tests in the bin folder?
set(INCLUDE_TEST_IN_BIN FALSE)

# -- Set project name
project(empty-proj)

# -- Include the magic ProjTools
include("cmake/ProjTools.cmake")

# -- Add the subdirectories
set(PROJ_SUBDIRS  unittest; doc; tools; test)

# add all subdirs
foreach(subdir ${PROJ_SUBDIRS})
  add_subdirectory(${subdir})
endforeach(subdir)
