# ProjTools.cmake
# ---------------
#
# CMake module that is meant as a single include in your top level
# CMakeLists.txt.
#
# Before including this module, the following definitions need to
# be in place in your main CMakeLists.txt file.
#
# # Sample CMakeLists.txt
#
# cmake_minimum_required(VERSION 2.8)
#
# set(PROJ_NAME <your_project_name>)
# project(${PROJ_NAME})
# set(PROJ_INSTALL_DIR <install_location>)
# set(CPACK_PACKAGE_VERSION "0.1.1")
# set(CPACK_PACKAGE_VERSION_MAJOR "0")
# set(CPACK_PACKAGE_VERSION_MINOR "1")
# set(CPACK_PACKAGE_VERSION_PATCH "1")
# set(CPACK_PACKAGE_CONTACT <your_email>)
# 
# set(license_file <license_file>)
# set(readme_file  <readme_file>)
#
# set(BUILD_DEFINE <proj>_BUILDING)
#
# # -- Include this module
# set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
# include(ProjTools)
#
# # -- Add targets below
#

cmake_minimum_required(VERSION 2.8)

# -- Force the build type to ensure this works on Windows
if(NOT CMAKE_BUILD_TYPE)
  if (NOT CMAKE_BUILD_TYPE_FORCE)
    set(bld_type Debug)
  else()
    set(bld_type ${CMAKE_BUILD_TYPE_FORCE})
  endif(NOT CMAKE_BUILD_TYPE_FORCE)
  set(CMAKE_BUILD_TYPE ${bld_type} CACHE STRING
        "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
	 FORCE)
endif(NOT CMAKE_BUILD_TYPE)

# -- Get the folder containing the project
get_filename_component(PROJ_BASE_DIR_TMP ${CMAKE_CURRENT_SOURCE_DIR} PATH)
set(PROJ_BASE_DIR ${PROJ_BASE_DIR_TMP} CACHE INTERNAL "Base dir" FORCE)
message("-- Base include dir: " ${PROJ_BASE_DIR})
message("-- Install location: " ${PROJ_INSTALL_DIR})

# -- Define project globals: INSTALL dirs
set(PROJ_INSTALL_BIN_DIR bin)
set(PROJ_INSTALL_LIB_DIR lib)
set(PROJ_INSTALL_INC_DIR include/${PROJ_NAME})

if(WIN32)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
endif(WIN32)

set(CMAKE_INSTALL_PREFIX ${PROJ_INSTALL_DIR})

# -- Fix RPATH
if (UNIX)
  if(APPLE)
    set(CMAKE_INSTALL_NAME_DIR "@executable_path/../${PROJ_INSTALL_LIB_DIR}")
  else()
    set(CMAKE_INSTALL_RPATH "\$ORIGIN/../${PROJ_INSTALL_LIB_DIR}")
  endif()
endif(UNIX)

include(InstallRequiredSystemLibraries)

# -- Add BUILD_DEFINE flag for import/export sym
if (BUILD_DEFINE)
  add_definitions(-D ${BUILD_DEFINE})
endif()

# -- Add warning flags
# * Error on warnings, and enable all
if(WIN32)
  add_definitions(/W3 /WX)
else()
  add_definitions(-std=c99 -Wall -Werror)
endif(WIN32)

# -- Set up temp dir
set(TMPDIR ${CMAKE_BINARY_DIR}/temp CACHE INTERNAL "Temp dir" FORCE)
file(MAKE_DIRECTORY ${TMPDIR})
if(NOT EXISTS "${TMPDIR}")
  message(FATAL_ERROR "OOOPS, can't determine temporary directory")
endif()

# --- INSTALLATION
install(FILES ${license_file} ${readme_file} DESTINATION .)

# --- PACKAGING
# include CPack for packagaing
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/${license_file})
set(CPACK_RESOURCE_FILE_README  ${CMAKE_SOURCE_DIR}/${readme_file})

# On Windows, the package install name must be set
if (WIN32)
  set(CPACK_PACKAGE_INSTALL_DIRECTORY ${PROJ_NAME})
endif(WIN32)

include(CPack)

# -- Code coverage defines
if ((UNIX OR APPLE) AND (CMAKE_BUILD_TYPE STREQUAL "Debug"))
  set(USE_CODE_COV 1)
  add_definitions("-O0 -fprofile-arcs -ftest-coverage")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fprofile-arcs -ftest-coverage")
  file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/coverage)
else()
  set(USE_CODE_COV 0)
endif()

# -- add_inc_dir: Add include dir to target (include_directories, but target specific!)
function(add_inc_dir tgt dir)
    set(new_inc_dir ${dir})
    get_target_property(curr_inc_dir ${tgt} INCLUDE_DIRECTORIES)
    if(curr_inc_dir)
      set(new_inc_dir ${curr_inc_dir};${new_inc_dir})
    endif(curr_inc_dir)
	set_property(TARGET ${tgt} PROPERTY INCLUDE_DIRECTORIES ${new_inc_dir})
