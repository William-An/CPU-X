/**
 * File name:	datapath.sv
 * Created:	12/24/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Datapath for the CPU implementation, connecting signals together
 */

`timescale 1ns / 100ps

`include "include/rv32ima_pkg.svh"
`include "include/alu_if.svh"
`include "include/regfile_if.svh"
`include "include/pc_if.svh"
`include "include/datapath_if.svh"

import rv32ima_pkg::*;

module datapath
(
	datapath_if.dp dpif
);

	// Initializing interfaces and signals
    pc_if pcif0(dpif.clk, dpif.nrst);
	decoder_if decif0();
	regfile_if rfif0(dpif.clk, dpif.nrst);
	alu_if aif0();
    word_t branch_addr; // Branch addr
    word_t ext_load;    // Signed extended load val

    // Connecting signals to PC
    assign pcif0.branch_addr = branch_addr;
    assign pcif0.branch_addr_en = 1'b1; // TODO
    assign pcif0.inst_ready = dpif.ihit;

    // Connecting signals to regfile
	assign rfif0.rsel1 	= decif0.rf_cmd.rs1;
	assign rfif0.rsel2 	= decif0.rf_cmd.rs2;
	assign rfif0.wsel 	= decif0.rf_cmd.rd;
	assign rfif0.wen 	= decif0.rf_cmd.wen;
	assign rfif0.wdat 	= aif0.out;

    // Connecting signals to decoder
	assign decif0.inst	= dpif.imem_load;

    // Connecting signals to ALU
	assign aif0.in1 = decif0.alu_cmd.alu_insel[0] == 1'b0 ? rfif0.rdat1 : pcif0.curr_pc;
	assign aif0.in2 = decif0.alu_cmd.alu_insel[1] == 1'b0 ? rfif0.rdat2 : decif0.imm32;
	assign aif0.alu_op = decif0.alu_cmd.aluop;

    // Branch adder
    assign branch_addr = decif0.imm32 + pcif0.curr_pc;

    // Initializing modules
    pc      pc0(pcif0);
	decoder dec0(decif0);
	regfile rf0(rfif0);
	alu 	alu0(aif0);

endmodule