/**
 * File name:	ram.sv
 * Created:	12/24/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Wrapper module with internal ram implementation
 */

`include "cpu_ram_if.svh"
`include "rv32ima_pkg.svh"

module ram (
    cpu_ram_if.ram _if
);
    import rv32ima_pkg::*;
    // TODO: can implement both on-chip ram and off-chip ram?

    ram_internal ram_raw0(
        .address(_if.ram_addr),
        .clock(_if.ram_clk),
        .data(_if.ram_store),
        .wren(_if.ram_wen),
        .q(_if.ram_load)
    );
    
endmodule