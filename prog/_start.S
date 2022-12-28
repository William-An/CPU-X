.section .text.init;
.align  6;
.weak stvec_handler;
.weak mtvec_handler;

.globl _start;
_start:
    /* reset vector */
    j reset_vector;
    .align 2;

reset_vector:
    // Reset sp
    li sp, 0x4000;
    j main