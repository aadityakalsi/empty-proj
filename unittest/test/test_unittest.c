/**
 * @file test_unittest.c
 * A tutorial and test for the unit-test framework
 */

#include <cutils/unittest/unittest.h>

/* ----------------------------------------------- */

/**
 * Test the basic function and ensure the passing test
 * succeeds
 */
TEST_FUNC( pass_test ) {
    TEST_TRUE( 1 );
    TEST_FALSE( 0 );
    ASSERT_FALSE( 0 );
    ASSERT_TRUE( 1 );
}

/* ----------------------------------------------- */

TEST_FUNC( fail_test_test_true ) {
    ASSERT_TRUE( *TEST_RET_VAL_PTR_NAME );
    TEST_TRUE( 0 );
    *TEST_RET_VAL_PTR_NAME = !(*TEST_RET_VAL_PTR_NAME);
}

TEST_FUNC( fail_test_test_false ) {
    ASSERT_TRUE( *TEST_RET_VAL_PTR_NAME );
    TEST_FALSE( 1 );
    *TEST_RET_VAL_PTR_NAME = !(*TEST_RET_VAL_PTR_NAME);
}

/* ----------------------------------------------- */


/* ----------------------------------------------- */

TEST_SETUP( test_case ) {
    static int bVal = false;
    return (void*) &bVal;
}

TEST_FUNC( test_case ) {
    int* data = (int*) testdata;
    ASSERT_FALSE( *data );
    *data = true;
    TEST_TRUE( *data );
}

TEST_CLEANUP( test_case ) {
    int* data = (int*) testdata;
    ASSERT_TRUE( *data );
}

/* ----------------------------------------------- */


/* ----------------------------------------------- */

void SetupTests(void) {
    REG_TEST( pass_test );
    REG_TEST( fail_test_test_true );
    REG_TEST( fail_test_test_false );
    REG_TEST_CASE( test_case );
}

/* ----------------------------------------------- */
