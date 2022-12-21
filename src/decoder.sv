/**
 * File name:	decoder.sv
 * Created:	12/18/2022
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.1 Adding CSR
 * Description:	Decoder implementation
 */

`include "decoder_if.svh"
`include "csr_if.svh"
`include "rv32ima_pkg.svh"

module decoder (
    decoder_if.decode _if
);
    import rv32ima_pkg::*;

    // Casting inst vars
    r_type r_inst;
    i_type i_inst;
    s_type s_inst;
    b_type b_inst;
    u_type u_inst;
    j_type j_inst;

    // System inst funct3 casting var
    system_funct3_t sfunct3;

    logic inst_msb;

    always_comb begin : DECODE
        // Avoid latches
        _if.alu_cmd = '0;
        _if.rf_cmd = '0;
        _if.dmem_cmd = '0;
        _if.control_type = '0;
        _if.inst_type = RTYPE;
        _if.imm32 = '0;
        _if.csr_cmd = '0;
        _if.csr_uimm = '0;
        _if.dec_exception_event = '0;

        // Casting
        r_inst = r_type'(_if.inst);
        i_inst = i_type'(r_inst);
        s_inst = s_type'(r_inst);
        b_inst = b_type'(r_inst);
        u_inst = u_type'(r_inst);
        j_inst = j_type'(r_inst);
        sfunct3 = system_funct3_t'(i_inst.funct3);

        // Transparent regfile signals
        _if.rf_cmd.rs1 = r_inst.rs1;
        _if.rf_cmd.rs2 = r_inst.rs2;
        _if.rf_cmd.rd = r_inst.rd;

        inst_msb = r_inst[BIT_WIDTH - 1];

        casez (r_inst.opcode)
            LOAD: begin 
                // rd = mem[r1 + signext(imm)]
                _if.alu_cmd.alu_insel = ALU_R2I;
                _if.alu_cmd.aluop     = ALU_ADD;

                _if.rf_cmd.wen = 1'b1;
                _if.rf_cmd.wdat_sel   = LOAD_OUT;

                _if.dmem_cmd.dmem_wen = 1'b0;
                _if.dmem_cmd.dmem_ren = 1'b1;
                _if.dmem_cmd.dmem_load_unsigned = i_inst.funct3[2];
                _if.dmem_cmd.dmem_width = i_inst.funct3[1:0];

                _if.inst_type = ITYPE;
                _if.imm32 = { {20{inst_msb}}, i_inst.imm };
            end

            MISC_MEM: begin 
                // TODO Implement FENCE inst?
                // Just implement FENCE as NOP
                // Which is addi x0, x0, 0
                _if.alu_cmd.alu_insel = ALU_R2I;
                _if.alu_cmd.aluop     = ALU_ADD;

                _if.rf_cmd.wen      = 1'b1;
                _if.rf_cmd.wdat_sel = ALU_OUT;
                _if.rf_cmd.rs1      = '0;
                _if.rf_cmd.rd       = '0;

                _if.inst_type = ITYPE;
                _if.imm32 = '0;
            end

            OP_IMM: begin 
                // rd = r1 + signext(imm)
                _if.alu_cmd.alu_insel = ALU_R2I;
                // TODO Altern bit cannot be used for inst with full imm?
                if (i_inst.funct3 == SR)
                    _if.alu_cmd.aluop     = aluop_t'({1'b0, i_inst[ALTERN_BIT + FUNCT7_START], i_inst.funct3});
                else
                    _if.alu_cmd.aluop     = aluop_t'({2'b0, i_inst.funct3});

                _if.rf_cmd.wen      = 1'b1;
                _if.rf_cmd.wdat_sel = ALU_OUT;

                _if.inst_type = ITYPE;
                _if.imm32 = { {20{inst_msb}}, i_inst.imm };
            end

            AUIPC: begin 
                // rd = imm << 20 + PC
                _if.alu_cmd.alu_insel = ALU_PCI;
                _if.alu_cmd.aluop     = ALU_ADD;

                _if.rf_cmd.wen      = 1'b1;
                _if.rf_cmd.wdat_sel = ALU_OUT;

                _if.inst_type = UTYPE;
                _if.imm32 = { u_inst.imm_31_12, {12{1'b0}} };
            end

            STORE: begin 
                // mem[r1 + offset] = r2
                _if.alu_cmd.alu_insel = ALU_R2I;
                _if.alu_cmd.aluop     = ALU_ADD;

                _if.rf_cmd.wen = 1'b0;

                _if.dmem_cmd.dmem_wen = 1'b1;
                _if.dmem_cmd.dmem_ren = 1'b0;
                _if.dmem_cmd.dmem_load_unsigned = i_inst.funct3[2];
                _if.dmem_cmd.dmem_width = i_inst.funct3[1:0];

                _if.inst_type = STYPE;
                _if.imm32 = { {20{inst_msb}}, s_inst.imm_11_5, s_inst.imm_4_0 };
            end

            // TODO Implement AMO op
            // AMO: begin 
                
            // end

            OP: begin 
                // rd = r1 + r2
                _if.alu_cmd.alu_insel = ALU_R2R;
                _if.alu_cmd.aluop     = aluop_t'({r_inst.funct7[MEXT_BIT], r_inst.funct7[ALTERN_BIT], r_inst.funct3});

                _if.rf_cmd.wen = 1'b1;
                _if.rf_cmd.wdat_sel   = ALU_OUT;

                _if.dmem_cmd.dmem_wen = 1'b0;
                _if.dmem_cmd.dmem_ren = 1'b0;

                _if.inst_type = RTYPE;
            end

            LUI: begin 
                // rd = imm << 12
                _if.alu_cmd.alu_insel = ALU_R2I;
                _if.alu_cmd.aluop     = ALU_ADD;

                // Fix r1 to r0
                _if.rf_cmd.wen      = 1'b1;
                _if.rf_cmd.wdat_sel = ALU_OUT;
                _if.rf_cmd.rs1      = 5'b0;

                _if.inst_type = UTYPE;
                _if.imm32 = { u_inst.imm_31_12, {12{1'b0}} };
            end

            // For RV64 only
            // OP_32: begin 
                
            // end

            BRANCH: begin 
                // branch to PC + imm if r1 cond r2
                _if.alu_cmd.alu_insel = ALU_R2R;
                // Select ALU op for comparsion
                casez (b_inst.funct3)
                    BEQ,
                    BNE: _if.alu_cmd.aluop  = ALU_SUB;
                    BLT,
                    BGE: _if.alu_cmd.aluop  = ALU_SLT;
                    BLTU,
                    BGEU: _if.alu_cmd.aluop = ALU_SLTU;
                    default: _if.alu_cmd.aluop  = ALU_SUB;
                endcase

                _if.rf_cmd.wen = 1'b0;

                _if.dmem_cmd.dmem_wen = 1'b0;
                _if.dmem_cmd.dmem_ren = 1'b0;

                _if.control_type.is_branch      = 1'b1;
                _if.control_type.is_jump        = 1'b0;
                _if.control_type.branch_type    = b_inst.funct3;

                _if.inst_type = BTYPE;
                // Branch offset, signed extended
                _if.imm32 = { {19{inst_msb}}, b_inst.imm_12, b_inst.imm_11, b_inst.imm_10_5, b_inst.imm_4_1, 1'b0 };
            end

            JALR: begin 
                // jump to rs1 + Offset, rd = PC + 4
                _if.alu_cmd.alu_insel = ALU_R2I;
                _if.alu_cmd.aluop     = ALU_ADD;

                _if.rf_cmd.wen = 1'b1;
                _if.rf_cmd.wdat_sel   = NPC;

                _if.dmem_cmd.dmem_wen = 1'b0;
                _if.dmem_cmd.dmem_ren = 1'b0;

                _if.control_type.is_branch      = 1'b0;
                _if.control_type.is_jump        = 1'b1;
                _if.control_type.branch_type    = BEQ;

                _if.inst_type = ITYPE;
                _if.imm32 = { {20{inst_msb}}, i_inst.imm };
            end

            JAL: begin 
                // jump to PC + Offset, rd = PC + 4
                _if.alu_cmd.alu_insel = ALU_PCI;
                _if.alu_cmd.aluop     = ALU_ADD;

                _if.rf_cmd.wen = 1'b1;
                _if.rf_cmd.wdat_sel   = NPC;

                _if.dmem_cmd.dmem_wen = 1'b0;
                _if.dmem_cmd.dmem_ren = 1'b0;

                _if.control_type.is_branch      = 1'b0;
                _if.control_type.is_jump        = 1'b1;
                _if.control_type.branch_type    = BEQ;

                _if.inst_type = JTYPE;
                _if.imm32 = { {11{inst_msb}}, j_inst.imm_20, j_inst.imm_19_12, j_inst.imm_11, j_inst.imm_10_1, 1'b0 };
            end

            SYSTEM:  begin 
                if (sfunct3 == PRIV) begin
                    if (i_inst.rs1 != '0 || i_inst.rd != '0) begin
                        // All inst in this class should have these
                        // two fields set to zeros
                        _if.dec_exception_event.inst_illegal = 1'b1;
                    end
                    else begin
                        casez (system_funct12_t'(i_inst.imm)) 
                            ECALL: _if.dec_exception_event.ecall = 1'b1;
                            EBREAK: _if.dec_exception_event.ebreak = 1'b1;
                            MRET: begin
                                // inform CSR unit that this is a MRET instruction
                                _if.csr_cmd.opcode = MRET_OP;
                                _if.csr_cmd.valid = 1'b1;

                                // Return to epc is handled by csr_exception unit 
                            end
                            WFI: begin
                                // Just implement WFI as NOP
                                // Which is addi x0, x0, 0
                                _if.alu_cmd.alu_insel = ALU_R2I;
                                _if.alu_cmd.aluop     = ALU_ADD;

                                _if.rf_cmd.wen      = 1'b1;
                                _if.rf_cmd.wdat_sel = ALU_OUT;
                                _if.rf_cmd.rs1      = '0;
                                _if.rf_cmd.rd       = '0;

                                _if.inst_type = ITYPE;
                                _if.imm32 = '0;
                            end
                            default: _if.dec_exception_event.inst_illegal = 1'b1;
                        endcase
                    end
                end
                else if (sfunct3 != PRIV && sfunct3 != PRIVM) begin
                    // Focus on CSRR instructions
                    _if.csr_cmd.index = i_inst.imm;
                    // For Zicsr instruction, the CSR unit opcode is {1'b1, sfunct3} 
                    _if.csr_cmd.opcode = csr_opcode_t'({1'b1, sfunct3});
                    _if.csr_cmd.valid = 1'b1;
                    _if.csr_cmd.ren = 1'b1;
                    _if.csr_cmd.wen = 1'b1;
                    _if.csr_uimm = i_inst.rs1;
                    
                    // Enable write to register file
                    _if.rf_cmd.wen      = 1'b1;
                    _if.rf_cmd.wdat_sel = CSR_OUT;
                    
                    if ((sfunct3 == CSRRW || sfunct3 == CSRRWI) && i_inst.rd == '0) begin
                        // Atomic swap
                        _if.csr_cmd.ren = 1'b0;
                    end
                    if ((sfunct3 == CSRRS   || sfunct3 == CSRRC || 
                         sfunct3 == CSRRSI  || sfunct3 == CSRRCI  ) && i_inst.rs1 == '0) begin
                        // bit clear
                        _if.csr_cmd.wen = 1'b0;
                    end
                end
                else begin
                    _if.dec_exception_event.inst_illegal = 1'b1;
                end
            end

            default: begin
                // Raise illegal inst excception
                _if.dec_exception_event.inst_illegal = 1'b1;
            end
        endcase
    end
    
endmodule