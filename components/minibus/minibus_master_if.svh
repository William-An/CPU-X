/**
 * File name:	minibus_master_if.svh
 * Created:	12/25/2022
 * Author:	Weili An
 * Email:	an107@purdue.eduu
 * Version:	1.0 Initial Design Entry
 * Description: Mini bus master interface
 */

`ifndef __MINIBUS_MASTER_IF_VH__
`define __MINIBUS_MASTER_IF_VH__

`include "minibus_pkg.svh"

import minibus_pkg::*;

interface minibus_master_if (input logic clk, input logic nrst);
    minibus_req_pack req;
    minibus_res_pack res;

    modport master (
        input clk, nrst, res,
        output req
    );

    modport decoder (
        input req,
        output res
    );

endinterface

`endif // __MINIBUS_MASTER_IF_VH__
