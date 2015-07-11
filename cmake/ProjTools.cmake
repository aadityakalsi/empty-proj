# ProjTools.cmake
# ---------------
# 
# CMake module that is meant as a single include in your top level
# CMakeLists.txt.
# 
# Before including this module, the following definitions need to
# be in place in your main CMakeLists.txt file.
# 
# Project structure:
# 
# + project
# |
# |- CMakeLists.txt
# |- LICENSE.txt
# |- README.txt
# |+ cmake
# |+ module1
# |+ module2
# |...
# |+ unittest (Unittest header available for writing unittests)
# |
# 
# Sample CMakeLists.txt file:
# 
# # CMakeLists.txt
# #
# # # -- This cmake file works only wth CMake >= 3.0
# # cmake_minimum_required(VERSION 3.0)
# #
# # # -- Set the project versioning details
# # set(PROJ_NAME <your_project_name>)
# # project(${PROJ_NAME})
# # set(PROJ_INSTALL_DIR <install_location>)
# # set(CPACK_PACKAGE_VERSION "0.1.1")
# # set(CPACK_PACKAGE_VERSION_MAJOR "0")
# # set(CPACK_PACKAGE_VERSION_MINOR "1"))
# # set(CPACK_PACKAGE_VERSION_PATCH "1")
# # set(CPACK_PACKAGE_CONTACT <your_email>)
# #
# # # -- Set the license and readme file for your project
# # set(PROJ_LICENSE_FILE <PROJ_LICENSE_FILE>)
# # set(PROJ_README_FILE  <PROJ_README_FILE>)
#
# # # -- Include this module
# # set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
# # set(USE_CPP )
# # # -- Can also set USE_CPP11
# #
# # # -- Finally include this magic CMake file
# # include(ProjTools)
# #
# # # -- Add targets below
# # add_subdirectory(module1; module2)
# #
# # # -- Functions available
# # add_inc_dir()
# # add_exe()
# # add_lib()
# # add_lib_build_def()
# # link_libs()
# # set_tgt_ver()
# # install_hdr()
# # install_tgt()
# # 
# # # -- Functions available for tests
# # In tests, you should use:
# # add_test_exe()
# # test_link_libs()
# # create_test()
# #
#

cmake_minimum_required(VERSION 3.0)

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

string(COMPARE EQUAL ${CMAKE_C_COMPILER_ID} "MSVC" is_msvc)
if(is_msvc)
  set(USING_MSVC TRUE CACHE STRING "Using MSVC")
  if(PROJ_USE_LTO)
    set(CMAKE_C_FLAGS_RELEASE
      "${CMAKE_C_FLAGS_RELEASE} /Ob2 /GL")
    set(CMAKE_CXX_FLAGS_RELEASE
      "${CMAKE_CXX_FLAGS_RELEASE} /Ob2 /GL")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE
      "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /LTCG /INCREMENTAL:NO /OPT:REF")
    set(CMAKE_MODULE_LINKER_FLAGS_RELEASE
      "${CMAKE_MODULE_LINKER_FLAGS_RELEASE} /LTCG /INCREMENTAL:NO /OPT:REF")
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE
      "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /LTCG /INCREMENTAL:NO /OPT:REF")
    set(STATIC_LIBRARY_FLAGS_RELEASE
      "${STATIC_LIBRARY_FLAGS_RELEASE} /LTCG /INCREMENTAL:NO /OPT:REF")
  endif()
else()#GCC like compiler
  if(PROJ_USE_LTO)
    set(CMAKE_C_FLAGS_RELEASE
      "${CMAKE_C_FLAGS_RELEASE} -flto")
    set(CMAKE_CXX_FLAGS_RELEASE
      "${CMAKE_CXX_FLAGS_RELEASE} -flto")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE
      "${CMAKE_EXE_LINKER_FLAGS_RELEASE} -flto")
    set(CMAKE_MODULE_LINKER_FLAGS_RELEASE
      "${CMAKE_MODULE_LINKER_FLAGS_RELEASE} -flto")
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE
      "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} -flto")
    set(STATIC_LIBRARY_FLAGS_RELEASE
      "${STATIC_LIBRARY_FLAGS_RELEASE} -flto")
  endif()
endif()

if(CMAKE_C_COMPILER_ID MATCHES "Clang")
  set(USING_CLANG TRUE CACHE STRING "Using Clang")
  if(APPLE)
    set(USING_APPLE_CLANG TRUE CACHE STRING "Using AppleClang")
  endif()
