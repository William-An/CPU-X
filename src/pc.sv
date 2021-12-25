/**
 * File name:	pc.sv
 * Created:	12/24/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	PC implementation
 */

`include "include/pc_if.svh"
`include "include/rv32ima_pkg.svh"

module pc #(
    PC_INIT = 32'b0
) (
    pc_if.pc _if
);
    import rv32ima_pkg::*;

    word_t tmp_pc;

    always_ff @( posedge _if.clk, negedge _if.nrst ) begin : STATE
        if (_if.nrst == 1'b0) begin
            _if.curr_pc = PC_INIT;
        end 
        else if (_if.inst_ready == 1'b1) begin
            // Fetch next instruction when the current one is ready and consume by the datapath
            _if.curr_pc = _if.next_pc;
        end
    end

    always_comb begin : NEXT_LOGIC
        _if.pc_add4 = _if.curr_pc + 4;
        _if.next_pc = _if.pc_add4;
        _if.next_pc_en = 1'b1;  // Always fetching

        // TODO Glitches?
        if (_if.branch_addr_en == 1'b1)
            _if.next_pc = _if.branch_addr;
    end

endmodule