# unittest project

set(unittest_dirname unittest)

set(unittest_h unittest.h; unittest.hpp)

# -- Uncomment below to install the unittest header with installation
#    of this package
# install_hdr(${unittest_h})

# add the test subdirectory
add_subdirectory(test)
