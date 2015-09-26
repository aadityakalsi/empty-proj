# TEST: cutils unittest sub module

add_test_exe    (test_unittest test_unittest.c)
test_link_libs  (test_unittest )
create_test     (test_unittest)

add_test_exe    (test_cppunittest test_cpp_unittest.cpp)
test_link_libs  (test_cppunittest )
create_test     (test_cppunittest)
