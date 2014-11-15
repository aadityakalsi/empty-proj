# unittest project

set(unittest_dirname unittest)

set(unittest_h unittest.h)

install_hdr(${unittest_h})

# add the test subdirectory
add_subdirectory(test)
