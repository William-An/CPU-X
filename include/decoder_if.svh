/**
 * File name:	decoder_if.vh
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Decoder unit interface
 */

`ifndef __DECODER_IF_VH__
`define __DECODER_IF_VH__

`include "rv32ima_pkg.svh"

interface decoder_if;
    import rv32ima_pkg::*;

    struct packed {
        aluop_t     aluop;
        // ALU input value select, [0] for in1, [1] for in2
        // 1'b0 for regfile data, 1'b1 for alternative input
        enum logic [1:0] {
            ALU_R2R = 2'b00,    // Register to Register
            ALU_R2I = 2'b01,    // Register to immediate
            ALU_PCR = 2'b10,    // PC to register
            ALU_PCI = 2'b11     // PC to immediate
        } alu_insel;  
    } alu_cmd;
    
    struct packed {
        reg_t rs1;
        reg_t rs2;
        reg_t rd;
        logic wen;
        enum logic [1:0] {
            ALU_OUT,
            LOAD_OUT,
            NPC         // Next instruction, or PC + 4
        } wdat_sel;   // Write back data select
    } rf_cmd;

    struct packed {
        logic       dmem_wen;   // Write to dmem enable
        logic       dmem_ren;   // Read from dmem enable
        logic       dmem_load_unsigned; // Whether to unsigned shift or signed shift loaded value
        logic [LDST_WIDTH_W - 1:0]  dmem_width;  // LD/ST data width 
    } dmem_cmd;

    bcontrol_t control_type;

    inst_t inst_type;
    word_t imm32; // Signed extended imm32
    logic [BIT_WIDTH - 1:0]     inst;

    modport decode (
        input inst,
        output alu_cmd, rf_cmd, dmem_cmd, control_type, inst_type, imm32
    );

    modport tb (
        input alu_cmd, rf_cmd, dmem_cmd, control_type, inst_type, imm32,
        output inst
    );
    
endinterface // decoder_if

`endif // __DECODER_IF_VH__