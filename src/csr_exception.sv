/**
 * File name:	csr_exception.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	CSR and Exception unit for the RV32IMA+Zicsr CPU
 */

`include "csr_if.svh"
`include "exception_if.svh"
`include "rv32ima_pkg.svh"
`include "csr_pkg.svh"

import rv32ima_pkg::*;
import csr_pkg::*;

localparam CSR_REG_W = 5;
localparam CSR_COUNT = 2**CSR_REG_W;

typedef enum logic [CSR_REG_W - 1:0] { 
    PHY_CSR_ZEROS = '0,
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

module csr_exception (
    csr_if.csr _if,
    exception_if.subscriber _excep_if
);

    // TODO: Need to update CSR registers based on request to
    // TODO: hardware environment
    word_t [CSR_COUNT - 1:0] csr, next_csr;
    logic [CSR_REG_W - 1:0] csr_psel; // Physical CSR register select
    word_t uimm32;
    logic exception_hit;    // By ORing all the exception flags

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

    word_t mtvec_base_addr;
    logic [XLEN-2:0] cause_code;
    word_t trap_value;
    always_comb begin : CSR_UPDATE_LOGIC
        next_csr = csr;
        _if.csr_val = '0;
        uimm32 = {27'b0, _if.csr_input.uimm};
        CSR_Regfile_Hashing(.csr_index(_if.csr_cmd.index), .hashed_index(csr_psel));
        mtvec_base_addr = {csr[PHY_CSR_MTVEC][MTVEC_BASE_END_BIT:MTVEC_BASE_START_BIT], 2'b0};
        cause_code = '0;
        trap_value = '0;
        _excep_if.epc_value = csr[PHY_CSR_MEPC];
        _excep_if.trap_handler_addr = mtvec_base_addr;   // Default
        exception_hit = _excep_if.inst_fetch_exception_event.inst_misalign | 
                        _excep_if.ldst_exception_event.load_addr_misalign |
                        _excep_if.ldst_exception_event.store_amo_addr_misalign |
                        _excep_if.dec_exception_event.inst_illegal |
                        _excep_if.dec_exception_event.ebreak |
                        _excep_if.dec_exception_event.ecall;
        _excep_if.trap_enable = exception_hit;

        // Exception hit
        if (exception_hit == 1'b1) begin
            // First need to handle privilege mode saving in mstatus
            // xPIE bit should be set to xIE when a trap taken from privilege mode y to x
            // xIE is then set to 0, and xPP is set to y
            // Since currently only M-mode is supported, this is trivial
            next_csr[PHY_CSR_MSTATUS][MSTATUS_MPIE_BIT] = csr[PHY_CSR_MSTATUS][MSTATUS_MIE_BIT];
            next_csr[PHY_CSR_MSTATUS][MSTATUS_MIE_BIT] = 1'b0;
            next_csr[PHY_CSR_MSTATUS][MSTATUS_MPP_BIT1:MSTATUS_MPP_BIT0] = MSTATUS_xPP_M_MODE;

            // Now need to set the mcause register
            // Exception only right now
            if (_excep_if.dec_exception_event.inst_illegal) begin
                cause_code = MCAUSE_CODE_EXCEPTION_INST_ILLEGAL;
            end 
            else if (_excep_if.inst_fetch_exception_event.inst_misalign) begin
                cause_code = MCAUSE_CODE_EXCEPTION_INST_ADDR_MISALIGN;
            end
            else if (_excep_if.dec_exception_event.ecall) begin
                // Since the current implementation is M-mode only
                cause_code = MCAUSE_CODE_EXCEPTION_ENVIRONMENT_CALL_M_MODE;
            end
            else if (_excep_if.dec_exception_event.ebreak) begin
                cause_code = MCAUSE_CODE_EXCEPTION_BREAKPOINT;
            end
            else if (_excep_if.ldst_exception_event.load_addr_misalign) begin
                // If mtval is written with a nonzero value when address-misaligned,
                // exception occurs on an instruction fetch, load, or store, 
                // then mtval will contain the faulting virtual address
                // Since no virtual memory support, just physical mem addr
                cause_code = MCAUSE_CODE_EXCEPTION_LOAD_ADDR_MISALIGN;
                trap_value = _excep_if.current_pc;
            end
            else if (_excep_if.ldst_exception_event.store_amo_addr_misalign) begin
                cause_code = MCAUSE_CODE_EXCEPTION_STORE_AMO_ADDR_MISALIGN;
            end
            // Write exception code to mcause register
            // Also update the mtval register
            next_csr[PHY_CSR_MCAUSE] = {1'b0, cause_code};
            next_csr[PHY_CSR_MTVAL] = trap_value;
            
            // Now need to jump to the handler address based on the mtvec
            // base address and mtvec mode
            // Default handler address is set to be direct mode
            if (csr[PHY_CSR_MTVEC][MTVEC_MODE_BIT1:MTVEC_MODE_BIT0] == MTVEC_MODE_VECTORED) begin
                // If vectored, jump to BASE + 4xcause address
                _excep_if.trap_handler_addr = mtvec_base_addr + cause_code << 2;
            end
            
            // Finally we need to update the epc value
            next_csr[PHY_CSR_MEPC] = _excep_if.current_pc;
        end
        else if (_if.csr_cmd.valid == 1'b1) begin  // Else perform normal operation
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