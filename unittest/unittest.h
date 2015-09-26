/**
 * @file unittest.h
 * Definitions for writing unit test C/CPP files
 *
 * Writing unittests:
 * ------------------
 * ------------------
 *
 * The only convention is to use a name for a test consistently in the
 * test source file.
 *
 * Writing "simple" tests:
 * -----------------------
 *
 * \code{.c}
 *
 * TEST_FUNC( MyTestName ) {
 *     // if a test setup function was used,
 *     // its return value is available as
 *     // value of the input variable "testdata"
 *     // which is otherwise, NULL.
 *
 *     mySetupData* p = (mySetupData*)testdata;
 *     TEST_TRUE( 1 );
 *     TEST_FALSE( 1 ); // Prints error message and ensures test fails
 *     ASSERT_FALSE( 1 ); // We now abort because, tl; dw
 *     // ASSERT_TRUE is available also
 * }
 *
 * \endcode
 *
 * You may optionally add test setup and cleanup
 * functions as shown below. Note that the same test name
 * is used as before to give a complete example.
 *
 * \code{.c}
 *
 * TEST_SETUP( MyTestName ) {
 *     static mySetupData data;
 *     SomeInitFunction(&data);
 *     return (void*)&data;
 * }
 *
 * TEST_CLEANUP( MyTestName ) {
 *     // testdata implicitly available.
 *     mySetupData* myData = (mySetupData*)testdata;
 *     SomeDestroyFunction(myData);
 * }
 *
 * \endcode
 *
 * The SetupTests function.
 * ------------------------
 *
 * This function must be defined in every unit test source file
 * where the calls to REG_TEST or REG_TEST_CASE will be made, and you
 * can optionally add static state for your tests.
 *
 * \code{.c}
 *
 * void SetupTests(void) {
 *     REG_TEST( MyTestName ); // If just using a simple test
 *     REG_TEST_CASE( MyTestName ); // With setup/cleanup we register a test case
 * }
 *
 * \endcode
 *
 * For a full example, see:
 *
 * \include unittest/test/test_unittest.c
 *
 */

#ifndef PROJ_UNITTEST_UNITTEST_H
#define PROJ_UNITTEST_UNITTEST_H


#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#define ERR_STRM stderr

const char* EXE_NAME = NULL;

/* --- Test function types --- */

/**
 * Expected function signatures for the test case components.
 */

/**
 * TestSetupFunc.
 *
 * This function is expected to return a void pointer that points to the data
 * that may be useful for the test function, and must be cleaned up with
 * the cleanup function.
 */
typedef void* (*TestSetupFunc)(void) ;

/* --- Macros to use in tests --- */

/**
 * This variable name is used by the test framework in the test function.
 * @note Avoid using this variable name in test functions.
 */
#define TEST_RET_VAL_PTR_NAME p_test_ret_val_

/**
 * TestFunc.
 *
 * This function takes the test data returned by the test setup
 * function and sets the int* value to false if the test failed.
 *
 * If there is no setup function, i.e. for a simple REG_TEST,
 * then the first input will be NULL
 *
 *
 */
typedef void (*TestFunc)(void*,int*);

/**
 * TestClnupFunc
 *
 * This function takes the test data returned by the test setup
 * function, after it may be possibly modified by the test function,
 * and performs resource cleanup and/or other tasks to complete the test.
 */
typedef void (*TestClnupFunc)(void*);

/* ------------------------------ */

static const double BAD_TIME = -1.0;

/* (No Doxygen)
 * TimeCacheOper
 * Contains operations that can be performed by the
 * TimeCache function.
 *   - TIC op: Resets the timer to 0.
 *   - TOC op: Records the time elapsed between the previous toc op.
 */
enum TimeCacheOper {
    START_OP = 0,
    STOP_OP  = 1
};

typedef enum TimeCacheOper TimeCacheOp;

#if !defined(_WIN32)

