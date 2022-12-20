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
`include "csr_pkg.svh"

import rv32ima_pkg::*;
import csr_pkg::*;

localparam CSR_REG_W = 5;
localparam CSR_COUNT = 2**CSR_REG_W;

typedef enum logic [CSR_REG_W - 1:0] { 
    PHY_CSR_ZEROS = 'd0,
    PHY_CSR_MVENDORID,
    PHY_CSR_MARCHID,
    PHY_CSR_MIMPID,
    PHY_CSR_MHARTID,
    PHY_CSR_MCONFIGPTR,
    PHY_CSR_MSTATUS,
    PHY_CSR_MISA,
    PHY_CSR_MEDELEG,
    PHY_CSR_MIDELEG,
    PHY_CSR_MIE,
    PHY_CSR_MTVEC,
    PHY_CSR_MCOUNTEREN,
    PHY_CSR_MSTATUSH,
    PHY_CSR_MSCRATCH,
    PHY_CSR_MEPC,
    PHY_CSR_MCAUSE,
    PHY_CSR_MTVAL,
    PHY_CSR_MIP,
    PHY_CSR_MTINST,
    PHY_CSR_MTVAL2,
    PHY_CSR_MENVCFG,
    PHY_CSR_MENVCFGH,
    PHY_CSR_MSECCFG,
    PHY_CSR_MSECCFGH
} pcsr_index_t;

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
        if (_if.nrst == 1'b0) begin
            csr <= '0;

            // Set I-bit in MISA to indicate the CPU support RV32I ISA
            // Also set MXL to 32 bit
            csr[PHY_CSR_MISA][MISA_EXT_I_RVIBASE_BIT] <= 1'b1;
            csr[PHY_CSR_MISA][MISA_MXL_BIT1:MISA_MXL_BIT0] <= MISA_MXL_32;
        end
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
    output pcsr_index_t hashed_index;
    begin
        // Limited M-mode CSR registers
        // From top to bottom
        // Machine information registers
        // Machine trap setup registers
        // Machine trap handling registers
        // Machine configuration registers
        casez(csr_index)
            CSR_MVENDORID:  hashed_index =  PHY_CSR_MVENDORID;
            CSR_MARCHID:    hashed_index =  PHY_CSR_MARCHID;
            CSR_MIMPID:     hashed_index =  PHY_CSR_MIMPID;
            CSR_MHARTID:    hashed_index =  PHY_CSR_MHARTID;
            CSR_MCONFIGPTR: hashed_index =  PHY_CSR_MCONFIGPTR;
            
            CSR_MSTATUS:    hashed_index =  PHY_CSR_MSTATUS;
            CSR_MISA:       hashed_index =  PHY_CSR_MISA;
            CSR_MEDELEG:    hashed_index =  PHY_CSR_MEDELEG;
            CSR_MIDELEG:    hashed_index =  PHY_CSR_MIDELEG;
            CSR_MIE:        hashed_index =  PHY_CSR_MIE;
            CSR_MTVEC:      hashed_index =  PHY_CSR_MTVEC;
            CSR_MCOUNTEREN: hashed_index =  PHY_CSR_MCOUNTEREN;
            CSR_MSTATUSH:   hashed_index =  PHY_CSR_MSTATUSH;

            CSR_MSCRATCH:   hashed_index =  PHY_CSR_MSCRATCH;
            CSR_MEPC:       hashed_index =  PHY_CSR_MEPC;
            CSR_MCAUSE:     hashed_index =  PHY_CSR_MCAUSE;
            CSR_MTVAL:      hashed_index =  PHY_CSR_MTVAL;
            CSR_MIP:        hashed_index =  PHY_CSR_MIP;
            CSR_MTINST:     hashed_index =  PHY_CSR_MTINST;
            CSR_MTVAL2:     hashed_index =  PHY_CSR_MTVAL2;
            
            CSR_MENVCFG:    hashed_index =  PHY_CSR_MENVCFG;
            CSR_MENVCFGH:   hashed_index =  PHY_CSR_MENVCFGH;
            CSR_MSECCFG:    hashed_index =  PHY_CSR_MSECCFG;
            CSR_MSECCFGH:   hashed_index =  PHY_CSR_MSECCFGH;
            default: hashed_index = PHY_CSR_ZEROS;    // this register should hard-wired to zeros
        endcase
    end
endtask