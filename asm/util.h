/************************************************************
*
* @file:      util.h
* @author:    Weili An
* @email:     an107@purdue.edu
* @version:   v1.0.0
* @date:      12/27/2021
* @brief:     Utility macros for unit testing, inspired from
*             riscv-tests repo
*
************************************************************/

// Address to write the final test result, whether is zero (passed)
// or not (contains the failed test number)

#ifndef SPIKE
    #define RESULT_ADDR 0xAF0
#else
    // For spike simulator
    #define RESULT_ADDR tohost
#endif

#define TEST_BEGIN                                                          \
.section .text.init;                                                        \
.global _start;                                                             \
_start:

#define TEST_END                                                            \
test_end:                                                                   \
    unimp;                                                                  \

#define TESTNUM gp

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

#define INSERT_NOPS_0
#define INSERT_NOPS_1 nop; INSERT_NOPS_0
#define INSERT_NOPS_2 nop; INSERT_NOPS_1
#define INSERT_NOPS_3 nop; INSERT_NOPS_2
#define INSERT_NOPS_4 nop; INSERT_NOPS_3
#define INSERT_NOPS_5 nop; INSERT_NOPS_4
#define INSERT_NOPS_6 nop; INSERT_NOPS_5
#define INSERT_NOPS_7 nop; INSERT_NOPS_6
#define INSERT_NOPS_8 nop; INSERT_NOPS_7
#define INSERT_NOPS_9 nop; INSERT_NOPS_8
#define INSERT_NOPS_10 nop; INSERT_NOPS_9


#define TEST_CASE(test_num, result_reg, exp, code...)   \
test_ ## test_num:                                                          \
    code;                                                                   \
    li x7, exp;                                                             \
    li TESTNUM, test_num;                                                   \
    bne result_reg, x7, test_fail

// Test R-type op with different r1, r2, rd registers
#define TEST_RR_OP(test_num, op, exp, val1, val2)                           \
TEST_CASE(test_num, x6, exp,                                                \
    li x1, val1;                                                            \
    li x4, val2;                                                            \
    op x6, x1, x4;                                                          \
);

#define TEST_RR_OP_SRC1_EQ_DEST(test_num, op, exp, val1, val2)              \
TEST_CASE(test_num, x1, exp,                                                \
    li x1, val1;                                                            \
    li x4, val2;                                                            \
    op x1, x1, x4;                                                          \
);


#define TEST_RR_OP_SRC2_EQ_DEST(test_num, op, exp, val1, val2)              \
TEST_CASE(test_num, x4, exp,                                                \
    li x1, val1;                                                            \
    li x4, val2;                                                            \
    op x4, x1, x4;                                                          \
);


#define TEST_RR_OP_ALL_EQ(test_num, op, exp, val)                           \
TEST_CASE(test_num, x1, exp,                                                \
    li x1, val;                                                             \
    op x1, x1, x1;                                                          \
);

// Insert nops between src1 and src2 load and op to test if pipeline bypass works
#define TEST_RR_OP_SRC12_BYPASS(test_num, src1_nops, src2_nops, op, exp, val1, val2)   \
TEST_CASE(test_num, x6, exp,                                                    \
    li x1, val1;                                                                \
    INSERT_NOPS_ ## src1_nops                                                   \
    li x4, val2;                                                                \
    INSERT_NOPS_ ## src2_nops                                                   \
    op x6, x1, x4;                                                              \
);

#define TEST_RR_OP_SRC21_BYPASS(test_num, src1_nops, src2_nops, op, exp, val1, val2)   \
TEST_CASE(test_num, x6, exp,                                                    \
    li x4, val2;                                                                \
    INSERT_NOPS_ ## src2_nops                                                   \
    li x1, val1;                                                                \
    INSERT_NOPS_ ## src1_nops                                                   \
    op x6, x1, x4;                                                              \
);

#define TEST_RR_OP_DEST_BYPASS(test_num, num_nops, op, exp, val1, val2)     \
TEST_CASE(test_num, x6, exp,                                                \
    li x1, val1;                                                            \
    li x4, val2;                                                            \
    op x14, x1, x4;                                                         \
    INSERT_NOPS_ ## num_nops                                                \
    addi x6, x14, 0;                                                        \
    INSERT_NOPS_10; /* Wait long enough to avoid additional dest bypass */  \
);

#define TEST_RR_OP_ZERO_SRC1(test_num, op, exp, val)                        \
TEST_CASE(test_num, x6, exp,                                                \
    li x4, val;                                                             \
    op x6, x0, x4;                                                          \
);

#define TEST_RR_OP_ZERO_SRC2(test_num, op, exp, val)                        \
TEST_CASE(test_num, x6, exp,                                                \
    li x1, val;                                                             \
    op x6, x1, x0;                                                          \
);

#define TEST_RR_OP_ZERO_SRC12(test_num, op, exp)                            \
TEST_CASE(test_num, x6, exp,                                                \
    op x6, x0, x0;                                                          \
);


// TESTNUM: contains the failed test number
#define TEST_PASS_FAIL                                                      \
test_pass:                                                                  \
    li TESTNUM, 0x0;                                                        \
    la x4, RESULT_ADDR;                                                     \
    sw TESTNUM, 0(x4);                                                      \
    HALT_PROCESSOR;                                                         \
    j dead_loop;                                                            \
test_fail:                                                                  \
    la x4, RESULT_ADDR;                                                     \
    sw TESTNUM, 0(x4);                                                      \
    HALT_PROCESSOR                                                          \
dead_loop:                                                                  \
    WRITE_TOHOST                                                            \
    j dead_loop   

// Write special values to register to signal testbench to halt
#define HALT_PROCESSOR                                                      \
    li x30, 0xBEEFBEEF;                                                     \
    li x31, 0xBEEFBEEF;                                                     


// TODO Add the trap handler for spike?
#ifndef SPIKE
    #define WRITE_TOHOST
    #define RVTEST_DATA_BEGIN  
    #define RVTEST_DATA_END

#else
    #define WRITE_TOHOST                                                    \
    write_tohost:                                                           \
        sw TESTNUM, tohost, t5;                                             \
        j write_tohost;                                                     
                                                            
    #define RVTEST_DATA_BEGIN                                               \
            .pushsection .tohost,"aw",@progbits;                            \
            .align 6; .global tohost; tohost: .dword 0;                     \
            .align 6; .global fromhost; fromhost: .dword 0;                 \
            .popsection;                                                    \
            .align 4; .global begin_signature; begin_signature:
    #define RVTEST_DATA_END .align 4; .global end_signature; end_signature:

#endif
