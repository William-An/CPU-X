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

    word_t ram_addr;
    word_t ram_store;
    word_t ram_load;
    logic  ram_ren;
    logic  ram_wen;

    modport cpu (
        input ram_load, 
        output ram_addr, ram_store, ram_ren, ram_wen
    );

    modport ram (
        input ram_clk, nrst, ram_addr, ram_store, ram_ren, ram_wen,
        output ram_load 
    );


endinterface // cpu_ram_if

`endif // __CPU_RAM_IF_SVH__