/* (No Doxygen)
 * Cache the current time when op is TIC_OP,
 * and return the time elapsed since last cache
 * when op is TOC_OP
 */
static double TimeCache(TimeCacheOp op) {
    static clock_t start;
    static clock_t end;
    switch (op) {
      case START_OP:
        start = clock();
        return BAD_TIME;
      case STOP_OP:
        end = clock();
        return (double)(end-start) / CLOCKS_PER_SEC;
    }
    return BAD_TIME;
}

#else // Windows

#include <Windows.h>

double  PCFreq = 0.0;
__int64 CounterStart = 0;
static void InitPCFreq(void) {
    LARGE_INTEGER li;
    QueryPerformanceFrequency(&li);
    PCFreq = (double)(li.QuadPart);
}
static void StartCounter(void) {
    LARGE_INTEGER li;
    QueryPerformanceCounter(&li);
    CounterStart = li.QuadPart;
}
static double GetCounter(void) {
    LARGE_INTEGER li;
    QueryPerformanceCounter(&li);
    return (double)(li.QuadPart - CounterStart) / PCFreq;
}

/* (No Doxygen)
 * Cache the current time when op is TIC_OP,
 * and return the time elapsed since last cache
 * when op is TOC_OP
 */
static double TimeCache(TimeCacheOp op) {
    static int dummy_ = -1;
    if (dummy_ == -1) {
        InitPCFreq();
        dummy_ = 0;
    }
    switch (op) {
    case START_OP:
        StartCounter();
        return BAD_TIME;
    case STOP_OP:
        return GetCounter();
    }
    return BAD_TIME;
}

#endif

/* ------------------  MACROS FOR PRINTING -------------------- */
#ifndef _WIN32
#define RESET   "\033[0m"
#define BLACK   "\033[30m"      /* Black */
#define RED     "\033[31m"      /* Red */
#define GREEN   "\033[32m"      /* Green */
#define BLUE    "\033[34m"      /* Blue */
#define WHITE   "\033[37m"      /* White */
#define BOLDBLACK   "\033[1m\033[30m"      /* Bold Black */
#define BOLDRED     "\033[1m\033[31m"      /* Bold Red */
#define BOLDGREEN   "\033[1m\033[32m"      /* Bold Green */
#define BOLDWHITE   "\033[1m\033[37m"      /* Bold White */
#endif

/* Debug printing is always on */
#define DEBUG_PRINT_ON 1

#if defined(_WIN32)

#define FOREGROUND_WHITE 15

/**
 * Print debugging info. Only prints if DEBUG_ON is defined
 * before including this header file.
 */
