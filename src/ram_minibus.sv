/**
 * File name:	ram_minibus.sv
 * Created:	12/26/2022
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Onchip RAM minibus interface
 */

`include "cpu_ram_if.svh"
`include "rv32ima_pkg.svh"
`include "minibus/minibus_slave_if.svh"

module ram_minibus (
    minibus_slave_if.slave _sif
);
    import rv32ima_pkg::*;

    logic [3:0] byteen;
    logic ram_rdy, n_ram_rdy;

    always_ff @(posedge _sif.clk, negedge _sif.nrst) begin
        if (_sif.nrst == 1'b0) begin
            ram_rdy <= '0;
        end
        else begin
            ram_rdy <= n_ram_rdy;
        end
    end

    always_comb begin: RAM_NEXT
        n_ram_rdy = 1'b0;
        _sif.res.err = 1'b0;

        casez ({_sif.req.wen, _sif.req.ren, _sif.nrst})
            3'b00?: begin
                // If no EN signals, the RAM is free to access
                n_ram_rdy = 1'b0;
            end
            3'b101,
            3'b011: begin
                // Ram will ready in next cycle
                n_ram_rdy = 1'b1;
            end
            default: begin
                n_ram_rdy = 1'b0;
            end
        endcase

        // If ram ready, we acknowledge
        _sif.res.ack = ram_rdy & _sif.sel;
    end

    always_comb begin: BYTE_EN_MUX
        casez (_sif.req.width[1:0])
			2'b00: byteen = 4'b1 << _sif.req.addr[1:0];
			2'b01: byteen = 4'b11 << {_sif.req.addr[1], 1'b0};
			2'b10: byteen = 4'b1111;
			default: byteen = 4'b1111;
		endcase
    end

    ram_internal ram_raw0(
        .address(_sif.req.addr[BIT_WIDTH - 1:2]),
        .clock(_sif.clk),
        .data(_sif.req.wdata),
        .wren(_sif.req.wen),
        .byteena(byteen),
        .q(_sif.res.rdata)
    );

    
endmodule