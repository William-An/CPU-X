/*
 * File name:	csr_pkg.svh
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Bits enums for a subset of CSR registers
*/

`ifndef __CSR_PKG_VH__
`define __CSR_PKG_VH__

package csr_pkg;

// misa
localparam XLEN = 32;
localparam MISA_MXL_BIT0 = XLEN-2;
localparam MISA_MXL_BIT1 = XLEN-1;
localparam MISA_MXL_32  = 2'd1;
localparam MISA_MXL_64  = 2'd2;
localparam MISA_MXL_128 = 2'd3;
localparam MISA_EXT_A_ATOMIC_BIT = 0;
localparam MISA_EXT_B_BIT_MANI_BIT = 1;
localparam MISA_EXT_C_COMPRESSED_BIT = 2;
localparam MISA_EXT_D_DOUBLE_FLOAT_BIT = 3;
localparam MISA_EXT_E_RV32E_BIT = 4;
localparam MISA_EXT_F_SINGLE_FLOAT_BIT = 5;
localparam MISA_EXT_G_RESERVED_BIT = 6;
localparam MISA_EXT_H_HYPERVISOR_BIT = 7;
localparam MISA_EXT_I_RVIBASE_BIT = 8;
localparam MISA_EXT_J_DYNAMIC_TRANSLATED_LANGUAGE_BIT = 9;
localparam MISA_EXT_K_RESERVED_BIT = 10;
localparam MISA_EXT_L_RESERVED_BIT = 11;
localparam MISA_EXT_M_MUL_DIV_BIT = 12;
localparam MISA_EXT_N_USER_LEVEL_INT_BIT = 13;
localparam MISA_EXT_O_RESERVED_BIT = 14;
localparam MISA_EXT_P_PACKED_SIMD_BIT = 15;
localparam MISA_EXT_Q_QUAD_FLOAT_BIT = 16;
localparam MISA_EXT_R_RESERVED_BIT = 17;
localparam MISA_EXT_S_SUPERVISOR_MODE_BIT = 18;
localparam MISA_EXT_T_RESERVED_BIT = 19;
localparam MISA_EXT_U_USER_MODE_BIT = 20;
localparam MISA_EXT_V_VECTOR_BIT = 21;
localparam MISA_EXT_W_RESERVED_BIT = 22;
localparam MISA_EXT_X_NON_STANDARD_EXT_BIT = 23;
localparam MISA_EXT_Y_RESERVED_BIT = 24;
localparam MISA_EXT_Z_RESERVED_BIT = 25;

// mvendorid
localparam MVENDORID_BANK_START_BIT = 7;
localparam MVENDORID_BANK_END_BIT = 31;
localparam MVENDORID_OFFSET_START_BIT = 0;
localparam MVENDORID_OFFSET_END_BIT = 6;

// marchid: no subfield
// mimpid: no subfield
// mhartid: no subfield

// mstatus and mstatush
// privilege level encoding
localparam MSTATUS_xPP_M_MODE = 2'b11;
localparam MSTATUS_xPP_S_MODE = 2'b01;
localparam MSTATUS_xPP_U_MODE = 2'b00;
localparam MSTATUS_MPP_M = 3;
localparam MSTATUS_SD_BIT = 31;
localparam MSTATUS_TSR_BIT = 22;
localparam MSTATUS_TW_BIT = 21;
localparam MSTATUS_TVM_BIT = 20;
localparam MSTATUS_MXR_BIT = 19;
localparam MSTATUS_SUM_BIT = 18;
localparam MSTATUS_MPRV_BIT = 17;
localparam MSTATUS_XS_BIT1 = 16;
localparam MSTATUS_XS_BIT0 = MSTATUS_XS_BIT1 - 1;
localparam MSTATUS_FS_BIT1 = 14;
localparam MSTATUS_FS_BIT0 = MSTATUS_FS_BIT1 - 1;
localparam MSTATUS_MPP_BIT1 = 12;
localparam MSTATUS_MPP_BIT0 = MSTATUS_MPP_BIT1 - 1;
localparam MSTATUS_VS_BIT1 = 10;
localparam MSTATUS_VS_BIT0 = MSTATUS_VS_BIT1 - 1;
localparam MSTATUS_SPP_BIT = 8;
localparam MSTATUS_MPIE_BIT = 7;
localparam MSTATUS_UBE_BIT = 6;
localparam MSTATUS_SPIE_BIT = 5;
localparam MSTATUS_MIE_BIT = 3;
localparam MSTATUS_SIE_BIT = 1;

