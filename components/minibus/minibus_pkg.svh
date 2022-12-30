/*
 * File name:	minibus_pkg.svh
 * Created:	12/25/2022
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Mini bus types
*/

`ifndef __MINIBUS_PKG_VH__
`define __MINIBUS_PKG_VH__

package minibus_pkg;

// TODO Want a struct for master, slave signals
// Or interface?
// Use interface then, since we will also have a decoder unit with parameterized slave input signals
// So it will be master <---> decoder <----> slave1/2/3/4

    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 32;
    typedef struct packed {
        logic [ADDR_WIDTH - 1:0] addr_start;  // Slave memory starting address, inclusive
        logic [ADDR_WIDTH - 1:0] addr_end;    // Slave memory ending address, exclusive
    } slave_mem_map;

    typedef struct packed {
        logic [ADDR_WIDTH - 1:0]  addr;
        logic [DATA_WIDTH - 1:0]  wdata;
        logic [1:0] width;
        logic   ren;
        logic   wen;
    } minibus_req_pack;

    typedef struct packed {
        logic [DATA_WIDTH - 1:0]  rdata;
        logic   ack;
        logic   err;
    } minibus_res_pack;

    // TODO Define this later and resolve the multiple word_t definitions error
    // typedef logic [DATA_WIDTH - 1:0] word_t;
endpackage

`endif // __MINIBUS_PKG_VH__