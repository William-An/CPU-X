/**
 * File name:	csr_if.vh
 * Created:	12/18/2022
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	CSR module interface
 */

`ifndef __CSR_IF_VH__
`define __CSR_IF_VH__

`include "rv32ima_pkg.svh"

interface csr_if (input clk, input nrst);
    import rv32ima_pkg::*;

    struct packed {
        logic [11:0]    index;  // CSR register index
        system_funct3_t opcode; // CSR opcode
        logic           ren;    // CSR register ren, whether to read from CSR register
        logic           wen;    // CSR register wen, whether to write to CSR register
    } csr_cmd;
    
    // CSR input source, can be from rs1 register or a 5 bit imm value to be extended
    struct packed {
        word_t      reg_val;
        logic [4:0] uimm;
    } csr_input;

    // CSR output value
    word_t csr_val;

    modport csr (
        input csr_cmd, csr_input, clk, nrst,
        output csr_val
    );

    modport tb (
        input csr_val, clk, nrst,
        output csr_cmd, csr_input
    );
    
endinterface // csr_if

`endif // __CSR_IF_VH__