#define DEBUG_PRINT(fmt, ...) \
do { \
    printf(fmt, ##__VA_ARGS__); \
} while(0)

/**
 * Print to standard error.
 */
#define ERROR_PRINT(fmt, ...) \
do { \
    HANDLE hConsole; \
    hConsole = GetStdHandle(STD_ERROR_HANDLE); \
    SetConsoleTextAttribute(hConsole, FOREGROUND_RED); \
    fprintf(ERR_STRM, "ERROR: "); \
    fflush(stderr); \
    SetConsoleTextAttribute(hConsole, FOREGROUND_WHITE); \
    fprintf(ERR_STRM, fmt, ##__VA_ARGS__); \
} while(0)

/**
 * Test passed.
 */
#define TEST_PASSED_PRINT(testName, timeTaken) \
do { \
    HANDLE hConsole; \
    hConsole = GetStdHandle(STD_OUTPUT_HANDLE); \
    printf("Test passed:\t"); \
    SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN); \
    printf("'%s'", (testName)); \
    fflush(stdout); \
    SetConsoleTextAttribute(hConsole, FOREGROUND_WHITE); \
    printf("\t %f sec\n", (timeTaken)); \
} while(0)

/**
 * Test failed.
 */
#define TEST_FAILED_PRINT(testName) \
do { \
    HANDLE hConsole; \
    hConsole = GetStdHandle(STD_OUTPUT_HANDLE); \
    printf("Failed    :\t"); \
    SetConsoleTextAttribute(hConsole, FOREGROUND_RED); \
    printf("'%s'", (testName)); \
    fflush(stdout); \
    SetConsoleTextAttribute(hConsole, FOREGROUND_WHITE); \
} while(0)

#else/*UNIX*/

/**
 * Print debugging info. Only prints if DEBUG_ON is defined
 * before including this header file.
 */
#define DEBUG_PRINT(fmt, ...) \
do { \
    printf(fmt, ##__VA_ARGS__); \
} while(0)

/**
 * Print to standard error.
 */
#define ERROR_PRINT(fmt, ...) \
do { \
    fprintf(ERR_STRM, RED "ERROR: " RESET fmt, ##__VA_ARGS__); \
} while(0)

/**
 * Test passed.
 */
#define TEST_PASSED_PRINT(testName, timeTaken) \
do { \
    printf("Test passed:\t" GREEN "'%s'" RESET "\t %f sec\n", (testName), (timeTaken)); \
} while(0)

/**
 * Test failed.
 */
#define TEST_FAILED_PRINT(testName) \
do { \
    printf("Failed    :\t" RED "'%s'" RESET"\n\n", (testName)); \
} while(0)

#endif


/* ----------------------------------------------------------- */


static
int RunTest(const char* testname,
            TestSetupFunc testsetupfn,
            TestFunc testfn,
            TestClnupFunc testcleanupfn) {
    int retval = 1;
    void* testdata = NULL;
    double timeTaken = -1.0;

    if (testsetupfn) {
        DEBUG_PRINT("Test setup:\t'%s'\n", testname);
        testdata = testsetupfn();
    }


    TimeCache(START_OP);
    testfn(testdata, &retval);
    timeTaken = TimeCache(STOP_OP);

    if (retval) {
        TEST_PASSED_PRINT(testname, timeTaken);
    }

    if (testcleanupfn) {
        DEBUG_PRINT("Test cleanup:\t'%s'\n", testname);
        testcleanupfn(testdata);
    }

    if (retval) {
        DEBUG_PRINT("Successful:\t'%s'\n\n", testname);
    } else {
        TEST_FAILED_PRINT(testname);
    }
    return retval;
}



/**
 * TEST_TRUE
 * Tests a condition in a test.
 *  - does nothing if the test condition is true
 *  - prints to standard error and returns from the
 *    test function if the condition is false.
 */
#define TEST_TRUE(expr) \
do { \
    if(!(expr)) { \
        ERROR_PRINT("Condition '%s' failed in file '%s:%d' in function '%s'.\n", #expr, __FILE__, __LINE__, __FUNCTION__); \
        *(TEST_RET_VAL_PTR_NAME) = 0; \
    } \
} while(0)

/**
 * TEST_FALSE
 * Tests a condition in a test.
 *  - does nothing if the test condition is false
 *  - prints to standard error and returns from the
 *    test function if the condition is true.
 */
#define TEST_FALSE(expr) TEST_TRUE(!(expr))

/**
 * ASSERT_TRUE
 * Asserts a condition in a test.
 *  - does nothing if the test condition is true
 *  - prints to standard error and exits with failure
 */
#define ASSERT_TRUE(expr) \
do { \
    if(!(expr)) { \
        ERROR_PRINT("Condition '%s' failed at file '%s:%d' in function '%s'.\n", #expr, __FILE__, __LINE__, __FUNCTION__); \
        fflush(ERR_STRM); \
        exit(1); \
    } \
} while(0)

/**
 * ASSERT_FALSE
 * Asserts a condition in a test.
 *  - does nothing if the test condition is false
 *  - prints to standard error and exits with failure
 */
#define ASSERT_FALSE(expr) ASSERT_TRUE(!(expr))

/**
 * FILTER_IF
 * Skip remaining test if the filter is true.
 */
#define FILTER_IF(cond) return

/* ------------------------------ */


/* --- Add main and ADD_TEST* --- */

struct cusr_testcase_t {
    const char*     test_name_  ;
    TestSetupFunc   test_setup_ ;
    TestFunc        test_func_  ;
    TestClnupFunc   test_clnup_ ;
};

typedef struct cusr_testcase_t testcase_t;

/**
 * If you have more than 512 tests (consider writing a new file?)
 * or just define MAX_TESTS in your .c file before the include
 * of unittest
 */
#ifndef MAX_TESTS
#define MAX_TESTS 512
#endif

static testcase_t TESTS_[MAX_TESTS];
static int        CURR_TEST_ = 0;


/**
 * Macro to define test setup
 */
#define TEST_SETUP(name) \
void* test_setup_##name(void)

/**
 * Macro to define test function
 */
#define TEST_FUNC(name) \
void  test_func_##name(void* testdata, int* TEST_RET_VAL_PTR_NAME)

/**
 * Macro to define test cleanup
 */
#define TEST_CLEANUP(name) \
void  test_clnup_##name(void* testdata)

/**
 * Macro to register a simple test for the framework.
 * Simple tests do not have a setup and cleanup function.
 */
#define REG_TEST(name) \
do { \
    TESTS_[CURR_TEST_].test_name_  = #name; \
    TESTS_[CURR_TEST_].test_setup_ = NULL; \
    TESTS_[CURR_TEST_].test_func_  = test_func_##name; \
    TESTS_[CURR_TEST_].test_clnup_ = NULL; \
    CURR_TEST_++; \
} while(0)

/**
 * REG_TEST_CASE
 *
 * Macro to define a test case with setup, test, cleanup
 * functions being used.
 */
#define REG_TEST_CASE(name) \
do { \
    TESTS_[CURR_TEST_].test_name_  = #name; \
    TESTS_[CURR_TEST_].test_setup_ = test_setup_##name; \
    TESTS_[CURR_TEST_].test_func_  = test_func_##name; \
    TESTS_[CURR_TEST_].test_clnup_ = test_clnup_##name; \
    CURR_TEST_++; \
} while(0)


/**
 * Every test file must have a SetupTests function
 * which calls REG_TEST/REG_TEST_CASE for the required
 * tests
 */
extern void SetupTests();


/* (No Doxygen)
 * Main function for test file
 * Returns process exit code 0 on success
 * and non-zero on failure
 */
int main(int argc, const char* argv[]) {
    int allPassed = 1;
    int tidx = 0;
    int currPassed = 0;
#if defined(_WIN32)
    // Initialize color attributes
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_WHITE);
    SetConsoleTextAttribute(GetStdHandle(STD_ERROR_HANDLE), FOREGROUND_WHITE);
#endif

    EXE_NAME = argv[0];

    SetupTests();
    ASSERT_TRUE(CURR_TEST_ < MAX_TESTS);
    for(; tidx < CURR_TEST_; ++tidx) {
        /* a test could abort with asserts */
         DEBUG_PRINT("Running test\n");
         currPassed = RunTest(
                        TESTS_[tidx].test_name_,
                        TESTS_[tidx].test_setup_,
                        TESTS_[tidx].test_func_,
                        TESTS_[tidx].test_clnup_);
         allPassed &= currPassed;
         if (currPassed) {
             DEBUG_PRINT("Re-running test to ensure pass on rerun\n");
             allPassed &= RunTest(
                            TESTS_[tidx].test_name_,
                            TESTS_[tidx].test_setup_,
                            TESTS_[tidx].test_func_,
                            TESTS_[tidx].test_clnup_);	 
         }
    }
    return allPassed ? 0 : 1;
}

/* ------------------------------ */

#endif/*PROJ_UNITTEST_UNITTEST_H*/
