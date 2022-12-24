/**
 * File name:	datapath_if.vh
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Datapath interface with memory system
 */

`ifndef __DATAPATH_IF_VH__
`define __DATAPATH_IF_VH__

`include "rv32ima_pkg.svh"

interface datapath_if (input clk, input nrst);
    import rv32ima_pkg::*;

    word_t  imem_load;  // Data from imem, inst
    word_t  imem_addr;  // Addr to fetch inst
    logic   ihit;       // Data ready
    logic   imem_ren;   // Read from dmem enable

    // TODO Group these into an event packet struct?
    logic   dhit;       // Data ready
    logic   dmem_wen;   // Write to dmem enable
    logic   dmem_ren;   // Read from dmem enable
    word_t  dmem_store; // Data to store
    word_t  dmem_load;  // Data from dmem
    word_t  dmem_addr;  // Addr to ld/st data
    logic [LDST_WIDTH_W - 1:0] dmem_width;  // LD/ST data width

    modport dp (
        input imem_load, ihit, dhit, dmem_load, clk, nrst,
        output imem_addr, imem_ren, dmem_wen, dmem_ren, dmem_store, dmem_addr, dmem_width
    );

    modport mem (
        input imem_addr, imem_ren, dmem_wen, dmem_ren, dmem_store, dmem_addr, dmem_width, clk, nrst,
        output imem_load, ihit, dhit, dmem_load
    );

    // TODO Add cache interfaces, icache and dcache
    
endinterface //datapath_if

`endif // __DATAPATH_IF_VH__