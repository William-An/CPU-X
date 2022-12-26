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

	minibus_slave_if ramif(
		.clk(clk),
		.nrst(nrst)
	);


	// Connecting ram signals to system
	always_comb begin
		_if.ram_load	= ramif.res.rdata;
		_if.ram_store	= ramif.req.wdata;
		_if.ram_addr	= ramif.req.addr;
		_if.ram_ren		= ramif.req.ren;
		_if.ram_wen		= ramif.req.wen;
	end

	// Single connection, no decoder needed
	always_comb begin
		ramif.req = cpuif.req;
		ramif.sel = 1'b1;
		cpuif.res = ramif.res;
	end

	// Modules
	datapath #(.PC_INIT(PC_INIT)) dp0(dpif);
	
	// Memory controller/arbiter
	// TODO: extend to a memory bus controller?
	memory_controller_minibus mc(dpif, cpuif);

	// Onchip ram, for offchip, initialize an offchip mem controller?
	ram_minibus ram0(ramif);

endmodule