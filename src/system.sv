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
`include "include/alu_if.svh"
`include "include/regfile_if.svh"
`include "include/datapath_if.svh"

import rv32ima_pkg::*;

module system
(
	input clk,
	input nrst,
	input word_t inst
);

	// Testing synthesis size
	alu_if aif0();
	regfile_if rfif0(clk, nrst);
	decoder_if decif0();

	assign aif0.in1 = rfif0.rdat1;
	assign aif0.in2 = rfif0.rdat2;
	assign aif0.alu_op = decif0.alu_cmd.aluop;

	assign rfif0.rsel1 	= decif0.rf_cmd.rs1;
	assign rfif0.rsel2 	= decif0.rf_cmd.rs2;
	assign rfif0.wsel 	= decif0.rf_cmd.rd;
	assign rfif0.wen 	= decif0.rf_cmd.wen;
	assign rfif0.wdat 	= aif0.out;

	assign decif0.inst	= inst;

	alu 	alu0(aif0);
	regfile rf0(rfif0);
	decoder dec0(decif0);

endmodule