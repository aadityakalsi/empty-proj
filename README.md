[empty-proj](http://aadityakalsi.github.io/empty-proj/) [![Build Status](https://travis-ci.org/aadityakalsi/empty-proj.svg?branch=master)](https://travis-ci.org/aadityakalsi/empty-proj)
==========

A simple C/C++ project scaffold. Uses CMake to allow new C and C++ projects to be easily integrated.

Comes built-in with support for:
* Unittest support for all platforms
* Code coverage on *NIX using ```lcov```. Can be installed using ```sudo apt-get install lcov``` or ```brew install lcov```
* Supports doxygen generation via the ```doc/``` directory.

To use this repo:

```
git clone https://github.com/aadityakalsi/empty-proj
```

To create a new C or C++ project, call ```clone```.

```
empty-proj/clone myNewProject
```

Typically, the source layout is:

```
+ project
|-+ include                       # all include files
|-+ src                           # all source files
|-+ test                          # all test files
|-+ doc                           # all doc tasks
|-+ tools                         # tools for the project
|-- CMakeLists.txt                # project CMakeLists.txt
|-- LICENSE|COPYING|LICENSE.txt   # license file
|-- README.txt                    # readme file
|-- appveyor.yml                  # for Windows CI
|-- .travis.yml                   # for Linux and Mac CI
|-- travis_setup                  # env setup for travis tests
|-~ unittest                      # internal: unittest header(s) for writing tests
|-~ cmake                         # internal: CMake tools
```

Then:

```
cd myNewProject
# regenerate CMake files
tools/regen [Debug|Release] [Generator]
# build using CMake
tools/build [Debug|Release]
# run code coverage
tools/codecov
# performance profile with valgrind - UNIX - starts kcachegrind or qcachegrind
tools/valproj exepath
# build using CMake and install on success
tools/install [Debug|Release]
# install using CMake and test on install
tools/test_on_install [Debug|Release]
# remove all non-source artifacts from directory
tools/clean
```

Source management is easier:

```
# create a new subdirectory - adds CMakeLists.txt
tools/createdir path
# create a new source file - automatically adds license as comments
tools/createsrc path
# create a new header file - automatically adds license and include guard
tools/createhdr path includegrd
# create a test file - automatically adds to test/CMakeLists.txt and creates file
tools/createtest path
# run update of documentation generation
tools/updatedoc
# run grep on source files
tools/findterm term

```

For the CMake module:

```
 ProjTools.cmake
 ---------------
 
 CMake module that is meant as a single include in your op level
 CMakeLists.txt.
 
 Before including this module, the following efinitions need to
 be in place in your main CMakeLists.txt file.
 
 Project structure:
 
 + project
 |
 |- CMakeLists.txt
 |- LICENSE.txt
 |- README.txt
 |+ cmake
 |+ module1
 |+ module2
 |...
 |+ unittest (Unittest header available for writing nittests)
 |
 
 Sample CMakeLists.txt file:
 
# CMakeLists.txt
# # -- This cmake file works only wth CMake >= 3.0
# cmake_minimum_required(VERSION 3.0)
# # -- Set the project versioning details
# set(PROJ_NAME <your_project_name>)
# project(${PROJ_NAME})
# set(PROJ_INSTALL_DIR <install_location>)
# set(CPACK_PACKAGE_VERSION "0.1.1")
# set(CPACK_PACKAGE_VERSION_MAJOR "0")
# set(CPACK_PACKAGE_VERSION_MINOR "1"))
# set(CPACK_PACKAGE_VERSION_PATCH "1")
# set(CPACK_PACKAGE_CONTACT <your_email>)
# # -- Set the license and readme file for your project
# set(PROJ_LICENSE_FILE <PROJ_LICENSE_FILE>)
# set(PROJ_README_FILE  <PROJ_README_FILE>)
# # -- Include this module
# set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
# set(USE_CPP )
# # -- Can also set USE_CPP11
# # -- Finally include this magic CMake file
# include(ProjTools)
# # -- Add targets below
# add_subdirectory(module1; module2)
# # -- Functions available
# projmsg(msg)                       # display a project message
# add_comp_flag(tgt def)             # add a compile flag at the end for target
# add_comp_def(tgt def)              # add a compile definition at the end for target
# add_link_flag(tgt flag)            # add a linker flag at the end for target
# add_inc_dir(tgt dir)               # add an include directory for target
# add_exe(tgt ...)                   # add_executable replacement
# add_lib(tgt ...)                   # add_library replacement
# link_libs(tgt ...)                 # target_link_libraries replacement
# add_lib_build_def(tgt buildSym)    # add a build symbol for shared library; does nothing for static library
# set_tgt_ver(tgt ...)               # sets the version for a target
# install_hdr(files)                 # set headers as export headers
# install_tgt(name)                  # install a given target
# add_hdrs_ide(files)                # add files to IDE target
#
# # -- Functions available for tests in tests, you should use:
# #    These enable test on install automatically.
# add_test_exe()                     # same as add_exe() but for tests
# test_link_libs()                   # same as link_libs() but for tests
# create_test()                      # add the target to the test list
```

[Hunter](http://github.com/ruslo/hunter) can also be used along with ```ProjTools.cmake``` to allow for better 3rd party build management.
