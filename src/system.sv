/**
 * File name:	system.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Top-level entry for the CPU implementation
 */

`timescale 1ns / 100ps

`include "include/rv32ima_pkg.vh"
`include "include/alu_if.vh"
`include "include/regfile_if.vh"

module system
(
	input clk,
	input nrst,
	input reg_t rs1,
	input reg_t rs2,
	input logic wen,
	input reg_t rd,
	input word_t wdata,
	input aluop_t op,
	output word_t out
);
	import rv32ima_pkg::*;

	// Testing synthesis size
	alu_if aif0();
	regfile_if rfif0(clk, nrst);

	assign aif0.in1 = rfif0.rdat1;
	assign aif0.in2 = rfif0.rdat2;
	assign out = aif0.out;
	assign aif0.alu_op = op;

	assign rfif0.rsel1 = rs1;
	assign rfif0.rsel2 = rs2;
	assign rfif0.wsel = rd;
	assign rfif0.wen = wen;
	assign rfif0.wdat = wdata;

	alu alu0(aif0);
	regfile rf0(rfif0);

endmodule