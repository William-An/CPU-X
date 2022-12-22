/**
 * File name:	system.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
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
	
	// Testing synthesis size
	logic cpu_clk;
	always_ff @( posedge clk, negedge nrst ) begin : CPU_CLK
		if (nrst == 1'b0)
			cpu_clk <= 1'b0;
		else
			cpu_clk <= ~cpu_clk;
	end

	datapath_if dpif(cpu_clk, nrst);
	cpu_ram_if	crif(
		.ram_clk(clk),
		.nrst(nrst)
	);

	// Connecting ram signals to system
	always_comb begin
		_if.ram_load	= crif.ram_load;
		_if.ram_store	= crif.ram_store;
		_if.ram_state	= crif.ram_state;
		_if.ram_addr	= crif.ram_addr;
		_if.ram_ren		= crif.ram_ren;
		_if.ram_wen		= crif.ram_wen;
	end

	// Modules
	datapath #(.PC_INIT(PC_INIT)) dp0(dpif);
	
	// Memory controller/arbiter
	// TODO: extend to a memory bus controller?
	memory_controller mc(dpif, crif);

	// Onchip ram, for offchip, initialize an offchip mem controller?
	ram	#(.REORDER_DATA(1'b1), .LAT(4'b0)) ram0(crif);

endmodule