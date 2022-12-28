/**
 * File name:	system.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.1 Use minibus for peripherals
 * Description:	Top-level entry for the CPU implementation
 */

`timescale 1ns / 100ps

`include "rv32ima_pkg.svh"
`include "datapath_if.svh"
`include "system_if.svh"
`include "cpu_ram_if.svh"
`include "minibus/minibus_pkg.svh"
`include "minibus/minibus_slave_if.svh"
`include "minibus/minibus_master_if.svh"

import rv32ima_pkg::*;

module system #(
	PC_INIT=-4
)
(
	input clk,
	input nrst,
	system_if.system _if
);

	datapath_if dpif(clk, nrst);
	minibus_master_if cpuif(
		.clk(clk),
		.nrst(nrst)
	);

	localparam SLAVE_DEVICE_COUNT = 1;
	localparam slave_mem_map ram_memmap = '{0, 'h4000};
	localparam slave_mem_map [SLAVE_DEVICE_COUNT - 1:0] slave_dev_mmap = {ram_memmap};
	minibus_slave_if slave_dev_ifs [SLAVE_DEVICE_COUNT](.clk(clk), .nrst(nrst));
	
	// Connecting ram signals to system
	always_comb begin
		_if.ram_load	= slave_dev_ifs[0].res.rdata;
		_if.ram_store	= slave_dev_ifs[0].req.wdata;
		_if.ram_addr	= slave_dev_ifs[0].req.addr;
		_if.ram_ren		= slave_dev_ifs[0].req.ren;
		_if.ram_wen		= slave_dev_ifs[0].req.wen;
	end

	// Decoder/Minibus hub
	minibus_decoder #(.SLAVE_COUNT(SLAVE_DEVICE_COUNT)) minibus_dec0(
		._masterif(cpuif),
		._slaveifs(slave_dev_ifs),
		.slavemmaps(slave_dev_mmap));

	// Modules
	datapath #(.PC_INIT(PC_INIT)) dp0(dpif);
	
	// Memory controller/arbiter
	// TODO: extend to a memory bus controller?
	memory_controller_minibus mc(dpif, cpuif);

	// Onchip ram, for offchip, initialize an offchip mem controller?
	ram_minibus ram0(slave_dev_ifs[0]);

endmodule