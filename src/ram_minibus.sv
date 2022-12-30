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
    word_t data_write;
    word_t tmp_data;

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
        _sif.res.rdata = '0;

        // Ram rdy signals
        casez ({_sif.sel, _sif.req.wen, _sif.req.ren, _sif.nrst})
            4'b0???: begin
                // If no EN signals, the RAM is free to access
                n_ram_rdy = 1'b0;
            end
            4'b1101,
            4'b1011: begin
                // Ram will ready in next cycle
                n_ram_rdy = ~ram_rdy; // 1'b1;
            end
            default: begin
                n_ram_rdy = 1'b0;
            end
        endcase

        // Prepare byteen and data to write into the RAM
        // Also prepare the data read result
        casez (_sif.req.width[1:0])
			2'b00: begin 
                word_t tmp;
                byteen = 4'b1 << _sif.req.addr[1:0];
                data_write = _sif.req.wdata[7:0] << {_sif.req.addr[1:0], 3'b0};
                tmp = tmp_data >> {_sif.req.addr[1:0], 3'b0};
                _sif.res.rdata[7:0] = tmp[7:0];
                // casez (_slaveif.req.addr[1:0])
                //     2'b00: _sif.res.rdata[7:0] = tmp_data[7:0];
                //     2'b01: _sif.res.rdata[7:0] = tmp_data[15:8];
                //     2'b10: _sif.res.rdata[7:0] = tmp_data[23:16];
                //     2'b11: _sif.res.rdata[7:0] = tmp_data[31:24];
                // endcase
            end
			2'b01: begin
                word_t tmp;
                byteen = 4'b11 << {_sif.req.addr[1], 1'b0};
                data_write = _sif.req.wdata[15:0] << {_sif.req.addr[1], 4'b0};
                tmp = tmp_data >> {_sif.req.addr[1], 4'b0};
                _sif.res.rdata[15:0] = tmp[15:0];
            end
			2'b10: begin
                byteen = 4'b1111;
                data_write = _sif.req.wdata;
                _sif.res.rdata = tmp_data;
            end
			default: begin
                // Do not perform write
                // TODO Raise error
                byteen = 4'b0;
                data_write = _sif.req.wdata;
                _sif.res.rdata = '0;
            end
		endcase

        // If ram ready, we acknowledge
        _sif.res.ack = ram_rdy & _sif.sel;
    end

    ram_internal ram_raw0(
        .address(_sif.req.addr[BIT_WIDTH - 1:2]),
        .clock(_sif.clk),
        .data(data_write),
        // Don't write until the device is selected
        // Read should be safe
        .wren(_sif.req.wen & _sif.sel),
        .byteena(byteen),
        .q(tmp_data)
    );

    
endmodule