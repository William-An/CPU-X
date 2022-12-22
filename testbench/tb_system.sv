`timescale 1ns/1ns

`include "rv32ima_pkg.svh"

module tb_system;
    import rv32ima_pkg::*;
	
    localparam CLK_PERIOD = 10;
    // localparam PC_INIT = 32'h80000000;
    localparam PC_INIT = -4;
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

        // Break on ecall and 50 clock cycles
        // Then check x3 register value
        // Break on if x30 and x31 contains value 0xBEEFBEEF
        while (!(dut.dp0.exceptionif0.dec_exception_event.ecall == 1'b1)) begin
            @(posedge tb_clk);
            tb_cycles++;
        end
        repeat (50) @(posedge tb_clk);
        if (dut.dp0.rf0.rf[3] == 32'd1) begin
            $display("All test passed!");
        end
        else begin
            $error("Test failed! Code: %d", dut.dp0.rf0.rf[3]);
        end
        $stop;

        // TODO tohost memory?
        // TODO Dump memory
    end
endmodule