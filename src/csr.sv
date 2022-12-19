/**
 * File name:	csr.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	CSR unit for the RV32IMA+Zicsr CPU
 */

`include "csr_if.svh"
`include "rv32ima_pkg.svh"

import rv32ima_pkg::*;

localparam CSR_REG_W = 5;
localparam CSR_COUNT = 2**CSR_REG_W;

module csr (
    csr_if.csr _if
);

    // TODO: Need to make a punctucated CSR register banks?
    // TODO: Rightnow this takes a while to compile
    word_t [CSR_COUNT - 1:0] csr, next_csr;
    logic [CSR_REG_W - 1:0] csr_psel; // Physical CSR register select
    word_t uimm32;

    assign uimm32 = {27'b0, _if.csr_input.uimm};

    always_ff @(posedge _if.clk, negedge _if.nrst) begin : CSR_REG
        if (_if.nrst == 1'b0)
            csr <= '0;
        else
            csr <= next_csr;
    end

    always_comb begin : CSR_UPDATE_LOGIC
        next_csr = csr;
        _if.csr_val = '0;
        CSR_Regfile_Hashing(.csr_index(_if.csr_cmd.index), .hashed_index(csr_psel));
        
        // Perform atomic swap and bit set/clear
        casez (_if.csr_cmd.opcode)
            CSRRW: begin
                // Atomically swap the CSR with the register value
                // And output the old CSR value
                if (_if.csr_cmd.ren) begin
                    // Read CSR value
                    next_csr[csr_psel] = _if.csr_input.reg_val;
                    _if.csr_val = csr[csr_psel];
                end
                else begin
                    // Do not read CSR value
                    next_csr[csr_psel] = _if.csr_input.reg_val;
                    _if.csr_val = '0; 
                end
            end
            CSRRS: begin
                // Atomically set the CSR bits indicated by
                // the register
                // And output the old CSR value
                if (_if.csr_cmd.wen) begin
                    next_csr[csr_psel] |= _if.csr_input.reg_val;
                    _if.csr_val = csr[csr_psel];
                end
                else begin
                    _if.csr_val = csr[csr_psel];
                end
            end
            CSRRC: begin
                // Atomically clear the CSR bits indicated by
                // the register
                // And output the old CSR value
                if (_if.csr_cmd.wen) begin
                    next_csr[csr_psel] &= ~_if.csr_input.reg_val;
                    _if.csr_val = csr[csr_psel];
                end
                else begin
                    _if.csr_val = csr[csr_psel];
                end
            end
            CSRRWI: begin
                // Atomically swap the CSR with the uimm value
                // And output the old CSR value
                if (_if.csr_cmd.ren) begin
                    // Read CSR value
                    next_csr[csr_psel] = uimm32;
                    _if.csr_val = csr[csr_psel];
                end
                else begin
                    // Do not read CSR value
                    next_csr[csr_psel] = uimm32;
                    _if.csr_val = '0; 
                end
            end
            CSRRSI: begin
                // Atomically set the CSR bits indicated by
                // the uimm32
                // And output the old CSR value
                if (_if.csr_cmd.wen) begin
                    next_csr[csr_psel] |= uimm32;
                    _if.csr_val = csr[csr_psel];
                end
                else begin
                    _if.csr_val = csr[csr_psel];
                end
            end
            CSRRCI: begin
                // Atomically clear the CSR bits indicated by
                // the uimm32 value
                // And output the old CSR value
                if (_if.csr_cmd.wen) begin
                    next_csr[csr_psel] &= ~uimm32;
                    _if.csr_val = csr[csr_psel];
                end
                else begin
                    _if.csr_val = csr[csr_psel];
                end
            end
            default: _if.csr_val = '0;
        endcase
    end

endmodule

task CSR_Regfile_Hashing;
    input logic [11:0] csr_index;
    output logic [CSR_REG_W - 1:0] hashed_index;
    begin
        // Limited M-mode CSR registers
        // From top to bottom
        // Machine information registers
        // Machine trap setup registers
        // Machine trap handling registers
        // Machine configuration registers
        casez(csr_index)
            CSR_MVENDORID:  hashed_index = 'd1;
            CSR_MARCHID:    hashed_index = 'd2;
            CSR_MIMPID:     hashed_index = 'd3;
            CSR_MHARTID:    hashed_index = 'd4;
            CSR_MCONFIGPTR: hashed_index = 'd5;
            
            CSR_MSTATUS:    hashed_index = 'd6;
            CSR_MISA:       hashed_index = 'd7;
            CSR_MEDELEG:    hashed_index = 'd8;
            CSR_MIDELEG:    hashed_index = 'd9;
            CSR_MIE:        hashed_index = 'd10;
            CSR_MTVEC:      hashed_index = 'd11;
            CSR_MCOUNTEREN: hashed_index = 'd12;
            CSR_MSTATUSH:   hashed_index = 'd13;

            CSR_MSCRATCH:   hashed_index = 'd14;
            CSR_MEPC:       hashed_index = 'd15;
            CSR_MCAUSE:     hashed_index = 'd16;
            CSR_MTVAL:      hashed_index = 'd17;
            CSR_MIP:        hashed_index = 'd18;
            CSR_MTINST:     hashed_index = 'd19;
            CSR_MTVAL2:     hashed_index = 'd20;
            
            CSR_MENVCFG:    hashed_index = 'd21;
            CSR_MENVCFGH:   hashed_index = 'd22;
            CSR_MSECCFG:    hashed_index = 'd23;
            CSR_MSECCFGH:   hashed_index = 'd24;
            default: hashed_index = 'd0;    // this register should hard-wired to zeros
        endcase
    end
endtask