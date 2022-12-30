/**
 * File name:	datapath.sv
 * Created:	12/24/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Datapath for the CPU implementation, connecting signals together
 */

`timescale 1ns / 100ps

`include "rv32ima_pkg.svh"
`include "alu_if.svh"
`include "regfile_if.svh"
`include "pc_if.svh"
`include "branch_resolver_if.svh"
`include "datapath_if.svh"
`include "csr_if.svh"
`include "exception_if.svh"

import rv32ima_pkg::*;

module datapath #(
	parameter PC_INIT=-4
)
(
	datapath_if.dp dpif
);

	// Initializing interfaces and signals
    pc_if pcif0(dpif.clk, dpif.nrst);
	decoder_if decif0();
	regfile_if rfif0(dpif.clk, dpif.nrst);
	csr_if csrif0(dpif.clk, dpif.nrst);
	exception_if exceptionif0();

	alu_if aif0();
	branch_resolver_if brif0();
    word_t ext_load;    // Signed extended load val

	i_type inst, next_inst;
	i_type cached_inst, next_cached_inst;
	logic served_data, next_served_data;

	// TODO Fix ST/LD op issue, where iren is not properly overrided
	always_ff @(posedge dpif.clk, negedge dpif.nrst) begin: CACHED_DEN
		if (dpif.nrst == 1'b0) begin
			served_data <= 1'b0;
		end
		else begin
			served_data <= next_served_data;
		end
	end

	always_ff @( posedge dpif.clk, negedge dpif.nrst ) begin : INST_REG
		if (dpif.nrst == 1'b0) begin
			// Default to NOP
			inst <= '0;
			inst.opcode <= OP_IMM;
			cached_inst <= '0;
		end
		else begin
			inst <= next_inst;
			cached_inst <= next_cached_inst;
		end
	end

	// TODO Cache the imemload and use the first cycle of LD/ST inst to fetch, second cycle to perform data operation
	always_comb begin: DATAPATH
		dpif.imem_addr 		= pcif0.next_pc;
		dpif.imem_ren		= pcif0.next_pc_en;
		pcif0.inst_ready 	= dpif.ihit;
		next_inst			= inst;
		// next_served_data 	= served_data;
		ext_load			= '0;

		if (dpif.ihit == 1'b1)
			next_inst = dpif.imem_load;

		// Connecting signals to regfile
		rfif0.rsel1 = decif0.rf_cmd.rs1;
		rfif0.rsel2 = decif0.rf_cmd.rs2;
		rfif0.wsel 	= decif0.rf_cmd.rd;
		
		if (decif0.dmem_cmd.dmem_ren) begin
			// If a load, register should be updated
			// only when dhit
			rfif0.wen 	= decif0.rf_cmd.wen & dpif.dhit;
		end else begin
			// For regular inst, only update register file
			// (the only architectural state) when ihit
			// meaning we are ready for a new instruction
			// thus can finish the current instruction 
			// register write safely
			// to avoid issue like addi r3, r3, 1
			rfif0.wen 	= decif0.rf_cmd.wen & dpif.ihit;
		end
		
		// Connecting signals to decoder
		decif0.inst	= inst;

		// Connecting signals to CSR unit
		csrif0.csr_cmd.index = decif0.csr_cmd.index;
		csrif0.csr_cmd.opcode = decif0.csr_cmd.opcode;
		// For CSR instruction, only update CSR registers once
		// in a multi-cycle span waiting for instruction fetch
		csrif0.csr_cmd.valid = decif0.csr_cmd.valid & dpif.ihit;
		csrif0.csr_cmd.ren = decif0.csr_cmd.ren;
		csrif0.csr_cmd.wen = decif0.csr_cmd.wen;
		csrif0.csr_input.uimm = decif0.csr_uimm;
		csrif0.csr_input.reg_val = rfif0.rdat1;

		// Connecting signals to exception control
		exceptionif0.inst_fetch_exception_event.inst_misalign = pcif0.curr_pc[1:0] != 2'b0;	// RV32, instruction at 4 byte boundary
		exceptionif0.ldst_exception_event = '0;
		exceptionif0.dec_exception_event = decif0.dec_exception_event;
		exceptionif0.current_pc = pcif0.curr_pc;

		// Connecting signals to ALU
		aif0.in1 = decif0.alu_cmd.alu_insel[0] == 1'b0 ? rfif0.rdat1 : pcif0.curr_pc;
		aif0.in2 = decif0.alu_cmd.alu_insel[1] == 1'b0 ? rfif0.rdat2 : decif0.imm32;
		aif0.alu_op = decif0.alu_cmd.aluop;

		// Data memory signals
		dpif.dmem_store 	= rfif0.rdat2;
		dpif.dmem_addr		= aif0.out;
		dpif.dmem_width 	= decif0.dmem_cmd.dmem_width;
		LDST_Addr_Misalign_Checker(.width(dpif.dmem_width),
								   .addr(dpif.dmem_addr),
								   .served(served_data),
								   .ren(decif0.dmem_cmd.dmem_ren),
								   .wen(decif0.dmem_cmd.dmem_wen),
								   .load_misalign(exceptionif0.ldst_exception_event.load_addr_misalign),
								   .store_amo_misalign(exceptionif0.ldst_exception_event.store_amo_addr_misalign));

		// Register this signal to avoid self-loop between dmem_wen and dhit
		if (dpif.dhit) begin
			next_served_data = 1'b1;
		end
		else begin
			// Only clear the served_data flag when the next inst
			// 	is ready
			// We want to maintain this throughout the entire
			// inst span to not stuck in ld/st forever
			next_served_data = served_data;
			if (dpif.ihit)
				next_served_data = 1'b0;
		end

		if (served_data == 1'b0) begin
			dpif.dmem_wen		= decif0.dmem_cmd.dmem_wen;
			dpif.dmem_ren		= decif0.dmem_cmd.dmem_ren;
		end
		else begin
			dpif.dmem_wen		= 1'b0;
			dpif.dmem_ren		= 1'b0;
		end

		// Branch resolver
		brif0.branch_addr 	= decif0.imm32 + pcif0.curr_pc;
		brif0.jump_addr 	= aif0.out;
		brif0.zero 			= aif0.zero;
		brif0.neg 			= aif0.neg;
		brif0.control_type	= decif0.control_type;

		// PC branch addr
		pcif0.branch_addr 		= brif0.next_addr;
		pcif0.branch_addr_en	= brif0.next_addr_en;

		// Load value extender
		if (decif0.dmem_cmd.dmem_load_unsigned == 1'b1) begin
			// Unsigned type (logic) will be pad with 0s
			casez (decif0.dmem_cmd.dmem_width[1:0])
				// Byte load
				2'b00: ext_load = dpif.dmem_load[7:0]; 
				// Half word load
				2'b01: ext_load = dpif.dmem_load[15:0]; 
				// Full word load
				2'b10: ext_load = dpif.dmem_load; 
				// Invalid width, should raise illegal inst?
				default: ext_load = dpif.dmem_load; 
			endcase
		end
		else begin
			// Casting from signed will pad with signed bit
			casez (decif0.dmem_cmd.dmem_width[1:0])
				// Byte load
				2'b00: ext_load = signed'(dpif.dmem_load[7:0]);
				// Half word load
				2'b01: ext_load = signed'(dpif.dmem_load[15:0]);
				// Full word load
				2'b10: ext_load = signed'(dpif.dmem_load);
				// Invalid width, should raise illegal inst?
				default: ext_load = signed'(dpif.dmem_load);
			endcase
		end

		// Writeback value selecter
		casez (decif0.rf_cmd.wdat_sel)
			ALU_OUT: 	rfif0.wdat = aif0.out;
			LOAD_OUT:	rfif0.wdat = ext_load;
			NPC:		rfif0.wdat = pcif0.pc_add4;
			CSR_OUT:	rfif0.wdat = csrif0.csr_val;
			default:	rfif0.wdat = aif0.out;
		endcase
	end

    // Initializing modules
    pc #(.PC_INIT(PC_INIT)) pc0(pcif0);
	decoder 				dec0(decif0);
	regfile 				rf0(rfif0);
	csr_exception			csr_exception0(csrif0, exceptionif0);
	alu 					alu0(aif0);
	branch_resolver 		br(brif0, exceptionif0);

endmodule

task LDST_Addr_Misalign_Checker;
	input logic [LDST_WIDTH_W - 1:0]  width;
	input word_t addr;
	input logic served;	// Whether the LDST has been served (or checked) in the inst span, so no check
	input logic ren;
	input logic wen;
	output logic load_misalign;
	output logic store_amo_misalign;
	logic misalign;
	begin
		load_misalign = 1'b0;
		store_amo_misalign = 1'b0;
		misalign = 1'b0;

		// Just check the last 2 bits of width
		// Since the first bit is whether to sign extend or not
		casez(width[1:0])
			2'b00: misalign = 1'b0;					// Single byte
			2'b01: misalign = addr[0] != 0;			// Half word (2 bytes)
			2'b10: misalign = addr[1:0] != 2'b0;	// word (4 bytes)
			2'b11: misalign = 1'b1;	// RV32I does not contain inst supporting this
		endcase
		misalign &= ~served;
		load_misalign = ren & misalign;
		// Just store misalign now, no AMO support
		store_amo_misalign = wen & misalign;
	end
endtask