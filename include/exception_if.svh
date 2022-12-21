/**
 * File name:	exception_if.svh
 * Created:	12/19/2022
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Interface for exception signals
 */

`ifndef __EXCEPTION_IF_SVH__
`define __EXCEPTION_IF_SVH__

`include "rv32ima_pkg.svh"

interface exception_if;
    import rv32ima_pkg::*;

    logic inst_addr_misalign_flag;
    logic load_addr_misalign_flag;
    logic store_amo_addr_misalign_flag;
    logic inst_illegal_flag;
    logic ebreak_flag;
    logic ecall_flag;
    word_t current_pc;          // Used to set epc register if necessary

    word_t epc_value;           // PC of the exception instruction
    word_t trap_handler_addr;   // from mtvec
    logic trap_enable;          // ORing all the flags

    // Module that produce these signals for exception handling
    modport publisher (output   inst_addr_misalign_flag,
                                load_addr_misalign_flag,
                                store_amo_addr_misalign_flag,
                                inst_illegal_flag,
                                ebreak_flag,
                                ecall_flag,
                                current_pc);

    // Module that use the signals and process them
    modport subscriber (input   inst_addr_misalign_flag,
                                load_addr_misalign_flag,
                                store_amo_addr_misalign_flag,
                                inst_illegal_flag,
                                ebreak_flag,
                                ecall_flag,
                                current_pc,
                        output  epc_value,
                                trap_handler_addr,
                                trap_enable);
    
    // Module that consume the processed signals
    modport consumer (input     epc_value,
                                trap_handler_addr,
                                trap_enable);
endinterface //exception_if

`endif // __EXCEPTION_IF_SVH__