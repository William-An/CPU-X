/**
 * File name:	system_if.svh
 * Created:	12/25/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Wrapper interface to access system
 */

`ifndef __SYSTEM_IF_SVH__
`define __SYSTEM_IF_SVH__

`include "rv32ima_pkg.svh"

interface system_if;
    import rv32ima_pkg::*;

endinterface // cpu_ram_if

`endif // __SYSTEM_IF_SVH__