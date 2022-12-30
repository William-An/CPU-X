/**
 * File name:	ax301_segment_display.svh
 * Created:	12/26/2022
 * Author:	Weili An
 * Email:	an107@purdue.eduu
 * Version:	1.0 Initial Design Entry
 * Description: ax301 digital led segment display with minibus interface
 */

`include "minibus/minibus_pkg.svh"
`include "ax301_peripherals/ax301_peripherals_pkg.svh"
`include "minibus/minibus_slave_if.svh"


module ax301_segment_display (
    minibus_slave_if.slave _sif,
    output ax301_peripherals_pkg::ax301_segment_ctrl seg_ctrl
);
    import ax301_peripherals_pkg::*;
    
    logic [0:0][DATA_WIDTH - 1:0] reg_out;
    minibus_slave_regs #(.REGS_COUNT(1)) regs(_sif, reg_out);

    assign seg_ctrl.sel = reg_out[0][13:8];
    assign seg_ctrl.segment = reg_out[0][7:0];
    
endmodule