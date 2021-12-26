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

    logic [3:0] byteen;

    always_comb begin: BYTE_EN_MUX
        casez (_if.ram_width[1:0])
            2'b00: byteen = 4'b0001;
            2'b01: byteen = 4'b0011;
            2'b10: byteen = 4'b1111;
            default: byteen = 4'b1111;
        endcase
    end

    // TODO: can implement both on-chip ram and off-chip ram?
    // TODO: reorder the little-endian data
    ram_internal ram_raw0(
        .address(_if.ram_addr),
        .clock(_if.ram_clk),
        .data(_if.ram_store),
        .wren(_if.ram_wen),
        .byteena(byteen),
        .q(_if.ram_load)
    );
    
endmodule