endfunction(add_inc_dir)

# -- add_exe: Add executable target (add_executable mimic)
function(add_exe tgt)
  add_executable(${ARGV})
  add_inc_dir(${tgt} ${PROJ_BASE_DIR})
endfunction(add_exe)

# -- link_libs: Link to libraries (add_library mimic)
function(link_libs tgt)
    set(xtra_libs )
	
if (USE_CODE_COV)
  if (APPLE)
    set(new_link_flags "--coverage")
    get_target_property(existing_link_flags ${tgt} LINK_FLAGS)
    if(existing_link_flags)
        set(new_link_flags "${existing_link_flags} ${new_link_flags}")
    endif()
    set_target_properties(${tgt} PROPERTIES LINK_FLAGS ${new_link_flags})
  else()#UNIX
    set(xtra_libs gcov)
  endif()
endif()

  target_link_libraries(${ARGV} ${xtra_libs})
  add_inc_dir(${tgt} ${PROJ_BASE_DIR})
endfunction(link_libs)

# -- set_tgt_ver: Set target version
function(set_tgt_ver tgt)
  get_property(tgt_type TARGET ${tgt} PROPERTY TYPE)
  string(REPLACE "SHARED_LIBRARY" "" empty_if_so ${tgt_type})
  if(empty_if_so)
    set_target_properties(${tgt} PROPERTIES VERSION ${ARGV1})
  else()
    set_target_properties(${tgt} PROPERTIES VERSION ${ARGV1} SOVERSION ${ARGV2})
  endif()
endfunction(set_tgt_ver)

# Link library install function: For test_on_install builds
function(link_libs_install tgt)
  set(xtra_libs )
	
if (USE_CODE_COV)
  if (APPLE)
    set(new_link_flags "--coverage")
    get_target_property(existing_link_flags ${tgt} LINK_FLAGS)
    if(existing_link_flags)
        set(new_link_flags "${existing_link_flags} ${new_link_flags}")
    endif()
    set_target_properties(${tgt} PROPERTIES LINK_FLAGS ${new_link_flags})
  else()#UNIX
    set(xtra_libs gcov)
  endif()
endif()

  target_link_libraries(${ARGV} ${xtra_libs})
  add_inc_dir(${tgt} ${PROJ_INSTALL_DIR}/include)
endfunction(link_libs_install)

# -- install_hdr: Install headers function
function(install_hdr)
  string(REGEX REPLACE "${CMAKE_SOURCE_DIR}" "${PROJ_INSTALL_INC_DIR}" relpath ${CMAKE_CURRENT_SOURCE_DIR})
  install(FILES ${ARGV} DESTINATION ${relpath})
endfunction(install_hdr)

# -- install_tgt: Install target function
function(install_tgt libname)
  install(TARGETS ${libname}
          ARCHIVE DESTINATION ${PROJ_INSTALL_LIB_DIR}
          LIBRARY DESTINATION ${PROJ_INSTALL_LIB_DIR}
          RUNTIME DESTINATION ${PROJ_INSTALL_BIN_DIR})
endfunction(install_tgt)

# -- TEST RELATED HELPERS

# enable testing for test subfolder
enable_testing()

# add the check target
add_custom_target(check)

# run the install to allow check on install
add_custom_target(install_for_check DEPENDS check)
add_custom_command(OUTPUT install_for_check.done
                   DEPENDS install_for_check
                   COMMAND ${CMAKE_COMMAND} --build ${CMAKE_CURRENT_BINARY_DIR} --target install
                   COMMAND ${CMAKE_COMMAND} -E touch install_for_check.done)

add_custom_target(install_for_check_done DEPENDS install_for_check.done)

# add the check on install
add_custom_target(check_on_install)

# -- add_hdrs_ide: Add headers to IDE
function(add_hdrs_ide)
  get_filename_component(submod_name ${CMAKE_CURRENT_SOURCE_DIR} NAME)
  add_custom_target("${submod_name}.src" ALL SOURCES ${ARGN})
endfunction(add_hdrs_ide)

