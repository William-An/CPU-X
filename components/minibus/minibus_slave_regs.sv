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
    output logic [REGS_COUNT - 1:0][DATA_WIDTH - 1:0] outputs
);
    localparam REGS_ADDR_WIDTH = $clog2(REGS_COUNT) + 1;
    logic [REGS_COUNT - 1:0][DATA_WIDTH - 1:0] regs, next_regs;
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

        casez ({_slaveif.sel, _slaveif.req.wen, _slaveif.req.ren, _slaveif.nrst})
            4'b0???: begin
                // If not selected, do nothing
                n_rdy = 1'b0;
            end
            4'b1101: begin
                // Prepare to perform register writes
                n_rdy = ~rdy;
                casez (_slaveif.req.width[1:0])
                    2'b00: begin
                        // Byte write
                        logic [DATA_WIDTH - 1:0] old_data;
                        logic [DATA_WIDTH - 1:0] new_data;
                        // Use REGS_ADDR_WIDTH + 1 as register are word aligned while
                        // incomign address is byte aligned
                        old_data = regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]];
                        // Figure out the byte offset
                        casez (_slaveif.req.addr[1:0])
                            2'b00: new_data = {old_data[31:8], _slaveif.req.wdata[7:0]};
                            2'b01: new_data = {old_data[31:16], _slaveif.req.wdata[7:0], old_data[7:0]};
                            2'b10: new_data = {old_data[31:24], _slaveif.req.wdata[7:0], old_data[15:0]};
                            2'b11: new_data = {_slaveif.req.wdata[7:0], old_data[23:0]};
                        endcase
                        next_regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]] = new_data;
                    end
                    2'b01: begin
                        // Half word write
                        logic [DATA_WIDTH - 1:0] old_data;
                        logic [DATA_WIDTH - 1:0] new_data;
                        old_data = regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]];
                        casez (_slaveif.req.addr[1])
                            2'b00: new_data = {old_data[31:16], _slaveif.req.wdata[15:0]};
                            2'b01: new_data = {_slaveif.req.wdata[15:0], old_data[15:0]};
                        endcase
                        next_regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]] = new_data;
                    end
                    2'b10: begin
                        // Full word write
                        next_regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]] = _slaveif.req.wdata;
                    end
                    default: begin
                        n_err = 1'b1;
                    end
                endcase
            end
            4'b1011: begin
                // Prepare to perform register reads
                // Cache the register data to output at DATA phase
                n_rdy = ~rdy;
                casez (_slaveif.req.width[1:0])
                    2'b00: begin
                        // Byte read
                        casez (_slaveif.req.addr[1:0])
                            2'b00: n_rdata[7:0] = regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]][7:0];
                            2'b01: n_rdata[7:0] = regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]][15:8];
                            2'b10: n_rdata[7:0] = regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]][23:16];
                            2'b11: n_rdata[7:0] = regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]][31:24];
                        endcase
                    end
                    2'b01: begin
                        // Half word read
                        casez (_slaveif.req.addr[1])
                            2'b00: n_rdata[15:0] = regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]][15:0];
                            2'b01: n_rdata[15:0] = regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]][31:16];
                        endcase
                    end
                    2'b10: begin
                        // Full word read
                        n_rdata = regs[_slaveif.req.addr[REGS_ADDR_WIDTH + 1:2]];
                    end
                    default: begin
                        n_err = 1'b1;
                    end
                endcase
            end
            default: begin
                n_rdy = 1'b0;
            end
        endcase

        // If ram ready and this device is selected, we acknowledges
        _slaveif.res.ack = rdy & _slaveif.sel;
        _slaveif.res.err = err;
        _slaveif.res.rdata = rdata;
    end

endmodule