`timescale 1ns/1ns

`include "rv32ima_pkg.svh"
`include "system_if.svh"
`include "minibus/minibus_pkg.svh"
`include "minibus/minibus_slave_if.svh"
`include "minibus/minibus_master_if.svh"

import minibus_pkg::*;
import ax301_peripherals_pkg::*;

// TODO
module tb_minibus;
    localparam CLK_PERIOD = 10;
    logic tb_clk, tb_nrst;
    ax301_segment_ctrl tb_seg_ctrl;
	minibus_master_if tb_msif(
		.clk(tb_clk),
		.nrst(tb_nrst)
	);

    // Initialize memory mapping
	localparam SLAVE_DEVICE_COUNT = 2;
	localparam slave_mem_map ram_memmap = '{0, 'h4000};
	localparam slave_mem_map segment_memmap = '{'h4000, 'h4004};
	localparam slave_mem_map slave_dev_mmap [SLAVE_DEVICE_COUNT] = '{ram_memmap, segment_memmap};
	minibus_slave_if slave_dev_ifs [SLAVE_DEVICE_COUNT](.clk(tb_clk), .nrst(tb_nrst));

    // Decoder/Minibus hub
	minibus_decoder #(.SLAVE_COUNT(SLAVE_DEVICE_COUNT), .SLAVEMMAPS(slave_dev_mmap)) minibus_dec0(
		._masterif(tb_msif),
		._slaveifs(slave_dev_ifs));

    ram_minibus ram0(slave_dev_ifs[0]);
	ax301_segment_display seg_disp(slave_dev_ifs[1], tb_seg_ctrl);

    always #CLK_PERIOD tb_clk = ~tb_clk;

    task reset_dut;
        begin
        // Activate the reset
        tb_nrst = 1'b0;

        // Maintain the reset for more than one cycle
        @(posedge tb_clk);
        @(posedge tb_clk);

        // Wait until safely away from rising edge of the clock before releasing
        @(negedge tb_clk);
        tb_nrst = 1'b1;

        // Leave out of reset for a couple cycles before allowing other stimulus
        // Wait for negative clock edges, 
        // since inputs to DUT should normally be applied away from rising clock edges
        @(negedge tb_clk);
        @(negedge tb_clk);
        end
    endtask

    // TODO
    task set_buswrite;
        input [31:0] address;
        input [1:0]  width;
        input [31:0] data;
    begin
        tb_msif.req.addr = address;
        tb_msif.req.width = width;
        tb_msif.req.wdata = data;
        tb_msif.req.ren = 1'b0;
        tb_msif.req.wen = 1'b1;
    end
    endtask

    // TODO
    task set_busread;
        input [31:0] address;
        input [1:0]  width;
        input [31:0] exp_data;
    begin
        tb_msif.req.addr = address;
        tb_msif.req.width = width;
        tb_msif.req.wdata = exp_data;
        tb_msif.req.ren = 1'b1;
        tb_msif.req.wen = 1'b0;
    end
    endtask

    task perform_transcation;
        input logic isRead;
    begin
        @(posedge tb_msif.res.ack);
        tb_msif.req.ren = 1'b0;
        tb_msif.req.wen = 1'b0;
        
        @(posedge tb_clk);
    end
    endtask

    initial begin
        tb_clk = 1'b0;
        reset_dut();

        set_buswrite('h4000, 2'b10, 32'h12345678);
        perform_transcation(1'b0);
        set_busread('h4000, 2'b10, 32'h12345678);
        perform_transcation(1'b1);
        set_buswrite('h0000, 2'b10, 32'hbeefbeef);
        perform_transcation(1'b0);
        set_busread('h0000, 2'b10, 32'hbeefbeef);
        perform_transcation(1'b1);

        $stop;
    end
endmodule
