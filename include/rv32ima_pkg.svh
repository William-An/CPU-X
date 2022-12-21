/*
 * File name:	rv32ima_pkg.svh
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Types for RV32IMA implementation, based on riscv-opcodes repo
*/

`ifndef __RV32IMA_PKG_VH__
`define __RV32IMA_PKG_VH__

package rv32ima_pkg;
    // Instruction field bit width
    localparam INST_W = 32;
    localparam OP_W = 7;
    localparam REG_W = 5;
    localparam FUNCT3_W = 3;
    localparam LDST_WIDTH_W = FUNCT3_W;
    localparam FUNCT5_W = 5;
    localparam FUNCT7_W = 7;
    localparam FUNCT12_W = 12;
    localparam BIT_WIDTH = 32;
    
    // ALU Op bit width
    localparam ALUOP_W = 5;

    typedef logic [REG_W - 1:0] reg_t;
    typedef logic [BIT_WIDTH - 1:0] word_t;

    // TODO Extend and implement hardware counters for inst count?
    typedef enum logic [2:0] { 
        RTYPE,
        ITYPE,
        STYPE,
        BTYPE,
        UTYPE,
        JTYPE
    } inst_t;

    typedef enum logic [OP_W - 1:0] { 
        LOAD        = 7'b0000011,
        MISC_MEM    = 7'b0001111,
        OP_IMM      = 7'b0010011, 
        AUIPC       = 7'b0010111, 
        STORE       = 7'b0100011,
        AMO         = 7'b0101111,
        OP          = 7'b0110011,
        LUI         = 7'b0110111, 
        OP_32       = 7'b0111011,
        BRANCH      = 7'b1100011,
        JALR        = 7'b1100111,
        JAL         = 7'b1101111,
        SYSTEM      = 7'b1110011
    } opcode_t;

    // I-type and R-type instruction funct3 enums
    localparam FUNCT3_START = 12;
    typedef enum logic [FUNCT3_W - 1:0] { 
        ADD     = 3'b000,   // Same as JALR and SUB (use imm[11:5] for differentiation)
        SLL     = 3'b001,
        SLT     = 3'b010,
        SLTU    = 3'b011,
        XOR     = 3'b100,
        SR      = 3'b101,   // SRL and SRA share the same funct3 and use imm[11:5] for differentiation
        OR      = 3'b110,
        AND     = 3'b111
    } funct3_t;

    // System funct3 type
    typedef enum logic [FUNCT3_W - 1:0] { 
        PRIV        = 3'b000,
        CSRRW       = 3'b001,
        CSRRS       = 3'b010,
        CSRRC       = 3'b011,
        PRIVM       = 3'b100,
        CSRRWI      = 3'b101,
        CSRRSI      = 3'b110,
        CSRRCI      = 3'b111
    } system_funct3_t;

    // System PRIV instructions funct12
    typedef enum logic [FUNCT12_W - 1:0] { 
        ECALL        = 12'b000000000000,
        EBREAK       = 12'b000000000001
    } system_funct12_t;

    // Load and store width funct3
    typedef enum logic [LDST_WIDTH_W - 1:0] { 
        LDST_BYTE  = 3'b000,
        LDST_HALF  = 3'b001,    // Signed extend byte for load
        LDST_WORD  = 3'b010,    // Signed extend half word for load
        LDST_UBYTE = 3'b100,    // Unsigned extend byte for load
        LDST_UHALF = 3'b101     // Unsigned extend half word for load
    } ldst_width_t;

    // B-type instruction funct3 enums
    typedef enum logic [FUNCT3_W - 1:0] { 
        BEQ     = 3'b000,
        BNE     = 3'b001,
        BLT     = 3'b100,
        BGE     = 3'b101,
        BLTU    = 3'b110,
        BGEU    = 3'b111
    } bfunct3_t;

    // Control type of the instruction
    typedef struct packed {
        logic is_branch;
        logic is_jump;
        bfunct3_t branch_type;
    } bcontrol_t;

    // R-type instruction funct7 enums
    localparam FUNCT7_START = 25;
    localparam MEXT_BIT     = 0;
    localparam ALTERN_BIT   = 5;
    typedef enum logic [FUNCT7_W - 1:0] { 
        BASE    = 7'b0000000,
        MEXT    = 7'b0000001,   // RV32M extension
        ALTERN  = 7'b0100000    // Perform alternate function
    } funct7_t;

    // A-extension funct5 enums
    // TODO can use wildcard ? to merge with the funct7 enum?
    // TODO like: AMOADD  = 7'b00000??,
    localparam FUNCT5_START = 27;
    typedef enum logic [FUNCT5_W - 1:0] {
        AMOADD  = 5'b00000,
        AMOSWAP = 5'b00001,
        LR      = 5'b00010,
        SC      = 5'b00011,
        AMOXOR  = 5'b00100,
        AMOOR   = 5'b01000,
        AMOAND  = 5'b01100,
        AMOMIN  = 5'b10000,
        AMOMAX  = 5'b10100,
        AMOMINU = 5'b11000,
        AMOMAXU = 5'b11100
    } funct5_t;

    // ALU Op, aligned with funct3 with the MSB specify alternative function
    // alu_op[2:0]  = funct3
    // alu_op[3]    = Alternative function?
    // alu_op[4]    = M-extension?
    typedef enum logic [ALUOP_W - 1:0] { 
        ALU_ADD     = 5'b00000,
        ALU_SUB     = 5'b01000,
        ALU_SLL     = 5'b00001, 
        ALU_SLT     = 5'b00010, 
        ALU_SLTU    = 5'b00011, 
        ALU_XOR     = 5'b00100,
        ALU_SRL     = 5'b00101, 
        ALU_SRA     = 5'b01101, 
        ALU_OR      = 5'b00110,
        ALU_AND     = 5'b00111, 

        // M-extension 
        ALU_MUL     = 5'b10000, 
        ALU_MULH    = 5'b10001,     // rs1, rs2: signed, return upper bits
        ALU_MULHSU  = 5'b10010,     // rs1: ssigned, rs2: unsigned
        ALU_MULHU   = 5'b10011,     // rs1, rs2: unsigned
        ALU_DIV     = 5'b10100, 
        ALU_DIVU    = 5'b10101,     // Unsigned division
        ALU_REM     = 5'b10110,
        ALU_REMU    = 5'b10111      // Unsigned modulo
    } aluop_t;

    // Instruction type struct definition
    // R-type
    typedef struct packed {
        funct7_t funct7;
        reg_t    rs2;
        reg_t    rs1;
        funct3_t funct3;
        reg_t    rd;
        opcode_t opcode;
    } r_type;

    // I-type
    typedef struct packed {
        logic [11:0]    imm;
        reg_t           rs1;
        funct3_t        funct3;
        reg_t           rd;
        opcode_t        opcode;
    } i_type;

    // S-type
    typedef struct packed {
        logic [6:0]     imm_11_5;
        reg_t           rs2;
        reg_t           rs1;
        ldst_width_t    width; // 2^width[1:0] yields the width of store and load
        logic [4:0]     imm_4_0;
        opcode_t        opcode;
    } s_type;
    
    // B-type
    typedef struct packed {
        logic       imm_12;
        logic [5:0] imm_10_5;
        reg_t       rs2;
        reg_t       rs1;
        bfunct3_t   funct3;
        logic [3:0] imm_4_1;
        logic       imm_11;
        opcode_t    opcode;
    } b_type;

    // U-type
    typedef struct packed {
        logic [31 - 12:0]   imm_31_12;
        reg_t               rd;
        opcode_t    opcode;
    } u_type;

    // J-type
    typedef struct packed {
        logic               imm_20;
        logic [9:0]         imm_10_1;
        logic               imm_11;
        logic [19 - 12:0]   imm_19_12;
        reg_t               rd;
        opcode_t            opcode;
    } j_type;

    typedef enum logic [1:0] {
        ALU_OUT,
        LOAD_OUT,
        NPC,         // Next instruction, or PC + 4
        CSR_OUT
    } wdat_sel_t;

    typedef enum logic [1:0] {
        ALU_R2R = 2'b00,    // Register to Register
        ALU_R2I = 2'b10,    // Register to immediate
        ALU_PCR = 2'b01,    // PC to register
        ALU_PCI = 2'b11     // PC to immediate
    } alu_insel_t;

    typedef enum logic [1:0] { 
        RAM_FREE,           // RAM Ready to accept request
        RAM_ADDR,           // RAM gather addr and enable signals for fetching 
        RAM_DATA,           // RAM data is ready
        RAM_ERROR
    } ram_state_t;

    // csr cmd packet
    typedef struct packed {
        logic [11:0]    index;  // CSR register index
        system_funct3_t opcode; // CSR opcode
        logic           valid;  // The current instruction is a valid CSR inst
        logic           ren;    // CSR register ren, whether to read from CSR register
        logic           wen;    // CSR register wen, whether to write to CSR register
    } csr_cmd_t;

    typedef struct packed {
        logic ecall;
        logic ebreak;
        logic inst_illegal;
    } decoder_exception_t;

    typedef struct packed {
        logic load_addr_misalign;
        logic store_amo_addr_misalign;
    } ldst_exception_t;

    typedef struct packed {
        logic inst_misalign;
    } inst_fetch_exception_t;

    // localparam [31:0] BEQ                = 32'b?????????????????000?????1100011;
    // localparam [31:0] BNE                = 32'b?????????????????001?????1100011;
    // localparam [31:0] BLT                = 32'b?????????????????100?????1100011;
    // localparam [31:0] BGE                = 32'b?????????????????101?????1100011;
    // localparam [31:0] BLTU               = 32'b?????????????????110?????1100011;
    // localparam [31:0] BGEU               = 32'b?????????????????111?????1100011;
    // localparam [31:0] JALR               = 32'b?????????????????000?????1100111;
    // localparam [31:0] JAL                = 32'b?????????????????????????1101111;
    // localparam [31:0] LUI                = 32'b?????????????????????????0110111;
    // localparam [31:0] AUIPC              = 32'b?????????????????????????0010111;
    // localparam [31:0] ADDI               = 32'b?????????????????000?????0010011;
    // localparam [31:0] SLTI               = 32'b?????????????????010?????0010011;
    // localparam [31:0] SLTIU              = 32'b?????????????????011?????0010011;
    // localparam [31:0] XORI               = 32'b?????????????????100?????0010011;
    // localparam [31:0] ORI                = 32'b?????????????????110?????0010011;
    // localparam [31:0] ANDI               = 32'b?????????????????111?????0010011;
    // localparam [31:0] ADD                = 32'b0000000??????????000?????0110011;
    // localparam [31:0] SUB                = 32'b0100000??????????000?????0110011;
    // localparam [31:0] SLL                = 32'b0000000??????????001?????0110011;
    // localparam [31:0] SLT                = 32'b0000000??????????010?????0110011;
    // localparam [31:0] SLTU               = 32'b0000000??????????011?????0110011;
    // localparam [31:0] XOR                = 32'b0000000??????????100?????0110011;
    // localparam [31:0] SRL                = 32'b0000000??????????101?????0110011;
    // localparam [31:0] SRA                = 32'b0100000??????????101?????0110011;
    // localparam [31:0] OR                 = 32'b0000000??????????110?????0110011;
    // localparam [31:0] AND                = 32'b0000000??????????111?????0110011;
    // localparam [31:0] LB                 = 32'b?????????????????000?????0000011;
    // localparam [31:0] LH                 = 32'b?????????????????001?????0000011;
    // localparam [31:0] LW                 = 32'b?????????????????010?????0000011;
    // localparam [31:0] LBU                = 32'b?????????????????100?????0000011;
    // localparam [31:0] LHU                = 32'b?????????????????101?????0000011;
    // localparam [31:0] SB                 = 32'b?????????????????000?????0100011;
    // localparam [31:0] SH                 = 32'b?????????????????001?????0100011;
    // localparam [31:0] SW                 = 32'b?????????????????010?????0100011;
    // localparam [31:0] FENCE              = 32'b?????????????????000?????0001111;
    // localparam [31:0] FENCE_I            = 32'b?????????????????001?????0001111;
    // localparam [31:0] MUL                = 32'b0000001??????????000?????0110011;
    // localparam [31:0] MULH               = 32'b0000001??????????001?????0110011;
    // localparam [31:0] MULHSU             = 32'b0000001??????????010?????0110011;
    // localparam [31:0] MULHU              = 32'b0000001??????????011?????0110011;
    // localparam [31:0] DIV                = 32'b0000001??????????100?????0110011;
    // localparam [31:0] DIVU               = 32'b0000001??????????101?????0110011;
    // localparam [31:0] REM                = 32'b0000001??????????110?????0110011;
    // localparam [31:0] REMU               = 32'b0000001??????????111?????0110011;
    // localparam [31:0] AMOADD_W           = 32'b00000????????????010?????0101111;
    // localparam [31:0] AMOXOR_W           = 32'b00100????????????010?????0101111;
    // localparam [31:0] AMOOR_W            = 32'b01000????????????010?????0101111;
    // localparam [31:0] AMOAND_W           = 32'b01100????????????010?????0101111;
    // localparam [31:0] AMOMIN_W           = 32'b10000????????????010?????0101111;
    // localparam [31:0] AMOMAX_W           = 32'b10100????????????010?????0101111;
    // localparam [31:0] AMOMINU_W          = 32'b11000????????????010?????0101111;
    // localparam [31:0] AMOMAXU_W          = 32'b11100????????????010?????0101111;
    // localparam [31:0] AMOSWAP_W          = 32'b00001????????????010?????0101111;
    // localparam [31:0] LR_W               = 32'b00010??00000?????010?????0101111;
    // localparam [31:0] SC_W               = 32'b00011????????????010?????0101111;
    /* CSR Addresses */
    localparam logic [11:0] CSR_FFLAGS = 12'h1;
    localparam logic [11:0] CSR_FRM = 12'h2;
    localparam logic [11:0] CSR_FCSR = 12'h3;
    localparam logic [11:0] CSR_VSTART = 12'h8;
    localparam logic [11:0] CSR_VXSAT = 12'h9;
    localparam logic [11:0] CSR_VXRM = 12'ha;
    localparam logic [11:0] CSR_VCSR = 12'hf;
    localparam logic [11:0] CSR_SEED = 12'h15;
    localparam logic [11:0] CSR_JVT = 12'h17;
    localparam logic [11:0] CSR_CYCLE = 12'hc00;
    localparam logic [11:0] CSR_TIME = 12'hc01;
    localparam logic [11:0] CSR_INSTRET = 12'hc02;
    localparam logic [11:0] CSR_HPMCOUNTER3 = 12'hc03;
    localparam logic [11:0] CSR_HPMCOUNTER4 = 12'hc04;
    localparam logic [11:0] CSR_HPMCOUNTER5 = 12'hc05;
    localparam logic [11:0] CSR_HPMCOUNTER6 = 12'hc06;
    localparam logic [11:0] CSR_HPMCOUNTER7 = 12'hc07;
    localparam logic [11:0] CSR_HPMCOUNTER8 = 12'hc08;
    localparam logic [11:0] CSR_HPMCOUNTER9 = 12'hc09;
    localparam logic [11:0] CSR_HPMCOUNTER10 = 12'hc0a;
    localparam logic [11:0] CSR_HPMCOUNTER11 = 12'hc0b;
    localparam logic [11:0] CSR_HPMCOUNTER12 = 12'hc0c;
    localparam logic [11:0] CSR_HPMCOUNTER13 = 12'hc0d;
    localparam logic [11:0] CSR_HPMCOUNTER14 = 12'hc0e;
    localparam logic [11:0] CSR_HPMCOUNTER15 = 12'hc0f;
    localparam logic [11:0] CSR_HPMCOUNTER16 = 12'hc10;
    localparam logic [11:0] CSR_HPMCOUNTER17 = 12'hc11;
    localparam logic [11:0] CSR_HPMCOUNTER18 = 12'hc12;
    localparam logic [11:0] CSR_HPMCOUNTER19 = 12'hc13;
    localparam logic [11:0] CSR_HPMCOUNTER20 = 12'hc14;
    localparam logic [11:0] CSR_HPMCOUNTER21 = 12'hc15;
    localparam logic [11:0] CSR_HPMCOUNTER22 = 12'hc16;
    localparam logic [11:0] CSR_HPMCOUNTER23 = 12'hc17;
    localparam logic [11:0] CSR_HPMCOUNTER24 = 12'hc18;
    localparam logic [11:0] CSR_HPMCOUNTER25 = 12'hc19;
    localparam logic [11:0] CSR_HPMCOUNTER26 = 12'hc1a;
    localparam logic [11:0] CSR_HPMCOUNTER27 = 12'hc1b;
    localparam logic [11:0] CSR_HPMCOUNTER28 = 12'hc1c;
    localparam logic [11:0] CSR_HPMCOUNTER29 = 12'hc1d;
    localparam logic [11:0] CSR_HPMCOUNTER30 = 12'hc1e;
    localparam logic [11:0] CSR_HPMCOUNTER31 = 12'hc1f;
    localparam logic [11:0] CSR_VL = 12'hc20;
    localparam logic [11:0] CSR_VTYPE = 12'hc21;
    localparam logic [11:0] CSR_VLENB = 12'hc22;
    localparam logic [11:0] CSR_SSTATUS = 12'h100;
    localparam logic [11:0] CSR_SEDELEG = 12'h102;
    localparam logic [11:0] CSR_SIDELEG = 12'h103;
    localparam logic [11:0] CSR_SIE = 12'h104;
    localparam logic [11:0] CSR_STVEC = 12'h105;
    localparam logic [11:0] CSR_SCOUNTEREN = 12'h106;
    localparam logic [11:0] CSR_SENVCFG = 12'h10a;
    localparam logic [11:0] CSR_SSTATEEN0 = 12'h10c;
    localparam logic [11:0] CSR_SSTATEEN1 = 12'h10d;
    localparam logic [11:0] CSR_SSTATEEN2 = 12'h10e;
    localparam logic [11:0] CSR_SSTATEEN3 = 12'h10f;
    localparam logic [11:0] CSR_SSCRATCH = 12'h140;
    localparam logic [11:0] CSR_SEPC = 12'h141;
    localparam logic [11:0] CSR_SCAUSE = 12'h142;
    localparam logic [11:0] CSR_STVAL = 12'h143;
    localparam logic [11:0] CSR_SIP = 12'h144;
    localparam logic [11:0] CSR_STIMECMP = 12'h14d;
    localparam logic [11:0] CSR_SATP = 12'h180;
    localparam logic [11:0] CSR_SCONTEXT = 12'h5a8;
    localparam logic [11:0] CSR_VSSTATUS = 12'h200;
    localparam logic [11:0] CSR_VSIE = 12'h204;
    localparam logic [11:0] CSR_VSTVEC = 12'h205;
    localparam logic [11:0] CSR_VSSCRATCH = 12'h240;
    localparam logic [11:0] CSR_VSEPC = 12'h241;
    localparam logic [11:0] CSR_VSCAUSE = 12'h242;
    localparam logic [11:0] CSR_VSTVAL = 12'h243;
    localparam logic [11:0] CSR_VSIP = 12'h244;
    localparam logic [11:0] CSR_VSTIMECMP = 12'h24d;
    localparam logic [11:0] CSR_VSATP = 12'h280;
    localparam logic [11:0] CSR_HSTATUS = 12'h600;
    localparam logic [11:0] CSR_HEDELEG = 12'h602;
    localparam logic [11:0] CSR_HIDELEG = 12'h603;
    localparam logic [11:0] CSR_HIE = 12'h604;
    localparam logic [11:0] CSR_HTIMEDELTA = 12'h605;
    localparam logic [11:0] CSR_HCOUNTEREN = 12'h606;
    localparam logic [11:0] CSR_HGEIE = 12'h607;
    localparam logic [11:0] CSR_HENVCFG = 12'h60a;
    localparam logic [11:0] CSR_HSTATEEN0 = 12'h60c;
    localparam logic [11:0] CSR_HSTATEEN1 = 12'h60d;
    localparam logic [11:0] CSR_HSTATEEN2 = 12'h60e;
    localparam logic [11:0] CSR_HSTATEEN3 = 12'h60f;
    localparam logic [11:0] CSR_HTVAL = 12'h643;
    localparam logic [11:0] CSR_HIP = 12'h644;
    localparam logic [11:0] CSR_HVIP = 12'h645;
    localparam logic [11:0] CSR_HTINST = 12'h64a;
    localparam logic [11:0] CSR_HGATP = 12'h680;
    localparam logic [11:0] CSR_HCONTEXT = 12'h6a8;
    localparam logic [11:0] CSR_HGEIP = 12'he12;
    localparam logic [11:0] CSR_SCOUNTOVF = 12'hda0;
    localparam logic [11:0] CSR_UTVT = 12'h7;
    localparam logic [11:0] CSR_UNXTI = 12'h45;
    localparam logic [11:0] CSR_UINTSTATUS = 12'h46;
    localparam logic [11:0] CSR_USCRATCHCSW = 12'h48;
    localparam logic [11:0] CSR_USCRATCHCSWL = 12'h49;
    localparam logic [11:0] CSR_STVT = 12'h107;
    localparam logic [11:0] CSR_SNXTI = 12'h145;
    localparam logic [11:0] CSR_SINTSTATUS = 12'h146;
    localparam logic [11:0] CSR_SSCRATCHCSW = 12'h148;
    localparam logic [11:0] CSR_SSCRATCHCSWL = 12'h149;
    localparam logic [11:0] CSR_MTVT = 12'h307;
    localparam logic [11:0] CSR_MNXTI = 12'h345;
    localparam logic [11:0] CSR_MINTSTATUS = 12'h346;
    localparam logic [11:0] CSR_MSCRATCHCSW = 12'h348;
    localparam logic [11:0] CSR_MSCRATCHCSWL = 12'h349;
    localparam logic [11:0] CSR_MSTATUS = 12'h300;
    localparam logic [11:0] CSR_MISA = 12'h301;
    localparam logic [11:0] CSR_MEDELEG = 12'h302;
    localparam logic [11:0] CSR_MIDELEG = 12'h303;
    localparam logic [11:0] CSR_MIE = 12'h304;
    localparam logic [11:0] CSR_MTVEC = 12'h305;
    localparam logic [11:0] CSR_MCOUNTEREN = 12'h306;
    localparam logic [11:0] CSR_MENVCFG = 12'h30a;
    localparam logic [11:0] CSR_MSTATEEN0 = 12'h30c;
    localparam logic [11:0] CSR_MSTATEEN1 = 12'h30d;
    localparam logic [11:0] CSR_MSTATEEN2 = 12'h30e;
    localparam logic [11:0] CSR_MSTATEEN3 = 12'h30f;
    localparam logic [11:0] CSR_MCOUNTINHIBIT = 12'h320;
    localparam logic [11:0] CSR_MSCRATCH = 12'h340;
    localparam logic [11:0] CSR_MEPC = 12'h341;
    localparam logic [11:0] CSR_MCAUSE = 12'h342;
    localparam logic [11:0] CSR_MTVAL = 12'h343;
    localparam logic [11:0] CSR_MIP = 12'h344;
    localparam logic [11:0] CSR_MTINST = 12'h34a;
    localparam logic [11:0] CSR_MTVAL2 = 12'h34b;
    localparam logic [11:0] CSR_PMPCFG0 = 12'h3a0;
    localparam logic [11:0] CSR_PMPCFG1 = 12'h3a1;
    localparam logic [11:0] CSR_PMPCFG2 = 12'h3a2;
    localparam logic [11:0] CSR_PMPCFG3 = 12'h3a3;
    localparam logic [11:0] CSR_PMPCFG4 = 12'h3a4;
    localparam logic [11:0] CSR_PMPCFG5 = 12'h3a5;
    localparam logic [11:0] CSR_PMPCFG6 = 12'h3a6;
    localparam logic [11:0] CSR_PMPCFG7 = 12'h3a7;
    localparam logic [11:0] CSR_PMPCFG8 = 12'h3a8;
    localparam logic [11:0] CSR_PMPCFG9 = 12'h3a9;
    localparam logic [11:0] CSR_PMPCFG10 = 12'h3aa;
    localparam logic [11:0] CSR_PMPCFG11 = 12'h3ab;
    localparam logic [11:0] CSR_PMPCFG12 = 12'h3ac;
    localparam logic [11:0] CSR_PMPCFG13 = 12'h3ad;
    localparam logic [11:0] CSR_PMPCFG14 = 12'h3ae;
    localparam logic [11:0] CSR_PMPCFG15 = 12'h3af;
    localparam logic [11:0] CSR_PMPADDR0 = 12'h3b0;
    localparam logic [11:0] CSR_PMPADDR1 = 12'h3b1;
    localparam logic [11:0] CSR_PMPADDR2 = 12'h3b2;
    localparam logic [11:0] CSR_PMPADDR3 = 12'h3b3;
    localparam logic [11:0] CSR_PMPADDR4 = 12'h3b4;
    localparam logic [11:0] CSR_PMPADDR5 = 12'h3b5;
    localparam logic [11:0] CSR_PMPADDR6 = 12'h3b6;
    localparam logic [11:0] CSR_PMPADDR7 = 12'h3b7;
    localparam logic [11:0] CSR_PMPADDR8 = 12'h3b8;
    localparam logic [11:0] CSR_PMPADDR9 = 12'h3b9;
    localparam logic [11:0] CSR_PMPADDR10 = 12'h3ba;
    localparam logic [11:0] CSR_PMPADDR11 = 12'h3bb;
    localparam logic [11:0] CSR_PMPADDR12 = 12'h3bc;
    localparam logic [11:0] CSR_PMPADDR13 = 12'h3bd;
    localparam logic [11:0] CSR_PMPADDR14 = 12'h3be;
    localparam logic [11:0] CSR_PMPADDR15 = 12'h3bf;
    localparam logic [11:0] CSR_PMPADDR16 = 12'h3c0;
    localparam logic [11:0] CSR_PMPADDR17 = 12'h3c1;
    localparam logic [11:0] CSR_PMPADDR18 = 12'h3c2;
    localparam logic [11:0] CSR_PMPADDR19 = 12'h3c3;
    localparam logic [11:0] CSR_PMPADDR20 = 12'h3c4;
    localparam logic [11:0] CSR_PMPADDR21 = 12'h3c5;
    localparam logic [11:0] CSR_PMPADDR22 = 12'h3c6;
    localparam logic [11:0] CSR_PMPADDR23 = 12'h3c7;
    localparam logic [11:0] CSR_PMPADDR24 = 12'h3c8;
    localparam logic [11:0] CSR_PMPADDR25 = 12'h3c9;
    localparam logic [11:0] CSR_PMPADDR26 = 12'h3ca;
    localparam logic [11:0] CSR_PMPADDR27 = 12'h3cb;
    localparam logic [11:0] CSR_PMPADDR28 = 12'h3cc;
    localparam logic [11:0] CSR_PMPADDR29 = 12'h3cd;
    localparam logic [11:0] CSR_PMPADDR30 = 12'h3ce;
    localparam logic [11:0] CSR_PMPADDR31 = 12'h3cf;
    localparam logic [11:0] CSR_PMPADDR32 = 12'h3d0;
    localparam logic [11:0] CSR_PMPADDR33 = 12'h3d1;
    localparam logic [11:0] CSR_PMPADDR34 = 12'h3d2;
    localparam logic [11:0] CSR_PMPADDR35 = 12'h3d3;
    localparam logic [11:0] CSR_PMPADDR36 = 12'h3d4;
    localparam logic [11:0] CSR_PMPADDR37 = 12'h3d5;
    localparam logic [11:0] CSR_PMPADDR38 = 12'h3d6;
    localparam logic [11:0] CSR_PMPADDR39 = 12'h3d7;
    localparam logic [11:0] CSR_PMPADDR40 = 12'h3d8;
    localparam logic [11:0] CSR_PMPADDR41 = 12'h3d9;
    localparam logic [11:0] CSR_PMPADDR42 = 12'h3da;
    localparam logic [11:0] CSR_PMPADDR43 = 12'h3db;
    localparam logic [11:0] CSR_PMPADDR44 = 12'h3dc;
    localparam logic [11:0] CSR_PMPADDR45 = 12'h3dd;
    localparam logic [11:0] CSR_PMPADDR46 = 12'h3de;
    localparam logic [11:0] CSR_PMPADDR47 = 12'h3df;
    localparam logic [11:0] CSR_PMPADDR48 = 12'h3e0;
    localparam logic [11:0] CSR_PMPADDR49 = 12'h3e1;
    localparam logic [11:0] CSR_PMPADDR50 = 12'h3e2;
    localparam logic [11:0] CSR_PMPADDR51 = 12'h3e3;
    localparam logic [11:0] CSR_PMPADDR52 = 12'h3e4;
    localparam logic [11:0] CSR_PMPADDR53 = 12'h3e5;
    localparam logic [11:0] CSR_PMPADDR54 = 12'h3e6;
    localparam logic [11:0] CSR_PMPADDR55 = 12'h3e7;
    localparam logic [11:0] CSR_PMPADDR56 = 12'h3e8;
    localparam logic [11:0] CSR_PMPADDR57 = 12'h3e9;
    localparam logic [11:0] CSR_PMPADDR58 = 12'h3ea;
    localparam logic [11:0] CSR_PMPADDR59 = 12'h3eb;
    localparam logic [11:0] CSR_PMPADDR60 = 12'h3ec;
    localparam logic [11:0] CSR_PMPADDR61 = 12'h3ed;
    localparam logic [11:0] CSR_PMPADDR62 = 12'h3ee;
    localparam logic [11:0] CSR_PMPADDR63 = 12'h3ef;
    localparam logic [11:0] CSR_MSECCFG = 12'h747;
    localparam logic [11:0] CSR_TSELECT = 12'h7a0;
    localparam logic [11:0] CSR_TDATA1 = 12'h7a1;
    localparam logic [11:0] CSR_TDATA2 = 12'h7a2;
    localparam logic [11:0] CSR_TDATA3 = 12'h7a3;
    localparam logic [11:0] CSR_TINFO = 12'h7a4;
    localparam logic [11:0] CSR_TCONTROL = 12'h7a5;
    localparam logic [11:0] CSR_MCONTEXT = 12'h7a8;
    localparam logic [11:0] CSR_MSCONTEXT = 12'h7aa;
    localparam logic [11:0] CSR_DCSR = 12'h7b0;
    localparam logic [11:0] CSR_DPC = 12'h7b1;
    localparam logic [11:0] CSR_DSCRATCH0 = 12'h7b2;
    localparam logic [11:0] CSR_DSCRATCH1 = 12'h7b3;
    localparam logic [11:0] CSR_MCYCLE = 12'hb00;
    localparam logic [11:0] CSR_MINSTRET = 12'hb02;
    localparam logic [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
    localparam logic [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
    localparam logic [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
    localparam logic [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
    localparam logic [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
    localparam logic [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
    localparam logic [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
    localparam logic [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
    localparam logic [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
    localparam logic [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
    localparam logic [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
    localparam logic [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
    localparam logic [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
    localparam logic [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
    localparam logic [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
    localparam logic [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
    localparam logic [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
    localparam logic [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
    localparam logic [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
    localparam logic [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
    localparam logic [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
    localparam logic [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
    localparam logic [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
    localparam logic [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
    localparam logic [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
    localparam logic [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
    localparam logic [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
    localparam logic [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
    localparam logic [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
    localparam logic [11:0] CSR_MHPMEVENT3 = 12'h323;
    localparam logic [11:0] CSR_MHPMEVENT4 = 12'h324;
    localparam logic [11:0] CSR_MHPMEVENT5 = 12'h325;
    localparam logic [11:0] CSR_MHPMEVENT6 = 12'h326;
    localparam logic [11:0] CSR_MHPMEVENT7 = 12'h327;
    localparam logic [11:0] CSR_MHPMEVENT8 = 12'h328;
    localparam logic [11:0] CSR_MHPMEVENT9 = 12'h329;
    localparam logic [11:0] CSR_MHPMEVENT10 = 12'h32a;
    localparam logic [11:0] CSR_MHPMEVENT11 = 12'h32b;
    localparam logic [11:0] CSR_MHPMEVENT12 = 12'h32c;
    localparam logic [11:0] CSR_MHPMEVENT13 = 12'h32d;
    localparam logic [11:0] CSR_MHPMEVENT14 = 12'h32e;
    localparam logic [11:0] CSR_MHPMEVENT15 = 12'h32f;
    localparam logic [11:0] CSR_MHPMEVENT16 = 12'h330;
    localparam logic [11:0] CSR_MHPMEVENT17 = 12'h331;
    localparam logic [11:0] CSR_MHPMEVENT18 = 12'h332;
    localparam logic [11:0] CSR_MHPMEVENT19 = 12'h333;
    localparam logic [11:0] CSR_MHPMEVENT20 = 12'h334;
    localparam logic [11:0] CSR_MHPMEVENT21 = 12'h335;
    localparam logic [11:0] CSR_MHPMEVENT22 = 12'h336;
    localparam logic [11:0] CSR_MHPMEVENT23 = 12'h337;
    localparam logic [11:0] CSR_MHPMEVENT24 = 12'h338;
    localparam logic [11:0] CSR_MHPMEVENT25 = 12'h339;
    localparam logic [11:0] CSR_MHPMEVENT26 = 12'h33a;
    localparam logic [11:0] CSR_MHPMEVENT27 = 12'h33b;
    localparam logic [11:0] CSR_MHPMEVENT28 = 12'h33c;
    localparam logic [11:0] CSR_MHPMEVENT29 = 12'h33d;
    localparam logic [11:0] CSR_MHPMEVENT30 = 12'h33e;
    localparam logic [11:0] CSR_MHPMEVENT31 = 12'h33f;
    localparam logic [11:0] CSR_MVENDORID = 12'hf11;
    localparam logic [11:0] CSR_MARCHID = 12'hf12;
    localparam logic [11:0] CSR_MIMPID = 12'hf13;
    localparam logic [11:0] CSR_MHARTID = 12'hf14;
    localparam logic [11:0] CSR_MCONFIGPTR = 12'hf15;
    localparam logic [11:0] CSR_STIMECMPH = 12'h15d;
    localparam logic [11:0] CSR_VSTIMECMPH = 12'h25d;
    localparam logic [11:0] CSR_HTIMEDELTAH = 12'h615;
    localparam logic [11:0] CSR_HENVCFGH = 12'h61a;
    localparam logic [11:0] CSR_HSTATEEN0H = 12'h61c;
    localparam logic [11:0] CSR_HSTATEEN1H = 12'h61d;
    localparam logic [11:0] CSR_HSTATEEN2H = 12'h61e;
    localparam logic [11:0] CSR_HSTATEEN3H = 12'h61f;
    localparam logic [11:0] CSR_CYCLEH = 12'hc80;
    localparam logic [11:0] CSR_TIMEH = 12'hc81;
    localparam logic [11:0] CSR_INSTRETH = 12'hc82;
    localparam logic [11:0] CSR_HPMCOUNTER3H = 12'hc83;
    localparam logic [11:0] CSR_HPMCOUNTER4H = 12'hc84;
    localparam logic [11:0] CSR_HPMCOUNTER5H = 12'hc85;
    localparam logic [11:0] CSR_HPMCOUNTER6H = 12'hc86;
    localparam logic [11:0] CSR_HPMCOUNTER7H = 12'hc87;
    localparam logic [11:0] CSR_HPMCOUNTER8H = 12'hc88;
    localparam logic [11:0] CSR_HPMCOUNTER9H = 12'hc89;
    localparam logic [11:0] CSR_HPMCOUNTER10H = 12'hc8a;
    localparam logic [11:0] CSR_HPMCOUNTER11H = 12'hc8b;
    localparam logic [11:0] CSR_HPMCOUNTER12H = 12'hc8c;
    localparam logic [11:0] CSR_HPMCOUNTER13H = 12'hc8d;
    localparam logic [11:0] CSR_HPMCOUNTER14H = 12'hc8e;
    localparam logic [11:0] CSR_HPMCOUNTER15H = 12'hc8f;
    localparam logic [11:0] CSR_HPMCOUNTER16H = 12'hc90;
    localparam logic [11:0] CSR_HPMCOUNTER17H = 12'hc91;
    localparam logic [11:0] CSR_HPMCOUNTER18H = 12'hc92;
    localparam logic [11:0] CSR_HPMCOUNTER19H = 12'hc93;
    localparam logic [11:0] CSR_HPMCOUNTER20H = 12'hc94;
    localparam logic [11:0] CSR_HPMCOUNTER21H = 12'hc95;
    localparam logic [11:0] CSR_HPMCOUNTER22H = 12'hc96;
    localparam logic [11:0] CSR_HPMCOUNTER23H = 12'hc97;
    localparam logic [11:0] CSR_HPMCOUNTER24H = 12'hc98;
    localparam logic [11:0] CSR_HPMCOUNTER25H = 12'hc99;
    localparam logic [11:0] CSR_HPMCOUNTER26H = 12'hc9a;
    localparam logic [11:0] CSR_HPMCOUNTER27H = 12'hc9b;
    localparam logic [11:0] CSR_HPMCOUNTER28H = 12'hc9c;
    localparam logic [11:0] CSR_HPMCOUNTER29H = 12'hc9d;
    localparam logic [11:0] CSR_HPMCOUNTER30H = 12'hc9e;
    localparam logic [11:0] CSR_HPMCOUNTER31H = 12'hc9f;
    localparam logic [11:0] CSR_MSTATUSH = 12'h310;
    localparam logic [11:0] CSR_MENVCFGH = 12'h31a;
    localparam logic [11:0] CSR_MSTATEEN0H = 12'h31c;
    localparam logic [11:0] CSR_MSTATEEN1H = 12'h31d;
    localparam logic [11:0] CSR_MSTATEEN2H = 12'h31e;
    localparam logic [11:0] CSR_MSTATEEN3H = 12'h31f;
    localparam logic [11:0] CSR_MHPMEVENT3H = 12'h723;
    localparam logic [11:0] CSR_MHPMEVENT4H = 12'h724;
    localparam logic [11:0] CSR_MHPMEVENT5H = 12'h725;
    localparam logic [11:0] CSR_MHPMEVENT6H = 12'h726;
    localparam logic [11:0] CSR_MHPMEVENT7H = 12'h727;
    localparam logic [11:0] CSR_MHPMEVENT8H = 12'h728;
    localparam logic [11:0] CSR_MHPMEVENT9H = 12'h729;
    localparam logic [11:0] CSR_MHPMEVENT10H = 12'h72a;
    localparam logic [11:0] CSR_MHPMEVENT11H = 12'h72b;
    localparam logic [11:0] CSR_MHPMEVENT12H = 12'h72c;
    localparam logic [11:0] CSR_MHPMEVENT13H = 12'h72d;
    localparam logic [11:0] CSR_MHPMEVENT14H = 12'h72e;
    localparam logic [11:0] CSR_MHPMEVENT15H = 12'h72f;
    localparam logic [11:0] CSR_MHPMEVENT16H = 12'h730;
    localparam logic [11:0] CSR_MHPMEVENT17H = 12'h731;
    localparam logic [11:0] CSR_MHPMEVENT18H = 12'h732;
    localparam logic [11:0] CSR_MHPMEVENT19H = 12'h733;
    localparam logic [11:0] CSR_MHPMEVENT20H = 12'h734;
    localparam logic [11:0] CSR_MHPMEVENT21H = 12'h735;
    localparam logic [11:0] CSR_MHPMEVENT22H = 12'h736;
    localparam logic [11:0] CSR_MHPMEVENT23H = 12'h737;
    localparam logic [11:0] CSR_MHPMEVENT24H = 12'h738;
    localparam logic [11:0] CSR_MHPMEVENT25H = 12'h739;
    localparam logic [11:0] CSR_MHPMEVENT26H = 12'h73a;
    localparam logic [11:0] CSR_MHPMEVENT27H = 12'h73b;
    localparam logic [11:0] CSR_MHPMEVENT28H = 12'h73c;
    localparam logic [11:0] CSR_MHPMEVENT29H = 12'h73d;
    localparam logic [11:0] CSR_MHPMEVENT30H = 12'h73e;
    localparam logic [11:0] CSR_MHPMEVENT31H = 12'h73f;
    localparam logic [11:0] CSR_MSECCFGH = 12'h757;
    localparam logic [11:0] CSR_MCYCLEH = 12'hb80;
    localparam logic [11:0] CSR_MINSTRETH = 12'hb82;
    localparam logic [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
    localparam logic [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
    localparam logic [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
    localparam logic [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
    localparam logic [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
    localparam logic [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
    localparam logic [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
    localparam logic [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
    localparam logic [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
    localparam logic [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
    localparam logic [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
    localparam logic [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
    localparam logic [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
    localparam logic [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
    localparam logic [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
    localparam logic [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
    localparam logic [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
    localparam logic [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
    localparam logic [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
    localparam logic [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
    localparam logic [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
    localparam logic [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
    localparam logic [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
    localparam logic [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
    localparam logic [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
    localparam logic [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
    localparam logic [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
    localparam logic [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
    localparam logic [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
endpackage

`endif // __RV32IMA_PKG_VH__