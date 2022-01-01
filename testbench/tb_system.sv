`timescale 1ns/1ns

`include "rv32ima_pkg.svh"

module tb_system;
    import rv32ima_pkg::*;
	
    localparam CLK_PERIOD = 10;
    logic tb_clk;
    logic tb_nrst;
    word_t tb_data;

    system dut(tb_clk, tb_nrst, tb_data);

    always #CLK_PERIOD tb_clk = ~tb_clk;

    initial begin
        tb_clk = 1'b0;
        tb_nrst = 1'b1;

        repeat (3) @(posedge tb_clk);
        tb_nrst = 1'b0;
        repeat (3) @(posedge tb_clk);
        tb_nrst = 1'b1;
        repeat (3) @(posedge tb_clk);

        repeat (100) @(posedge tb_clk);
        $stop;
        // TODO Break on if x30 and x31 contains value 0xBEEFBEEF
    end
endmodule