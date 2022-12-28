/**
 * File name:	system_fpga.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	FPGA wrapper for the full system design
 */

module system_fpga (
    input clk,      // 50 Mhz
    input nrst,
    output logic[7:0] seg_data,
    output logic[5:0] seg_sel
);

    localparam PC_INIT = -4;
    system_if syif();

    // First reduce the clock frequency to 25 MHz for single cycle CPU
    logic cpu_clk;
    always_ff @(posedge clk, negedge nrst) begin
        if (nrst == 1'b0)
            cpu_clk <= 1'b0;
        else
            cpu_clk <= ~cpu_clk;
    end
    
    // Placeholder for peripherals
    always_comb begin
        seg_data = syif.seg_ctrl.segment;
        seg_sel = syif.seg_ctrl.sel;
    end

    system #(.PC_INIT(PC_INIT)) core(cpu_clk, nrst, syif);

endmodule