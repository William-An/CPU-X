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
		rfif0.wen 	= decif0.rf_cmd.wen;

		// Connecting signals to decoder
		decif0.inst	= inst;

		// Connecting signals to CSR unit
		csrif0.csr_cmd = decif0.csr_cmd;
		csrif0.csr_input.uimm = decif0.csr_uimm;
		csrif0.csr_input.reg_val = rfif0.rdat1;

		// Connecting signals to ALU
		aif0.in1 = decif0.alu_cmd.alu_insel[0] == 1'b0 ? rfif0.rdat1 : pcif0.curr_pc;
		aif0.in2 = decif0.alu_cmd.alu_insel[1] == 1'b0 ? rfif0.rdat2 : decif0.imm32;
		aif0.alu_op = decif0.alu_cmd.aluop;

		// Data memory signals
		dpif.dmem_store 	= rfif0.rdat2;
		dpif.dmem_addr		= aif0.out;
		dpif.dmem_width 	= decif0.dmem_cmd.dmem_width;

		// Register this signal to avoid self-loop between dmem_wen and dhit
		if (dpif.dhit) begin
			next_served_data = 1'b1;
		end
		else begin
			next_served_data = 1'b0;
		end

		if (!served_data) begin
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
			ext_load = dpif.dmem_load;
		end
		else begin
			// Casting from signed will pad with signed bit
			casez (decif0.dmem_cmd.dmem_width[1:0])
				2'b00:	ext_load = signed'(dpif.dmem_load[7:0]);
				2'b01:	ext_load = signed'(dpif.dmem_load[15:0]);
				2'b10:	ext_load = signed'(dpif.dmem_load[31:0]);
				default: ext_load = signed'(dpif.dmem_load[31:0]);
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
	csr						csr0(csrif0);
	alu 					alu0(aif0);
	branch_resolver 		br(brif0);

endmodule