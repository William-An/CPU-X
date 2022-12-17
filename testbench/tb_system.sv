`timescale 1ns/1ns

`include "rv32ima_pkg.svh"

module tb_system;
    import rv32ima_pkg::*;
	
    localparam CLK_PERIOD = 10;
	localparam PC_INIT = 32'h80000000;
    logic tb_clk;
    logic tb_nrst;
    word_t tb_data;
    int unsigned tb_cycles;

    system #(.PC_INIT(PC_INIT)) dut(tb_clk, tb_nrst, tb_data);

    always #CLK_PERIOD tb_clk = ~tb_clk;

    initial begin
        tb_clk = 1'b0;
        tb_nrst = 1'b1;
        tb_cycles = 0;

        // Reset the device
        repeat (3) @(posedge tb_clk);
        tb_nrst = 1'b0;
        repeat (3) @(posedge tb_clk);
        tb_nrst = 1'b1;

        // Break on if x30 and x31 contains value 0xBEEFBEEF
        while (!(dut.dp0.rf0.rf[30] == 32'hbeefbeef && dut.dp0.rf0.rf[31] == 32'hbeefbeef)) begin
            @(posedge tb_clk);
            tb_cycles++;
        end
        $stop;
        // TODO Dump memory
    end
endmodule