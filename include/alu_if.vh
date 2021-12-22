/*
 * File name:	alu_if.vh
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	RV32IMA ALU interface
*/

`ifndef __ALU_IF_VH__
`define __ALU_IF_VH__

`include "rv32ima_pkg.vh"

interface alu_if;
    import rv32ima_pkg::*;

    aluop_t alu_op;
    word_t  in1;
    word_t  in2;
    word_t  out;
    logic   zero;
    logic   neg;
    logic   overflow;
    logic   carry;

    modport alu (
        input alu_op, in1, in2,
        output out, zero, neg, overflow, carry
    );

    modport tb (
        input out, zero, neg, overflow, carry,
        output alu_op, in1, in2
    );

endinterface // alu_if

`endif  // __ALU_IF_VH__