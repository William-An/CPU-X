/**
 * File name:	system.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Top-level entry for the CPU implementation
 */

`timescale 1ns / 100ps

`include "include/rv32ima_pkg.svh"
`include "include/datapath_if.svh"

import rv32ima_pkg::*;

module system
(
	input clk,
	input nrst,
	output word_t iaddr,
	input word_t idata,
	input logic ihit,
	output logic iren,
	input logic dhit,
	output logic dren,
	output logic dwen,
	output word_t dstore,
	input word_t dload,
	output word_t daddr,
	output logic [LDST_WIDTH_W - 1:0] dwidth
);

	// Testing synthesis size
	datapath_if dpif(clk, nrst);

	assign iaddr = dpif.imem_addr;
	assign iren = dpif.imem_ren;
	assign dren = dpif.dmem_ren;
	assign dwen = dpif.dmem_wen;
	assign dstore = dpif.dmem_store;
	assign daddr = dpif.dmem_addr;
	assign dwidth = dpif.dmem_width;

	assign dpif.imem_load = idata;
	assign dpif.ihit = ihit;
	assign dpif.dhit = dhit;
	assign dpif.dmem_load = dload;

	datapath dp0(dpif);

endmodule