localparam MSTATUSH_MBE_BIT = 5;
localparam MSTATUSH_SBE_BIT = 4;

// mtvec
localparam MTVEC_BASE_START_BIT = 2;
localparam MTVEC_BASE_END_BIT = XLEN - 1;
localparam MTVEC_MODE_BIT1 = 1;
localparam MTVEC_MODE_BIT0 = 0;
localparam MTVEC_MODE_DIRECT = 0;
localparam MTVEC_MODE_VECTORED = 1;

// medeleg and mideleg has no subfield

// mip and mie: interrupt pending and enable registers
localparam MIP_MEIP_BIT = 11;
localparam MIP_SEIP_BIT = 9;
localparam MIP_MTIP_BIT = 7;
localparam MIP_STIP_BIT = 5;
localparam MIP_MSIP_BIT = 3;
localparam MIP_SSIP_BIT = 1;

localparam MIE_MEIE_BIT = 11;
localparam MIE_SEIE_BIT = 9;
localparam MIE_MTIE_BIT = 7;
localparam MIE_STIE_BIT = 5;
localparam MIE_MSIE_BIT = 3;
localparam MIE_SSIE_BIT = 1;

// NOTE: mcycle, minstret, mcounteren, mhpmcounterX, mcountinhibit all not implemented yet

// mscratch, mepc, mtval has no subfield

// mcause
localparam MCAUSE_EXCEPTION_CODE_START_BIT = 0;
localparam MCAUSE_EXCEPTION_CODE_END_BIT = XLEN - 2;
localparam MCAUSE_INT_BIT = XLEN - 1;

localparam MCAUSE_CODE_INTERRUPT_SUPERVISOR_SOFTWARE = 1;
localparam MCAUSE_CODE_INTERRUPT_MACHINE_SOFTWARE = 3;
localparam MCAUSE_CODE_INTERRUPT_SUPERVISOR_TIMER = 5;
localparam MCAUSE_CODE_INTERRUPT_MACHINE_TIMER = 7;
localparam MCAUSE_CODE_INTERRUPT_SUPERVISOR_EXTERNAL = 9;
localparam MCAUSE_CODE_INTERRUPT_MACHINE_EXTERNAL = 11;

localparam MCAUSE_CODE_EXCEPTION_INST_ADDR_MISALIGN = 0;
localparam MCAUSE_CODE_EXCEPTION_INST_ACCESS_FAULT = 1;
localparam MCAUSE_CODE_EXCEPTION_INST_ILLEGAL = 2;
localparam MCAUSE_CODE_EXCEPTION_BREAKPOINT = 3;
localparam MCAUSE_CODE_EXCEPTION_LOAD_ADDR_MISALIGN = 4;
localparam MCAUSE_CODE_EXCEPTION_LOAD_ACCESS_FAULT = 5;
localparam MCAUSE_CODE_EXCEPTION_STORE_AMO_ADDR_MISALIGN = 6;
localparam MCAUSE_CODE_EXCEPTION_STORE_AMO_ACCESS_FAULT = 7;
localparam MCAUSE_CODE_EXCEPTION_ENVIRONMENT_CALL_U_MODE = 8;
localparam MCAUSE_CODE_EXCEPTION_ENVIRONMENT_CALL_S_MODE = 9;
localparam MCAUSE_CODE_EXCEPTION_ENVIRONMENT_CALL_M_MODE = 11;
localparam MCAUSE_CODE_EXCEPTION_INST_PAGE_FAULT = 12;
localparam MCAUSE_CODE_EXCEPTION_LOAD_PAGE_FAULT = 13;
localparam MCAUSE_CODE_EXCEPTION_STORE_AMO_PAGE_FAULT = 15;

// menvcfg and menvcfgh not implemented since no U-mode

endpackage

`endif // __CSR_PKG_VH__