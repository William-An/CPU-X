/**
 * File name:	pc.sv
 * Created:	12/24/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	PC implementation
 */

`include "pc_if.svh"
`include "rv32ima_pkg.svh"

module pc #(
    PC_INIT = -4
)
(
    pc_if.pc _if
);
    import rv32ima_pkg::*;

    word_t tmp_pc;

    always_ff @( posedge _if.clk, negedge _if.nrst ) begin : STATE
        if (_if.nrst == 1'b0) begin
            _if.curr_pc <= PC_INIT;
            _if.next_pc_en <= 1'b0;
        end 
        else begin
            _if.next_pc_en <= 1'b1; // Sync with clk
            if (_if.inst_ready == 1'b1) begin
                // Fetch next instruction when the current one is ready and consume by the datapath
                _if.curr_pc <= _if.next_pc;
            end
        end
    end

    always_comb begin : NEXT_LOGIC
        _if.pc_add4 = _if.curr_pc + 4;
        _if.next_pc = _if.pc_add4;

        // TODO Glitches?
        if (_if.branch_addr_en == 1'b1)
            _if.next_pc = _if.branch_addr;
    end

endmodule
