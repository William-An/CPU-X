/**
 * File name:	minibus_slave_if.svh
 * Created:	12/25/2022
 * Author:	Weili An
 * Email:	an107@purdue.eduu
 * Version:	1.0 Initial Design Entry
 * Description: Mini bus slave interface
 */

`ifndef __MINIBUS_SLAVE_IF_VH__
`define __MINIBUS_SLAVE_IF_VH__

`include "minibus_pkg.svh"

import minibus_pkg::*;

interface minibus_slave_if;
    logic clk, nrst, sel;
    minibus_req_pack req;
    minibus_res_pack res;

    modport slave (
        input clk, nrst, req, sel,
        output res
    );

    modport decoder (
        input res,
        output sel, req
    );

endinterface

`endif // __MINIBUS_SLAVE_IF_VH__
