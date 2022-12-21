/**
 * File name:	branch_resolver.sv
 * Created:	12/21/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.1 Add support to jump to trap and EPC address
 * Description:	Branch resolver, can add predictor help in future
 */

`include "branch_resolver_if.svh"
`include "exception_if.svh"
`include "rv32ima_pkg.svh"

module branch_resolver (
    branch_resolver_if.br _if,
    exception_if.consumer _excep_if
);
    import rv32ima_pkg::*;

    always_comb begin: Resolver
        _if.next_addr = '0;
        _if.next_addr_en = '0;

        if (_excep_if.trap_enable) begin
            // Prioritize trap handling
            // Jump to trap handler address
            _if.next_addr = _excep_if.trap_handler_addr;
            _if.next_addr_en = 1'b1;
        end
        else if (_excep_if.xret_enable) begin
            // Return to EPC address
            _if.next_addr = _excep_if.epc_value;
            _if.next_addr_en = 1'b1;
        end
        else if (_if.control_type.is_branch) begin
            // TODO: Actually do not need the carry, zero, neg, overflow flags other place than this module, might be able to remove them?
            casez ({_if.zero, _if.neg, _if.control_type.branch_type})
                // Branch taken
                // Use ALU_SUB
                {1'b1, 1'b0, BEQ},
                {1'b0, 1'b?, BNE},
                // Use ALU_SLT[U]
                {1'b0, 1'b?, BLT},
                {1'b1, 1'b?, BGE},
                {1'b0, 1'b?, BLTU},
                {1'b1, 1'b?, BGEU}:
                begin
                    _if.next_addr_en    = 1'b1;
                    _if.next_addr       = _if.branch_addr;
                end
                // Branch not taken
                default: begin
                    _if.next_addr_en    = 1'b0;
                    _if.next_addr       = '0;
                end
            endcase
        end
        else if (_if.control_type.is_jump) begin
            _if.next_addr_en    = 1'b1;
            _if.next_addr       = _if.jump_addr;
        end
    end
endmodule
