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

module ram #(
    REORDER_DATA = 1'b0,
    LAT = 4'b0
) (
    cpu_ram_if.ram _if
);
    import rv32ima_pkg::*;

    logic [3:0] byteen;
    logic [3:0] lat_count, next_lat_count;
    word_t tmp_data;
    logic ram_rdy, n_ram_rdy;

    // Simple 
    always_ff @(posedge _if.ram_clk, negedge _if.nrst) begin
        if (_if.nrst == 1'b0) begin
            ram_rdy <= '0;
            lat_count <= '0;
        end
        else begin
            ram_rdy <= n_ram_rdy;
            lat_count <= next_lat_count;
        end
    end

    always_comb begin: RAM_NEXT
        next_lat_count = lat_count;
        n_ram_rdy = ram_rdy;

        _if.ram_load = 32'hdeadbeef;
        // RAM state logic
        if (ram_rdy && lat_count >= LAT) begin
            // If we have ram ready, means we are in an ongoing request
            // If the the latency is reached, we are good to send the data
            _if.ram_state = RAM_DATA;
            n_ram_rdy = 1'b0;
            next_lat_count = '0;
            _if.ram_load = REORDER_DATA == 1'b1 ? {tmp_data[7:0], tmp_data[15:8], tmp_data[23:16], tmp_data[31:24]} : tmp_data;
        end
        else begin
            casez ({_if.ram_wen, _if.ram_ren, _if.nrst})
                3'b00?: begin
                    // If no EN signals, the RAM is free to access
                    _if.ram_state = RAM_FREE;
                end
                3'b101,
                3'b011: begin
                    // Increment lat count to simulat multiple cycles ram
                    // If the EN signals are up, still in addressing state
                    // If the EN signals are up, we could serve the data in next cycle
                    _if.ram_state = RAM_ADDR;
                    next_lat_count = lat_count + 4'b1;
                    n_ram_rdy = 1'b1;
                end
                default: begin
                    _if.ram_state = RAM_ERROR;
                end
            endcase
        end
    end

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
        .address(_if.ram_addr[BIT_WIDTH - 1:2]),
        .clock(_if.ram_clk),
        .data(_if.ram_store),
        .wren(_if.ram_wen),
        .byteena(byteen),
        .q(tmp_data)
    );

    
endmodule