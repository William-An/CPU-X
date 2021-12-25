/**
 * File name:	pc_if.svh
 * Created:	12/24/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Interface for PC
 */

`ifndef __PC_IF_SVH__
`define __PC_IF_SVH__

`include "rv32ima_pkg.svh"

interface pc_if (input clk, input nrst);
    import rv32ima_pkg::*;
    
    word_t  curr_pc;          // Current PC value
    word_t  pc_add4;     // PC + 4
    word_t  next_pc;         // Next PC to be fetch on
    logic   next_pc_en;       // Signal memory npc is valid
    word_t  branch_addr;   // Next potential branch addr
    logic   branch_addr_en; // Branch addr is valid
    logic   inst_ready;   // Instruction of current PC is ready

    modport pc (
        input clk, nrst, branch_addr, branch_addr_en, inst_ready,
        output next_pc, next_pc_en, curr_pc, pc_add4
    );

    modport tb (
        input clk, nrst, next_pc, next_pc_en, curr_pc, pc_add4,
        output branch_addr, branch_addr_en, inst_ready
    );
endinterface // pc_if

`endif // __PC_IF_SVH__