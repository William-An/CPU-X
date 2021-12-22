/*
 * File name:	regfile_if.vh
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Register file interface
*/

`ifndef __REGFILE_IF_VH__
`define __REGFILE_IF_VH__

`include "rv32ima_pkg.vh"

interface regfile_if (input clk, input nrst);
    import rv32ima_pkg::*;

    reg_t   rsel1;
    reg_t   rsel2;
    reg_t   wsel;
    logic   wen;
    word_t  rdat1;
    word_t  rdat2;
    word_t  wdat;

    modport regfile ( * 
        input rsel1, rsel2, wsel, wen, wdat, clk, nrst,
        output rdat1, rdat2
    );

    modport tb (
        input rdat1, rdat2, clk, nrst,
        output rsel1, rsel2, wsel, wen, wdat
    );

endinterface // alu_if

`endif  // __REGFILE_IF_VH__