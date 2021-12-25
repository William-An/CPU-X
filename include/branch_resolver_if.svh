/**
 * File name:	branch_resolver_if.svh
 * Created:	12/24/2021
 * Author:	Weili An
 * Email:	an107@purdue.eduu
 * Version:	1.0 Initial Design Entry
 * Description:	Branch resolver
 */

`ifndef __BRANCH_RESOLVER_IF_SVH__
`define __BRANCH_RESOLVER_IF_SVH__

`include "rv32ima_pkg.svh"

interface branch_resolver_if;
    import rv32ima_pkg::*;

    bcontrol_t control_type;
    word_t  jump_addr;
    word_t  branch_addr; 
    logic   zero;
    logic   neg;
    word_t  next_addr;
    word_t  next_addr_en;
    // TODO What if overflow?

    modport br (
        input control_type, jump_addr, branch_addr, zero, neg,
        output next_addr, next_addr_en
    );

    modport tb (
        input next_addr, next_addr_en,
        output control_type, jump_addr, branch_addr, zero, neg
    );
    
endinterface //branch_resolver_if

`endif // __BRANCH_RESOLVER_IF_SVH__