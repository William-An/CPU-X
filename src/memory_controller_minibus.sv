/**
 * File name:	memory_controller.svh
 * Created:	12/25/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Controller responsible for communicating with ram
 */

`include "datapath_if.svh"
`include "minibus/minibus_master_if.svh"
`include "rv32ima_pkg.svh"

module memory_controller_minibus (
    datapath_if.mem _dpif,
    minibus_master_if.master  _mif
);
    import rv32ima_pkg::*;

    typedef enum logic [1:0] { 
        FREE,
        BUS_OP,
        READY
    } mem_control_state_t;

    mem_control_state_t state, n_state;
    minibus_req_pack cached_req, n_cached_req;
    minibus_res_pack cached_res, n_cached_res;

    always_ff @( posedge _mif.clk, negedge _mif.nrst ) begin : STATE
        if (_mif.nrst == 1'b0) begin
            state <= FREE;
            cached_req <= '0;
            cached_res <= '0;
        end
        else begin
            state <= n_state;
            cached_req <= n_cached_req;
            cached_res <= n_cached_res;
        end
    end

    always_comb begin : NEXT_LOGIC
        n_state = state;
        n_cached_req = cached_req;
        n_cached_res = cached_res;
        casez (state) 
            FREE: begin
                if (_dpif.dmem_wen == 1'b1) begin : DATA_STORE
                    // Serve ongoing store
                    // TODO Issue here, comment each one of these will work
                    n_cached_req.addr   = _dpif.dmem_addr;
                    n_cached_req.wdata  = _dpif.dmem_store;
                    n_cached_req.width  = _dpif.dmem_width[1:0];
                    n_cached_req.wen    = 1'b1;
                    n_state = BUS_OP;
                end
                else if (_dpif.dmem_ren == 1'b1) begin : DATA_LOAD
                    // Serve ongoing load
                    n_cached_req.addr   = _dpif.dmem_addr;
                    n_cached_req.width  = _dpif.dmem_width[1:0];
                    n_cached_req.ren    = 1'b1;
                    n_state = BUS_OP;
                end
                else if (_dpif.imem_ren == 1'b1) begin : INST_LOAD
                    // Serve ongoing fetch
                    n_cached_req.addr   = _dpif.imem_addr;
                    n_cached_req.width  = 2'b10;    // For instruction fetch, always at word alignment
                    n_cached_req.ren    = 1'b1;
                    n_state = BUS_OP;
                end
            end
            BUS_OP: begin
                // Maintain state until ack
                if (_mif.res.ack) begin
                    n_cached_req = '0;
                    n_cached_res = _mif.res;
                    n_state = READY;
                end
            end
            READY: begin
                // Stay in READY state until datapath is not issuing
                // if ((_dpif.dmem_wen == 1'b0) && 
                    // (_dpif.dmem_ren == 1'b0) &&
                    // (_dpif.imem_ren == 1'b0)) begin
                    n_cached_res = '0;
                    n_state = FREE;
                // end
            end
            default: begin
                // TODO Raise error?
                n_state = FREE;
                n_cached_res = '0;
                n_cached_req = '0;
            end
        endcase
    end

    always_comb begin: OUTPUT
        // Just some initial setup to avoid latches
        _dpif.imem_load = '0;
        _dpif.ihit = 1'b0;
        _dpif.dhit = 1'b0;
        _dpif.dmem_load = '0;
        _mif.req = '0;

        casez(state)
            FREE: begin
                // Do nothing since we either not finish BUS op or don't have
                // Ongoing transcation
            end
            BUS_OP: begin
                // Use registered request
                _mif.req = cached_req;
                
                // TODO If this is causing problem, remove it
                // if (_mif.res.ack) begin
                //     _mif.req.wen = 1'b0;
                //     _mif.req.ren = 1'b0;
                // end
            end
            READY: begin
                // Signal datapath correspondingly based on their request ENs
                if (_dpif.dmem_wen) begin
                    _dpif.dhit = 1'b1;
                end
                else if (_dpif.dmem_ren) begin
                    _dpif.dhit = 1'b1;
                    _dpif.dmem_load = cached_res.rdata;
                end
                else begin
                    _dpif.ihit = _dpif.imem_ren;
                    _dpif.imem_load = cached_res.rdata;
                end
            end
            default: begin
            end
        endcase
    end
endmodule