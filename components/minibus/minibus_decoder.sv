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
    SLAVE_COUNT = 4
) (
    minibus_master_if.decoder _masterif,
    minibus_slave_if.decoder _slaveifs [SLAVE_COUNT],
    input slave_mem_map [SLAVE_COUNT-1:0] slavemmaps
);
    // multiplex signals based on slavemmaps, assuming the
    // slavemmaps is of increasing order (i.e. slave[0] has lower addr than slave[1])
    generate
        genvar i;
        for (i = 0; i < SLAVE_COUNT; i++) begin : MINIBUS_GEN
            always_comb begin : MINIBUS_SLAVE_HANDLE
                _slaveifs[i].sel = 1'b0;
                _slaveifs[i].req = _masterif.req;

                // Cannot assign to zeros?
                _masterif.res = _slaveifs[0].res;

                if ((_masterif.req.addr >= slavemmaps[i].addr_start) &&
                    (_masterif.req.addr <  slavemmaps[i].addr_end)) begin
                    _slaveifs[i].sel = 1'b1;
                    _masterif.res = _slaveifs[i].res;
                end
            end
        end
    endgenerate
endmodule