/**
 * File name:	alu.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	ALU for the RV32IMA CPU
 */

`include "alu_if.svh"
`include "rv32ima_pkg.svh"

module alu (
    alu_if.alu _if
);
    import rv32ima_pkg::*;

    logic in1_msb;
    logic in2_msb;
    logic out_msb;

    always_comb begin : ALU
        _if.carry = 1'b0;
        in1_msb = _if.in1[BIT_WIDTH - 1];
        in2_msb = _if.in2[BIT_WIDTH - 1];
        casez (_if.alu_op)
            ALU_ADD  : {_if.carry, _if.out} = {in1_msb, _if.in1} + {in2_msb, _if.in2};
            ALU_SUB  : {_if.carry, _if.out} = {in1_msb, _if.in1} - {in2_msb, _if.in2};
            ALU_SLT  : _if.out = signed'(_if.in1) <  signed'(_if.in2) ? 32'b1 : 32'b0;
            ALU_SLTU : _if.out = unsigned'(_if.in1) < unsigned'(_if.in2) ? 32'b1 : 32'b0;
            ALU_AND  : _if.out = _if.in1 & _if.in2;
            ALU_OR   : _if.out = _if.in1 | _if.in2;
            ALU_XOR  : _if.out = _if.in1 ^ _if.in2;
            ALU_SLL  : _if.out = _if.in1 << _if.in2[4:0];
            ALU_SRL  : _if.out = _if.in1 >> _if.in2[4:0];
            ALU_SRA  : _if.out = _if.in1 >>> _if.in2[4:0];
            ALU_MUL  : _if.out = _if.in1 * _if.in2;
            // Commented out to save synthesis space, also might try some efficient implementation
            // ALU_DIV : _if.out = _if.in1 / _if.in2;
            // ALU_REM : _if.out = _if.in1 % _if.in2;
            default : {_if.carry, _if.out} = '0; // Default assign zeros
        endcase

        // Additional output status signal
        out_msb = _if.out[BIT_WIDTH - 1];
        _if.zero = ~|_if.out;
        _if.neg  = out_msb;
        // Since in two's complement, sign bit is extended
        // Thus {carry, out} holds the result in 33-bit format
        // if carry bit differs from out_msb, it means the out value
        // perceive in 32-bit format is overflowed
        _if.overflow = _if.carry ^ out_msb;

    end
    
endmodule