endif()

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

# -- For Windows, add the required system libraries
include(InstallRequiredSystemLibraries)

# -- Set up temp dir
set(TMPDIR ${CMAKE_BINARY_DIR}/temp CACHE INTERNAL "Temp dir" FORCE)
file(MAKE_DIRECTORY ${TMPDIR})
if(NOT EXISTS "${TMPDIR}")
  message(FATAL_ERROR "OOOPS, can't determine temporary directory")
endif()

# --- INSTALLATION
install(FILES ${PROJ_LICENSE_FILE} ${PROJ_README_FILE} DESTINATION .)

# --- PACKAGING
# include CPack for packagaing
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/${PROJ_LICENSE_FILE})
set(CPACK_RESOURCE_FILE_README  ${CMAKE_SOURCE_DIR}/${PROJ_README_FILE})

# On Windows, the package install name must be set
if (WIN32)
  set(CPACK_PACKAGE_INSTALL_DIRECTORY ${PROJ_NAME})
endif(WIN32)

include(CPack)

# -- Add C++ and C++11 flags and C99 flags
if (NOT WIN32)
  if (USE_CPP)
    if (USE_CPP11)
      set(STD_CPPVER_FLAG -std=c++11)
    else()
      set(STD_CPPVER_FLAG -std=c++03)
    endif(USE_CPP11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${STD_CPPVER_FLAG}")
  endif(USE_CPP)

  set(STD_CVER_FLAG -std=c99)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${STD_CVER_FLAG}")
endif(NOT WIN32)

# -- Code coverage defines
if ((UNIX OR APPLE) AND (CMAKE_BUILD_TYPE STREQUAL "Debug"))
  set(USE_CODE_COV 1)
  file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/coverage)
else()
  set(USE_CODE_COV 0)
endif()

# -- For debug with lcov, we skip -Wl,-no-undefined
if((NOT USE_CODE_COV) AND (NOT WIN32))
  if(USING_APPLE_CLANG)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-undefined,error")
  else()#GCC like compiler
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")
  endif()
endif()

# -- add_comp_flag: Add compile flag to target
function(add_comp_flag tgt def)
  target_compile_options(${tgt} PUBLIC ${def})
endfunction(add_comp_flag)

# -- add_comp_def: Add compile definitions
function(add_comp_def tgt def)
  get_target_property(compile_defs ${tgt} COMPILE_DEFINITIONS)
  if(compile_defs)
    set(compile_defs "${compile_defs} ${def}")  
  else()
    set(compile_defs ${def})
  endif(compile_defs)
  set_target_properties(${tgt} PROPERTIES COMPILE_DEFINITIONS ${compile_defs})
endfunction(add_comp_def)

# -- add_link_flag: Add link flag to target
function(add_link_flag tgt flag)
    set(new_flags ${flag})
    get_target_property(curr_flags ${tgt} LINK_FLAGS)
    if(curr_flags)
      set(new_flags "${curr_flags} ${new_flags}")
    endif(curr_flags)
    set_property(TARGET ${tgt} PROPERTY LINK_FLAGS ${new_flags})
endfunction(add_link_flag)

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

# -- Add warning flags
# --- Error on warnings, and enable all
if(USING_MSVC)
  add_comp_flag(${tgt} /W3)
  add_comp_flag(${tgt} /WX)
else()
  add_comp_flag(${tgt} -Wall)
  add_comp_flag(${tgt} -Werror)
  add_comp_flag(${tgt} -ffunction-sections)
  add_comp_flag(${tgt} -fdata-sections)
endif(USING_MSVC)

# -- Change default visibility on UNIX
if(NOT WIN32)
  add_comp_flag(${tgt} -fvisibility=hidden)
endif(NOT WIN32)

if(USE_CODE_COV)
  add_comp_flag(${tgt} -O0)
  add_comp_flag(${tgt} -fprofile-arcs)
  add_comp_flag(${tgt} -ftest-coverage)
  add_link_flag(${tgt} -fprofile-arcs)
  add_link_flag(${tgt} -ftest-coverage)
endif(USE_CODE_COV)

endfunction(add_exe)

# -- add_lib: Add library target (add_library mimic)
function(add_lib tgt)
  add_library(${ARGV})
  add_inc_dir(${tgt} ${PROJ_BASE_DIR})

# -- Add warning flags
# --- Error on warnings, and enable all
if(USING_MSVC)
  add_comp_flag(${tgt} /W3)
  add_comp_flag(${tgt} /WX)
