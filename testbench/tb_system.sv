`timescale 1ns/1ns

`include "rv32ima_pkg.svh"
`include "system_if.svh"

module tb_system;
    import rv32ima_pkg::*;
	
    localparam CLK_PERIOD = 10;
    localparam PC_INIT = -4;
    localparam TO_HOST_ADDR = 32'h1000;
    logic tb_clk;
    logic tb_nrst;
    word_t tb_data;
    int unsigned tb_cycles;

    word_t tb_ram_addr;
    word_t tb_ram_store;
    word_t tb_ram_load;
    logic  tb_ram_ren;
    logic  tb_ram_wen;
    logic[1:0] tb_ram_state;

    system_if tb_sysif0();

    // TODO Separate MAPPED and RTL simulation
    // # In gate-level synthesis, it loses information on the signal names
    // system #(.PC_INIT(PC_INIT)) dut(tb_clk, tb_nrst, tb_data);
`ifdef MAPPED
    system dut(tb_clk, tb_nrst, 
                tb_sysif0.ram_wen, 
                tb_sysif0.ram_ren,
                tb_sysif0.ram_addr, 
                tb_sysif0.ram_state, 
                tb_sysif0.ram_store, 
                tb_sysif0.ram_load);
`else
    system #(.PC_INIT(PC_INIT)) dut(tb_clk, tb_nrst, tb_sysif0);
`endif

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

        // Listen on TOHOST memory region
        while ((tb_sysif0.ram_addr != TO_HOST_ADDR) || (tb_sysif0.ram_wen != 1'b1)) begin
            @(posedge tb_clk);
            tb_cycles++;
        end

        // Read the RAM store value
        if (tb_sysif0.ram_store == 32'd1) begin
            $display("All test passed!");
        end
        else begin
            $error("Test failed! Code: %d Test case: %d", tb_sysif0.ram_store, tb_sysif0.ram_store >> 1);
        end
        $stop;

        // TODO Dump memory
    end
endmodule