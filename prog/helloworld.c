// TODO: Write a program to light up led segment
#define AX301_SEGMENT_OUT 0x4000
#define AX301_SEGMENT_SEL 0x4001
#include <stdint.h>

void main(void) {
    uint8_t digit = 0b11111110;
    uint8_t sel = 0b111110;
    volatile uint8_t *seg_out_reg = AX301_SEGMENT_OUT;
    volatile uint8_t *seg_sel_reg = AX301_SEGMENT_SEL;

    int count = 0;
    for(;;) {
        *seg_out_reg = digit;
        *seg_sel_reg = sel;
        // Delay func
        while (count < 25000000)
            count++;
        count = 0;

        // Shift the digit select
        sel <<= 1;
        sel |= 0b000001;
        if (sel == 0b111111)
            sel = 0b111110;
    }
}