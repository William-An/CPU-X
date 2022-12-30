/**
 * File name:	minibus_decoder.svh
 * Created:	12/25/2022
 * Author:	Weili An
 * Email:	an107@purdue.eduu
 * Version:	1.0 Initial Design Entry
 * Description: Mini bus decoder, handling slave signals multiplexing
 *              and map memory control
 */

`include "minibus_pkg.svh"
`include "minibus_master_if.svh"
`include "minibus_slave_if.svh"

import minibus_pkg::*;

module minibus_decoder #(
    SLAVE_COUNT = 4,
    slave_mem_map SLAVEMMAPS [SLAVE_COUNT]
) (
    minibus_master_if.decoder _masterif,
    minibus_slave_if.decoder _slaveifs [SLAVE_COUNT]
);
    // multiplex signals based on SLAVEMMAPS, assuming the
    // SLAVEMMAPS is of increasing order (i.e. slave[0] has lower addr than slave[1])

    // Map slave device response to a local array so that we can use
    // non-genvar index to access them
    // See https://stackoverflow.com/a/33614997/6904794
    // Basically to bypass the constraint that interface array can only be accessed
    // with constant index like genvar
    minibus_res_pack response_map [SLAVE_COUNT];
    generate
        genvar i;
        for (i = 0; i < SLAVE_COUNT; i++) begin: RES_PACKET_MAP
            assign response_map[i] = _slaveifs[i].res;
        end
    endgenerate

    // Handle master device response multiplexing
    // Based on request address, map master response packet to
    // one of the slave devices
    always_comb begin : MINIBUS_MASTER_HANDLE
        // Cannot assign to zeros?
        _masterif.res = _slaveifs[0].res;
        for (int unsigned k = 0; k < SLAVE_COUNT; k++) begin
            if ((_masterif.req.addr >= SLAVEMMAPS[k].addr_start) &&
                (_masterif.req.addr <  SLAVEMMAPS[k].addr_end)) begin

                // TODO Start with here? If set constant to 0
                // the code will not stuck in comb loop
                _masterif.res = response_map[k];
            end
        end
    end

    // Handle Slave device signals with generate block
    // Let all slave devices listen on master request
    // And select one of them based on request address
    generate
        genvar j;
        for (j = 0; j < SLAVE_COUNT; j++) begin : MINIBUS_SLAVE_HANDLE
            assign _slaveifs[j].req = _masterif.req;
            assign _slaveifs[j].sel = ((_masterif.req.addr >= SLAVEMMAPS[j].addr_start) &&
                                       (_masterif.req.addr <  SLAVEMMAPS[j].addr_end)) ? 1'b1 : 1'b0;
        end
    endgenerate
endmodule