/*
 * File name:	ax301_peripherals_pkg.svh
 * Created:	12/25/2022
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	AX301 FPGA development board peripherals types
*/

`ifndef __AX301_PERIPHERALS_PKG_SVH__
`define __AX301_PERIPHERALS_PKG_SVH__

package ax301_peripherals_pkg;

typedef struct packed {
    logic [7:0] segment;
    logic [5:0] sel;
} ax301_segment_ctrl;

endpackage

`endif // __AX301_PERIPHERALS_PKG_SVH__