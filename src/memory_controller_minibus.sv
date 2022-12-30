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
    
    // TODO Arbiter irequest and datarequest
    // TODO Make a state machine
    always_comb begin: ARIBITER
        // Just some initial setup to avoid latches
        _dpif.imem_load = '0;
        _dpif.ihit = 1'b0;
        _dpif.dhit = 1'b0;
        _dpif.dmem_load = '0;
        _mif.req = '0;
        _mif.req.width = _dpif.dmem_width[1:0];

        // TODO Handle response error
        if (_dpif.dmem_wen == 1'b1) begin : DATA_STORE
            // Serve ongoing store
            // TODO Issue here, comment each one of these will work
            _mif.req.addr = _dpif.dmem_addr;
            _mif.req.wdata = _dpif.dmem_store;
            _mif.req.wen = 1'b1;
        end
        else if (_dpif.dmem_ren == 1'b1) begin : DATA_LOAD
            // Serve ongoing load
            _mif.req.addr = _dpif.dmem_addr;
            _mif.req.ren = 1'b1;
        end
        else if (_dpif.imem_ren == 1'b1) begin : INST_LOAD
            // Serve ongoing fetch
            _mif.req.addr   = _dpif.imem_addr;
            _mif.req.width  = 2'b10;    // For instruction fetch, always at word alignment
            _mif.req.ren    = 1'b1;
        end

        // If slave device acknowledge, good to go 
        // but still maintain the address signals
        if (_mif.res.ack) begin : REQ_ACK
            // RAM last request is ready
            // Single port ram
            _mif.req.wen = 1'b0;
            _mif.req.ren = 1'b0;

            // Signal datapath correspondingly based on their request ENs
            if (_dpif.dmem_wen) begin
                _dpif.dhit = 1'b1;
            end
            else if (_dpif.dmem_ren) begin
                _dpif.dhit = 1'b1;
                _dpif.dmem_load = _mif.res.rdata;
            end
            else begin
                _dpif.ihit = _dpif.imem_ren;
                _dpif.imem_load = _mif.res.rdata;
            end
        end
    end
endmodule