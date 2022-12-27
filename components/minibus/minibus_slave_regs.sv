/**
 * File name:	minibus_slave_regs.svh
 * Created:	12/26/2022
 * Author:	Weili An
 * Email:	an107@purdue.eduu
 * Version:	1.0 Initial Design Entry
 * Description: Mini bus generic slave register array
 */

`include "minibus_pkg.svh"
`include "minibus_master_if.svh"
`include "minibus_slave_if.svh"

import minibus_pkg::*;

module minibus_slave_regs #(
    REGS_COUNT = 4
) (
    minibus_slave_if.slave _slaveif,
    output logic [DATA_WIDTH - 1:0][REGS_COUNT - 1:0] outputs
);
    logic [DATA_WIDTH - 1:0][REGS_COUNT - 1:0] regs, next_regs;
    logic rdy, n_rdy;
    logic err, n_err;
    logic [DATA_WIDTH - 1:0] rdata, n_rdata;

    always_ff @(posedge _slaveif.clk, negedge _slaveif.nrst) begin
        if (_slaveif.nrst == 1'b0) begin
            regs <= '0;
            rdy <= 1'b0;
            err <= 1'b0;
            rdata <= '0;
        end
        else begin
            regs <= next_regs;
            rdy <= n_rdy;
            err <= n_err;
            rdata <= n_rdata;
        end
    end

    always_comb begin
        n_rdy = 1'b0;
        n_err = 1'b0;
        n_rdata = '0;
        next_regs = regs;
        outputs = regs;
        _sif.res = '0;

        casez ({_sif.req.wen, _sif.req.ren, _sif.nrst})
            3'b00?: begin
                // If no EN signals, the regs are free
                n_rdy = 1'b0;
            end
            3'b101: begin
                // Prepare to perform register writes
                n_rdy = 1'b1;
                casez (_sif.req.width[1:0])
                    2'b00: begin
                        // Byte write
                        logic [DATA_WIDTH - 1:0] old_data;
                        logic [DATA_WIDTH - 1:0] new_data;
                        old_data = regs[_sif.req.addr[ADDR_WIDTH-1:2]];
                        casez (_sif.req.addr[1:0])
                            2'b00: new_data = {old_data[31:8], _sif.req.wdata[7:0]};
                            2'b01: new_data = {old_data[31:16], _sif.req.wdata[7:0], old_data[7:0]};
                            2'b10: new_data = {old_data[31:24], _sif.req.wdata[7:0], old_data[15:0]};
                            2'b11: new_data = {_sif.req.wdata[7:0], old_data[23:0]};
                        endcase
                        next_regs[_sif.req.addr[ADDR_WIDTH-1:2]] = new_data;
                    end
                    2'b01: begin
                        // Half word write
                        logic [DATA_WIDTH - 1:0] old_data;
                        logic [DATA_WIDTH - 1:0] new_data;
                        old_data = regs[_sif.req.addr[ADDR_WIDTH-1:2]];
                        casez (_sif.req.addr[1])
                            2'b00: new_data = {old_data[31:16], _sif.req.wdata[15:0]};
                            2'b01: new_data = {_sif.req.wdata[15:0], old_data[15:0]};
                        endcase
                        next_regs[_sif.req.addr[ADDR_WIDTH-1:2]] = new_data;
                    end
                    2'b10: begin
                        // Full word write
                        next_regs[_sif.req.addr[ADDR_WIDTH-1:2]] = _sif.req.wdata;
                    end
                    default: begin
                        n_err = 1'b1;
                    end
                endcase
            end
            3'b011: begin
                // Prepare to perform register reads
                // Cache the register data to output at DATA phase
                n_rdy = 1'b1;
                
                // Just return the whole word now as master device will resolve for now
                // TODO Remove the offset information in Mini-Bus data signals
                n_rdata = regs[_sif.req.addr[ADDR_WIDTH-1:2]];
            end
            default: begin
                n_rdy = 1'b0;
            end
        endcase

        // If ram ready and this device is selected, we acknowledge
        if (rdy && _sif.sel) begin
            _sif.res.ack = 1'b1;
            _sif.res.err = err;
            _sif.res.rdata = rdata;
        end
    end

endmodule