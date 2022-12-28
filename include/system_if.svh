/**
 * File name:	system_if.svh
 * Created:	12/22/2022
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Wrapper interface to access system
 */

`ifndef __SYSTEM_IF_SVH__
`define __SYSTEM_IF_SVH__

`include "rv32ima_pkg.svh"
`include "ax301_peripherals/ax301_peripherals_pkg.svh"

interface system_if;
    import rv32ima_pkg::*;
    import ax301_peripherals_pkg::*;

    // TODO Make the following signal a RAM event packet
    word_t ram_addr;
    word_t ram_store;
    word_t ram_load;
    logic  ram_ren;
    logic  ram_wen;
    logic[1:0] ram_state;
    ax301_segment_ctrl seg_ctrl;

    modport system (
        output ram_load, ram_store, ram_state, ram_addr, ram_ren, ram_wen, 
               seg_ctrl
    );

    modport tb (
        input ram_load, ram_store, ram_state, ram_addr, ram_ren, ram_wen, 
              seg_ctrl
    );
endinterface // cpu_ram_if

`endif // __SYSTEM_IF_SVH__