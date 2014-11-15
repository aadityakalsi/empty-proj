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

set(license_file LICENSE.txt)
set(readme_file  README.txt)

# -- Define to use when building project
set(BUILD_DEFINE )

# -- Include the tests in the bin folder?
set(INCLUDE_TEST_IN_BIN FALSE)

# -- Include the cmake modules
if(CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake")
else()
  set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
endif()

# -- Include the magic ProjTools
include(ProjTools)

# -- Add the subdirectories
set(PROJ_SUBDIRS  unittest; doc; tools)

# add all subdirs
foreach(subdir ${PROJ_SUBDIRS})
  add_subdirectory(${subdir})
endforeach(subdir)

