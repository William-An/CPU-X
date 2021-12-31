/************************************************************
*
* @file:      util.h
* @author:    Weili An
* @email:     an107@purdue.edu
* @version:   v1.0.0
* @date:      12/27/2021
* @brief:     Utility macros for unit testing
*
************************************************************/

// Address to write the final test result, whether is zero (passed)
// or not (contains the failed test number)
#ifndef RESULT_ADDR
    #define RESULT_ADDR 0xAFF
#endif

#define TEST_BEGIN                                                          \
.global _start;                                                             \
_start:

#define TEST_END                                                            \
test_end:                                                                   \
    unimp;                                                                  \

#define INIT_XREG                                                           \
init_xreg:                                                                  \
    li x1, 0;                                                               \
    li x2, 0;                                                               \
    li x3, 0;                                                               \
    li x4, 0;                                                               \
    li x5, 0;                                                               \
    li x6, 0;                                                               \
    li x7, 0;                                                               \
    li x8, 0;                                                               \
    li x9, 0;                                                               \
    li x10, 0;                                                              \
    li x11, 0;                                                              \
    li x12, 0;                                                              \
    li x13, 0;                                                              \
    li x14, 0;                                                              \
    li x15, 0;                                                              \
    li x16, 0;                                                              \
    li x17, 0;                                                              \
    li x18, 0;                                                              \
    li x19, 0;                                                              \
    li x20, 0;                                                              \
    li x21, 0;                                                              \
    li x22, 0;                                                              \
    li x23, 0;                                                              \
    li x24, 0;                                                              \
    li x25, 0;                                                              \
    li x26, 0;                                                              \
    li x27, 0;                                                              \
    li x28, 0;                                                              \
    li x29, 0;                                                              \
    li x30, 0;                                                              \
    li x31, 0;

// Test R-type op with different r1, r2, rd registers
#define TEST_RR_OP(test_num, op, exp, val1, val2)                           \
test_ ## test_num:                                                          \
    li x1, val1;                                                            \
    li x4, val2;                                                            \
    li x3, test_num;                                                        \
    li x5, exp;                                                             \
    op x6, x1, x4;                                                          \
    bne x5, x6, test_fail

#define TEST_RR_OP_SRC1_EQ_DEST(test_num, op, exp, val1, val2)              \
test_ ## test_num:                                                          \
    li x1, val1;                                                            \
    li x4, val2;                                                            \
    li x3, test_num;                                                        \
    li x5, exp;                                                             \
    op x1, x1, x4;                                                          \
    bne x5, x1, test_fail

#define TEST_RR_OP_SRC2_EQ_DEST(test_num, op, exp, val1, val2)              \
test_ ## test_num:                                                          \
    li x1, val1;                                                            \
    li x4, val2;                                                            \
    li x3, test_num;                                                        \
    li x5, exp;                                                             \
    op x4, x1, x4;                                                          \
    bne x5, x4, test_fail

#define TEST_RR_OP_ALL_EQ(test_num, op, exp, val)                           \
test_ ## test_num:                                                          \
    li x1, val;                                                             \
    li x3, test_num;                                                        \
    li x5, exp;                                                             \
    op x1, x1, x1;                                                          \
    bne x5, x1, test_fail


// x3: contains the failed test number
#define TEST_PASS_FAIL                                                      \
test_pass:                                                                  \
    li x3, 0x0;                                                             \
    la x4, RESULT_ADDR;                                                     \
    sw x3, 0(x4);                                                           \
    HALT_PROCESSOR;                                                         \
    j dead_loop;                                                            \
test_fail:                                                                  \
    la x4, RESULT_ADDR;                                                     \
    sw x3, 0(x4);                                                           \
    HALT_PROCESSOR                                                          \
dead_loop:                                                                  \
    j dead_loop   

// Write special values to register to signal testbench to halt
#define HALT_PROCESSOR                                                      \
    li x30, 0xBEEFBEEF;                                                     \
    li x31, 0xBEEFBEEF;                                                     
