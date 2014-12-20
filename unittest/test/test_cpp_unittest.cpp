#include "unittest.hpp"

class BasicTest
{
  public:
    CLS_TEST_RUN() {
        TEST_TRUE( true );
    }
};

class ExternalBasicTest
{
  public:
    CLS_TEST_RUN();

    bool always_true()  { return true;  }
    bool always_false() { return false; }
};

CLS_TEST_RUN_EXT(ExternalBasicTest) {
    TEST_TRUE( true );
    ASSERT_TRUE( always_true() );
    ASSERT_FALSE( always_false() );
}

REG_TEST_CLASS( BasicTest );
REG_TEST_CLASS( ExternalBasicTest );

CPP_TEST( Trivial ) {
    TEST_TRUE( true );
    TEST_FALSE( false );
}

CPP_TEST( Negative ) {
    TEST_TRUE( false );
    ASSERT_TRUE( *TEST_RET_VAL_PTR_NAME == false );
    *TEST_RET_VAL_PTR_NAME = true;
    TEST_FALSE( true );
    ASSERT_TRUE( *TEST_RET_VAL_PTR_NAME == false );
    *TEST_RET_VAL_PTR_NAME = true;
}