else()
  add_comp_flag(${tgt} -Wall)
  add_comp_flag(${tgt} -Werror)
  add_comp_flag(${tgt} -ffunction-sections)
  add_comp_flag(${tgt} -fdata-sections)
endif(USING_MSVC)

# -- Change default visibility on UNIX
if(NOT WIN32)
  add_comp_flag(${tgt} -fvisibility=hidden)
endif(NOT WIN32)

if(USE_CODE_COV)
  add_comp_flag(${tgt} -O0)
  add_comp_flag(${tgt} -fprofile-arcs)
  add_comp_flag(${tgt} -ftest-coverage)
  add_link_flag(${tgt} -ftest-coverage)
endif(USE_CODE_COV)

endfunction(add_lib)

# -- add_lib_build_def: Add library compile definition
function(add_lib_build_def tgt buildSym)
  target_compile_definitions(${tgt} PUBLIC ${buildSym})
endfunction(add_lib_build_def)

# -- link_libs: Link to libraries (target_link_libraries mimic)
function(link_libs tgt)
    set(xtra_libs )
	
if (USE_CODE_COV)
  if (APPLE)
    add_link_flag(${tgt} --coverage)
  else()#UNIX
    set(xtra_libs gcov)
  endif()
endif()

if((NOT WIN32) AND (NOT USE_CODE_COV))
  if(USING_APPLE_CLANG)
    add_link_flag(${tgt} -dead_strip)
  else()#GCC like compiler
    add_link_flag(${tgt} -Wl,--gc-sections)
    add_link_flag(${tgt} -Wl,--as-needed)
  endif()
endif()

  target_link_libraries(${ARGV} ${xtra_libs})
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
    add_link_flag(${tgt} --coverage)
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
  foreach(file ${ARGV})
    get_filename_component(parent_dir ${file} DIRECTORY)
    install(FILES ${file} DESTINATION ${relpath}/${parent_dir})
  endforeach()
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
  add_custom_target("${submod_name}.hdr" ALL SOURCES ${ARGN})
endfunction(add_hdrs_ide)

# -- add_hdrs_tgt_ide: Add headers to IDE
function(add_hdrs_tgt_ide tgt_name)
  add_custom_target("${tgt_name}.hdr" ALL SOURCES ${ARGN})
endfunction(add_hdrs_tgt_ide)

# -- add_test_exe: Add test executable
function(add_test_exe testname filename)
  ## deal with normal test
  add_exe(${ARGV})
  
  # On Windows, the custom build detects the "ERROR" word in the
  # output and fails a passing test. We simply detect on the executable's
  # return code to detect failure.
  if(USING_MSVC AND ((${testname} STREQUAL "test_unittest") OR (${testname} STREQUAL "test_cppunittest")))
    add_custom_command(TARGET ${testname} POST_BUILD COMMAND ${testname} 2>nul)
  else()
    add_custom_command(TARGET ${testname} POST_BUILD COMMAND ${testname})
  endif()

  add_inc_dir(${testname} ${CMAKE_SOURCE_DIR}/unittest)
  add_test(${testname} ${testname})
  add_dependencies(check ${testname})

  # deal with test on install
  # copy file to temp folder
  set(test_dirname "${testname}.toi")
  message("-- TOI: Adding test for ${testname} in dir ${test_dirname}")
  
  # copy the file over
  file(MAKE_DIRECTORY ${test_dirname})
  file(COPY ${filename} DESTINATION ${test_dirname})

  set(install_test_args ${ARGV})
  list(REMOVE_AT install_test_args 0)
  list(INSERT install_test_args 0 "${testname}_install")
  
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
      "add_executable(${install_test_args})\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "add_dependencies(${testname}_install install_for_check_done)\n")
    file(APPEND ${test_dirname}/CMakeLists.txt
      "add_inc_dir(${testname}_install ${CMAKE_SOURCE_DIR}/unittest)\n")
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
    if(USING_MSVC AND ((${testname} STREQUAL "test_unittest") OR (${testname} STREQUAL "test_cppunittest")))
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
    if (WIN32)
      set(cd_cmd "cd /d")
    else()
      set(cd_cmd "cd")
    endif()
    
    include("cmake/CodeCoverage.cmake")
    
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
        POST_BUILD COMMAND echo "View the report: `pwd`/coverage/index.html")
    add_custom_target(code_cov DEPENDS check.cov.done)
  endif()