# -- add_test_exe: Add test executable
function(add_test_exe testname filename)
  ## deal with normal test
  include_directories(${PROJ_BASE_DIR})
  add_exe(${ARGV} ${CMAKE_SOURCE_DIR}/unittest/unittest.h)
  
  # On Windows, the custom build detects the "ERROR" word in the
  # output and fails a passing test. We simply detect on the executable's
  # return code to detect failure.
  if((WIN32) AND (${testname} STREQUAL "test_unittest"))
    add_custom_command(TARGET ${testname} POST_BUILD COMMAND ${testname} 2>nul)
  else()
    add_custom_command(TARGET ${testname} POST_BUILD COMMAND ${testname})
  endif()

  add_dependencies(check ${testname})

  # deal with test on install
  # copy file to temp folder
  set(test_dirname "${testname}.toi")
  message("-- TOI: Adding test for ${testname} in dir ${test_dirname}")
  
  # copy the file over
  file(MAKE_DIRECTORY ${test_dirname})
  file(COPY ${filename} DESTINATION ${test_dirname})
  
  # generate a CMakeLists.txt
  set("${testname}_gen" 1 CACHE INTERNAL "Base dir" FORCE)
  if ("${${testname}_gen}")
    file(WRITE ${test_dirname}/CMakeLists.txt
      "# Generated CMakeLists.txt for install test ${testname}\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "set_directory_properties(PROPERTIES INCLUDE_DIRECTORIES ${PROJ_INSTALL_DIR}/include)\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "if (USE_CODE_COV)\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "  add_definitions(-O0 -fprofile-arcs -ftest-coverage)\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "  set(CMAKE_EXE_LINKER_FLAGS=\"-fprofile-arcs -ftest-coverage\")\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "  file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/coverage)\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "endif()\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "add_executable(${testname}_install ${filename})\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "add_dependencies(${testname}_install install_for_check_done)\n")
  endif()
endfunction(add_test_exe)

# -- test_link_libs: Link libraries to test
function(test_link_libs testname)
  link_libs(${ARGV})

  set(install_test_args ${ARGV})
  list(REMOVE_AT install_test_args 0)
  list(INSERT install_test_args 0 "${testname}_install")
  # deal with test on install
  if ("${${testname}_gen}")
    set(test_dirname "${testname}.toi")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "set_directory_properties(PROPERTIES LINK_DIRECTORIES ${PROJ_INSTALL_DIR}/${PROJ_INSTALL_LIB_DIR})\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "link_libs_install(${install_test_args})\n")
  endif()
endfunction(test_link_libs)

# -- create_test: Bless this target
function(create_test testname)
  if ("${${testname}_gen}")
    set(test_dirname "${testname}.toi")

    # On Windows, the custom build detects the "ERROR" word in the
    # output and fails a passing test. We simply detect on the executable's
    # return code to detect failure.
    if((WIN32) AND (${testname} STREQUAL "test_unittest"))
      set(xtra_args "2>nul")
    else()
      set(xtra_args "")
    endif()

    file(APPEND ${test_dirname}/CMakeLists.txt
      "add_custom_command(OUTPUT ${testname}.toi.done\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "  COMMAND ${testname}_install ${xtra_args}\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "  COMMAND \"${CMAKE_COMMAND}\" -E touch ${testname}.toi.done\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "  DEPENDS ${testname}_install)\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "add_custom_target(${testname}_install_run DEPENDS ${testname}.toi.done)\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "add_dependencies(check_on_install ${testname}_install_run)\n")
    set("${testname}_gen" 0 CACHE INTERNAL "Base dir" FORCE)
  endif()

  # add the subdir!
  add_subdirectory(${test_dirname} EXCLUDE_FROM_ALL)
  if(${INCLUDE_TEST_IN_BIN})
    install_tgt(${testname})
  endif()
endfunction(create_test)

# -- GENERATE CODE COVERAGE REPORT
  if(USE_CODE_COV)
    if (APPLE)
      set(browser_cmd "open")
    else()
      set(browser_cmd "firefox")
    endif()
    if (WIN32)
      set(cd_cmd "cd /d")
    else()
      set(cd_cmd "cd")
    endif()
    
    include(CodeCoverage)
    
    add_custom_target(check.cov.gen ALL)
    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/check
                       DEPENDS check.cov.gen
                       COMMAND echo "#!/bin/sh" > ${CMAKE_BINARY_DIR}/check
                       COMMAND echo "${cd_cmd} ${CMAKE_BINARY_DIR}" >> ${CMAKE_BINARY_DIR}/check
                       COMMAND echo "${CMAKE_COMMAND} .." >> ${CMAKE_BINARY_DIR}/check
                       COMMAND echo "${CMAKE_COMMAND} --build ." >> ${CMAKE_BINARY_DIR}/check
                       COMMAND chmod u+x ${CMAKE_BINARY_DIR}/check)
    add_custom_target(check.cov.gen.done DEPENDS check.cov.gen ${CMAKE_BINARY_DIR}/check)
    SETUP_TARGET_FOR_COVERAGE(check.cov ${CMAKE_BINARY_DIR}/check ${CMAKE_BINARY_DIR}/coverage)
    add_dependencies(check.cov check.cov.gen.done)
    add_custom_target(check.cov.done DEPENDS check.cov)
    add_custom_command(TARGET check.cov.done
        POST_BUILD COMMAND ${browser_cmd} coverage/index.html)
    add_custom_target(code_cov DEPENDS check.cov.done)
  endif()