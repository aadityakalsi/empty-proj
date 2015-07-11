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

Then:

```
cd myNewProject
tools/build [Debug/Release]
tools/codecov
tools/install
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
 #
 # # -- This cmake file works only wth CMake >= 2.8
 # cmake_minimum_required(VERSION 2.8)
 #
 # # -- Set the project versioning details
 # set(PROJ_NAME <your_project_name>)
 # project(${PROJ_NAME})
 # set(PROJ_INSTALL_DIR <install_location>)
 # set(CPACK_PACKAGE_VERSION "0.1.1")
 # set(CPACK_PACKAGE_VERSION_MAJOR "0")
 # set(CPACK_PACKAGE_VERSION_MINOR "1"))
 # set(CPACK_PACKAGE_VERSION_PATCH "1")
 # set(CPACK_PACKAGE_CONTACT <your_email>)
 #
 # # -- Set the license and readme file for your project
 # set(PROJ_LICENSE_FILE <PROJ_LICENSE_FILE>)
 # set(PROJ_README_FILE  <PROJ_README_FILE>)

 # # -- Include this module
 # set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} {CMAKE_CURRENT_SOURCE_DIR}/cmake)
 # set(USE_CPP )
 # # -- Can also set USE_CPP11
 #
 # # -- Finally include this magic CMake file
 # include(ProjTools)
 #
 # # -- Add targets below
 # add_subdirectory(module1; module2)
 #
 # # -- Functions available
 # add_inc_dir()
 # add_exe()
 # add_lib()
 # add_lib_build_def()
 # link_libs()
 # set_tgt_ver()
 # install_hdr()
 # install_tgt()
 # 
 # # -- Functions available for tests
 # In tests, you should use:
 # add_test_exe()
 # test_link_libs()
 # create_test()
 #
```

[Hunter](http://github.com/ruslo/hunter) can also be used along with ```ProjTools.cmake``` to allow for better 3rd party build management.
