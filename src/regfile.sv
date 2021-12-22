/**
 * File name:	regfile.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Register file
 */

`include "include/regfile_if.vh"
`include "include/rv32ima_pkg.vh"

module regfile (
    regfile_if.regfile _if
);
    import rv32ima_pkg::*;
    localparam REG_COUNT = 2**REG_W;

    word_t [REG_COUNT - 1:0] rf, next_rf;

    always_ff @( posedge _if.clk, negedge _if.nrst ) begin : STATE_LOGIC
        if (_if.nrst == 1'b0)
            rf <= '0;
        else
            rf <= next_rf;
    end

    always_comb begin : NXT_LOGIC
        next_rf = rf;
        // Make sure wen is set and not write to r0 (hard-wired to 0s)
        if (_if.wen && _if.wsel != 0) begin
            next_rf[_if.wsel] = _if.wdat;
        end
    end

    always_comb begin : OUT_LOGIC
        _if.rdat1 = rf[_if.rsel1];
        _if.rdat2 = rf[_if.rsel2];
    end
    
endmodule