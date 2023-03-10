/**
 * File name:	ram_if.svh
 * Created:	12/25/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Wrapper interface to communicate between ram internal and cpu
 */

`ifndef __CPU_RAM_IF_SVH__
`define __CPU_RAM_IF_SVH__

`include "rv32ima_pkg.svh"

interface cpu_ram_if (input ram_clk, input nrst);
    import rv32ima_pkg::*;

    // TODO Make the following signal a RAM event packet
    word_t ram_addr;
    word_t ram_store;
    word_t ram_load;
    logic  ram_ren;
    logic  ram_wen;
    logic [LDST_WIDTH_W - 1:0] ram_width;
    ram_state_t ram_state;

    modport cpu (
        input ram_load, ram_state,
        output ram_addr, ram_store, ram_ren, ram_wen, ram_width
    );

    modport ram (
        input ram_clk, nrst, ram_addr, ram_store, ram_ren, ram_wen, ram_width,
        output ram_load, ram_state
    );

    modport tb (
        input ram_load, ram_state, ram_addr, ram_ren, ram_wen
    );


endinterface // cpu_ram_if

`endif // __CPU_RAM_IF_SVH__