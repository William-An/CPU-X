# Testing add

#include "util.h"

TEST_BEGIN

INIT_XREG

# TESTNUM, OP, EXP, SRC1, SRC2
TEST_RR_OP(1, add, 1, 0, 0);

TEST_PASS_FAIL

TEST_END