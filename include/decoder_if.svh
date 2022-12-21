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
        alu_insel_t alu_insel;  
    } alu_cmd;
    
    struct packed {
        reg_t rs1;
        reg_t rs2;
        reg_t rd;
        logic wen;
        wdat_sel_t wdat_sel;   // Write back data select
    } rf_cmd;

    // TODO Remove the dmem prefix as already in dmem_cmd struct?
    struct packed {
        logic       dmem_wen;   // Write to dmem enable
        logic       dmem_ren;   // Read from dmem enable
        logic       dmem_load_unsigned; // Whether to unsigned shift or signed shift loaded value
        logic [LDST_WIDTH_W - 1:0]  dmem_width;  // LD/ST data width 
    } dmem_cmd;

    csr_cmd_t csr_cmd;
    logic [4:0] csr_uimm;
    decoder_exception_t dec_exception_event;

    bcontrol_t control_type;

    inst_t inst_type;
    word_t imm32; // Signed extended imm32
    logic [BIT_WIDTH - 1:0]     inst;

    modport decode (
        input   inst,
        output  alu_cmd, rf_cmd, dmem_cmd, control_type, 
                inst_type, imm32, csr_cmd, csr_uimm, dec_exception_event
    );

    modport tb (
        input   alu_cmd, rf_cmd, dmem_cmd, control_type, 
                inst_type, imm32, csr_cmd, csr_uimm, dec_exception_event,
        output  inst
    );
    
endinterface // decoder_if

`endif // __DECODER_IF_VH__