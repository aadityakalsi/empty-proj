
#include "unittest.h"
#include <exception>

#define REG_TEST_CLASS(x) \
  TEST_SETUP(x) { \
      static x inst; \
      return static_cast<void*>(&inst); \
  } \
  \
  TEST_FUNC(x) { \
      x* ptr_test = static_cast<x*>(testdata); \
      try { \
          ptr_test->run(TEST_RET_VAL_PTR_NAME); \
      } catch(const std::exception& e) { \
          ERROR_PRINT("Uncaught exception message:\n\t%s",e.what()); \
          *TEST_RET_VAL_PTR_NAME = false; \
      } catch(...) { \
          ERROR_PRINT("Uncaught throw."); \
          *TEST_RET_VAL_PTR_NAME = false; \
      } \
  } \
  \
  TEST_CLEANUP(x) { \
      ((x*)testdata)->~x(); \
  } \
  \
  int register_test_class##x(void) { \
      REG_TEST_CASE(x); \
      return 0; \
  } \
  \
  static const int cls_test_reg_##x = register_test_class##x()

#define CLS_TEST_RUN() \
  void run(int* TEST_RET_VAL_PTR_NAME)

#define CLS_TEST_RUN_EXT(x) \
  void x::run(int* TEST_RET_VAL_PTR_NAME)

#define CPP_TEST(x) \
  struct x { \
      CLS_TEST_RUN(); \
  }; \
  \
  REG_TEST_CLASS(x); \
  \
  CLS_TEST_RUN_EXT(x)

void SetupTests(void)
{
  //
  // Do nothing, as tests are added using static initializers.
  //
}
