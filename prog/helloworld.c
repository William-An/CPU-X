/**
 * A HelloWorld program that lights up LED segments
 * on AX301 FPGA development board
*/
#include <stdint.h>

// This is with active high mapping
const uint8_t seven_seg_digits_decode_gfedcba[75]= {
/*  0     1     2     3     4     5     6     7     8     9     :     ;     */
    0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x00, 0x00, 
/*  <     =     >     ?     @     A     B     C     D     E     F     G     */
    0x00, 0x00, 0x00, 0x00, 0x00, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71, 0x3D, 
/*  H     I     J     K     L     M     N     O     P     Q     R     S     */
    0x76, 0x30, 0x1E, 0x75, 0x38, 0x55, 0x54, 0x5C, 0x73, 0x67, 0x50, 0x6D, 
/*  T     U     V     W     X     Y     Z     [     \     ]     ^     _     */
    0x78, 0x3E, 0x1C, 0x1D, 0x64, 0x6E, 0x5B, 0x00, 0x00, 0x00, 0x00, 0x00, 
/*  `     a     b     c     d     e     f     g     h     i     j     k     */
    0x00, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71, 0x3D, 0x76, 0x30, 0x1E, 0x75, 
/*  l     m     n     o     p     q     r     s     t     u     v     w     */
    0x38, 0x55, 0x54, 0x5C, 0x73, 0x67, 0x50, 0x6D, 0x78, 0x3E, 0x1C, 0x1D, 
/*  x     y     z     */
    0x64, 0x6E, 0x5B
};

#define AX301_SEGMENT_OUT 0x4000
#define AX301_SEGMENT_SEL 0x4001

void main(void) {
    uint8_t seg_map[] = {  
        ~seven_seg_digits_decode_gfedcba['R' - '0'],
        ~seven_seg_digits_decode_gfedcba['I' - '0'],
        ~seven_seg_digits_decode_gfedcba['S' - '0'],
        ~seven_seg_digits_decode_gfedcba['C' - '0'],
        ~seven_seg_digits_decode_gfedcba['V' - '0'],
        ~seven_seg_digits_decode_gfedcba['3' - '0'],
        ~seven_seg_digits_decode_gfedcba['2' - '0'],
        ~seven_seg_digits_decode_gfedcba['I' - '0'],
        ~seven_seg_digits_decode_gfedcba['=' - '0'],    // Space
        ~seven_seg_digits_decode_gfedcba['W' - '0'],
        ~seven_seg_digits_decode_gfedcba['A' - '0'],
        ~seven_seg_digits_decode_gfedcba['=' - '0'],    // Space
        ~seven_seg_digits_decode_gfedcba['H' - '0'],
        ~seven_seg_digits_decode_gfedcba['e' - '0'],
        ~seven_seg_digits_decode_gfedcba['l' - '0'],
        ~seven_seg_digits_decode_gfedcba['l' - '0'],
        ~seven_seg_digits_decode_gfedcba['o' - '0'],
        ~seven_seg_digits_decode_gfedcba['=' - '0'],    // Space
        ~seven_seg_digits_decode_gfedcba['W' - '0'],
        ~seven_seg_digits_decode_gfedcba['o' - '0'],
        ~seven_seg_digits_decode_gfedcba['r' - '0'],
        ~seven_seg_digits_decode_gfedcba['l' - '0'],
        ~seven_seg_digits_decode_gfedcba['d' - '0'],
        ~seven_seg_digits_decode_gfedcba['=' - '0'],    // Spave
    };
    volatile uint8_t *seg_out_reg = AX301_SEGMENT_OUT;
    volatile uint8_t *seg_sel_reg = AX301_SEGMENT_SEL;

    *seg_sel_reg = 0b111110;
    *seg_out_reg = 0b11001100;

    for(;;) {
        // Scroll through the entire segment table
        // int scroll_counter = 0;
        // int display_counter = 0;
        // int arr_length = sizeof(seg_map) / sizeof(seg_map[0]);
        // for (int offset = 0; offset < arr_length; offset++) {
        //     // Display 6 digitletter at a time
        //     while (scroll_counter < 1000) {
        //         for (int i = 0; i < 6; i++) {
        //             uint8_t sel = 0xFF & (~(1 << i));
        //             uint8_t data = seg_map[(i + offset) % arr_length];
        //             *seg_sel_reg = sel;
        //             *seg_out_reg = data;

        //             while (display_counter < 25)
        //                 display_counter++;
        //             display_counter = 0;
        //         }
        //         scroll_counter++;
        //     }
        //     scroll_counter = 0;
        // }
    }
}