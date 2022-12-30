onerror {resume}
quietly virtual signal -install /tb_system/dut/cpuif { (context /tb_system/dut/cpuif )&{clk , nrst , req , res }} Master
quietly virtual function -install {/tb_system/dut/slave_dev_ifs[0]} -env /tb_system/dut/slave_dev_ifs[0] { &{/tb_system/dut/slave_dev_ifs[0]/clk, /tb_system/dut/slave_dev_ifs[0]/nrst, /tb_system/dut/slave_dev_ifs[0]/sel, /tb_system/dut/slave_dev_ifs[0]/req, /tb_system/dut/slave_dev_ifs[0]/res }} slaveif_0
quietly virtual function -install {/tb_system/dut/slave_dev_ifs[1]} -env /tb_system/dut/slave_dev_ifs[1] { &{/tb_system/dut/slave_dev_ifs[1]/clk, /tb_system/dut/slave_dev_ifs[1]/nrst, /tb_system/dut/slave_dev_ifs[1]/sel, /tb_system/dut/slave_dev_ifs[1]/req, /tb_system/dut/slave_dev_ifs[1]/res }} slaveif_1
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_system/tb_clk
add wave -noupdate /tb_system/tb_nrst
add wave -noupdate /tb_system/tb_data
add wave -noupdate -group TB_systemif /tb_system/tb_sysif0/ram_addr
add wave -noupdate -group TB_systemif /tb_system/tb_sysif0/ram_store
add wave -noupdate -group TB_systemif /tb_system/tb_sysif0/ram_load
add wave -noupdate -group TB_systemif /tb_system/tb_sysif0/ram_ren
add wave -noupdate -group TB_systemif /tb_system/tb_sysif0/ram_wen
add wave -noupdate -group TB_systemif /tb_system/tb_sysif0/ram_state
add wave -noupdate -group TB_systemif /tb_system/tb_sysif0/seg_ctrl
add wave -noupdate -group RAM /tb_system/dut/ram0/byteen
add wave -noupdate -group RAM /tb_system/dut/ram0/ram_rdy
add wave -noupdate -group RAM /tb_system/dut/ram0/n_ram_rdy
add wave -noupdate -group RAMIF /tb_system/dut/ram0/ram_rdy
add wave -noupdate -group RAMIF /tb_system/dut/ram0/n_ram_rdy
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/clk
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/nrst
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/imem_load
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/imem_addr
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/ihit
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/imem_ren
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/dhit
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/dmem_wen
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/dmem_ren
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/dmem_store
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/dmem_load
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/dmem_addr
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dpif/dmem_width
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dp0/served_data
add wave -noupdate -group DATAPAT -expand -group DPIF /tb_system/dut/dp0/next_served_data
add wave -noupdate -group DATAPAT -expand -group pcif /tb_system/dut/dp0/pcif0/clk
add wave -noupdate -group DATAPAT -expand -group pcif /tb_system/dut/dp0/pcif0/nrst
add wave -noupdate -group DATAPAT -expand -group pcif /tb_system/dut/dp0/pcif0/curr_pc
add wave -noupdate -group DATAPAT -expand -group pcif /tb_system/dut/dp0/pcif0/pc_add4
add wave -noupdate -group DATAPAT -expand -group pcif /tb_system/dut/dp0/pcif0/next_pc
add wave -noupdate -group DATAPAT -expand -group pcif /tb_system/dut/dp0/pcif0/next_pc_en
add wave -noupdate -group DATAPAT -expand -group pcif /tb_system/dut/dp0/pcif0/branch_addr
add wave -noupdate -group DATAPAT -expand -group pcif /tb_system/dut/dp0/pcif0/branch_addr_en
add wave -noupdate -group DATAPAT -expand -group pcif /tb_system/dut/dp0/pcif0/inst_ready
add wave -noupdate -group DATAPAT -group decif /tb_system/dut/dp0/decif0/alu_cmd
add wave -noupdate -group DATAPAT -group decif /tb_system/dut/dp0/decif0/rf_cmd
add wave -noupdate -group DATAPAT -group decif /tb_system/dut/dp0/decif0/csr_cmd
add wave -noupdate -group DATAPAT -group decif /tb_system/dut/dp0/decif0/csr_uimm
add wave -noupdate -group DATAPAT -group decif -expand /tb_system/dut/dp0/decif0/dec_exception_event
add wave -noupdate -group DATAPAT -group decif -expand /tb_system/dut/dp0/decif0/dmem_cmd
add wave -noupdate -group DATAPAT -group decif /tb_system/dut/dp0/decif0/dmem_cmd.dmem_ren
add wave -noupdate -group DATAPAT -group decif /tb_system/dut/dp0/decif0/control_type
add wave -noupdate -group DATAPAT -group decif /tb_system/dut/dp0/decif0/inst_type
add wave -noupdate -group DATAPAT -group decif /tb_system/dut/dp0/decif0/imm32
add wave -noupdate -group DATAPAT -group decif /tb_system/dut/dp0/decif0/inst
add wave -noupdate -group DATAPAT -group csrif /tb_system/dut/dp0/csrif0/clk
add wave -noupdate -group DATAPAT -group csrif /tb_system/dut/dp0/csrif0/nrst
add wave -noupdate -group DATAPAT -group csrif /tb_system/dut/dp0/csrif0/csr_cmd
add wave -noupdate -group DATAPAT -group csrif /tb_system/dut/dp0/csrif0/csr_input
add wave -noupdate -group DATAPAT -group csrif /tb_system/dut/dp0/csrif0/csr_val
add wave -noupdate -group DATAPAT -group exceptionif /tb_system/dut/dp0/exceptionif0/inst_fetch_exception_event
add wave -noupdate -group DATAPAT -group exceptionif /tb_system/dut/dp0/exceptionif0/ldst_exception_event
add wave -noupdate -group DATAPAT -group exceptionif /tb_system/dut/dp0/exceptionif0/dec_exception_event
add wave -noupdate -group DATAPAT -group exceptionif /tb_system/dut/dp0/exceptionif0/current_pc
add wave -noupdate -group DATAPAT -group exceptionif /tb_system/dut/dp0/exceptionif0/epc_value
add wave -noupdate -group DATAPAT -group exceptionif /tb_system/dut/dp0/exceptionif0/xret_enable
add wave -noupdate -group DATAPAT -group exceptionif /tb_system/dut/dp0/exceptionif0/trap_handler_addr
add wave -noupdate -group DATAPAT -group exceptionif /tb_system/dut/dp0/exceptionif0/trap_enable
add wave -noupdate -group DATAPAT -group brif /tb_system/dut/dp0/brif0/control_type
add wave -noupdate -group DATAPAT -group brif /tb_system/dut/dp0/brif0/jump_addr
add wave -noupdate -group DATAPAT -group brif /tb_system/dut/dp0/brif0/branch_addr
add wave -noupdate -group DATAPAT -group brif /tb_system/dut/dp0/brif0/zero
add wave -noupdate -group DATAPAT -group brif /tb_system/dut/dp0/brif0/neg
add wave -noupdate -group DATAPAT -group brif /tb_system/dut/dp0/brif0/next_addr
add wave -noupdate -group DATAPAT -group brif /tb_system/dut/dp0/brif0/next_addr_en
add wave -noupdate -group DATAPAT -expand -group rfif /tb_system/dut/dp0/rfif0/clk
add wave -noupdate -group DATAPAT -expand -group rfif /tb_system/dut/dp0/rfif0/nrst
add wave -noupdate -group DATAPAT -expand -group rfif /tb_system/dut/dp0/rfif0/rsel1
add wave -noupdate -group DATAPAT -expand -group rfif /tb_system/dut/dp0/rfif0/rsel2
add wave -noupdate -group DATAPAT -expand -group rfif /tb_system/dut/dp0/rfif0/wsel
add wave -noupdate -group DATAPAT -expand -group rfif /tb_system/dut/dp0/rfif0/wen
add wave -noupdate -group DATAPAT -expand -group rfif /tb_system/dut/dp0/rfif0/rdat1
add wave -noupdate -group DATAPAT -expand -group rfif /tb_system/dut/dp0/rfif0/rdat2
add wave -noupdate -group DATAPAT -expand -group rfif /tb_system/dut/dp0/rfif0/wdat
add wave -noupdate -group DATAPAT -group aluif /tb_system/dut/dp0/aif0/alu_op
add wave -noupdate -group DATAPAT -group aluif /tb_system/dut/dp0/aif0/in1
add wave -noupdate -group DATAPAT -group aluif /tb_system/dut/dp0/aif0/in2
add wave -noupdate -group DATAPAT -group aluif /tb_system/dut/dp0/aif0/out
add wave -noupdate -group DATAPAT -group aluif /tb_system/dut/dp0/aif0/zero
add wave -noupdate -group DATAPAT -group aluif /tb_system/dut/dp0/aif0/neg
add wave -noupdate -group DATAPAT -group aluif /tb_system/dut/dp0/aif0/overflow
add wave -noupdate -group DATAPAT -group aluif /tb_system/dut/dp0/aif0/carry
add wave -noupdate -group DATAPAT /tb_system/dut/dp0/ext_load
add wave -noupdate -group DATAPAT /tb_system/dut/dp0/byteen
add wave -noupdate -group DATAPAT /tb_system/dut/dp0/inst
add wave -noupdate -group DATAPAT /tb_system/dut/dp0/next_inst
add wave -noupdate -group DECODER /tb_system/dut/dp0/dec0/r_inst
add wave -noupdate -group DECODER /tb_system/dut/dp0/dec0/i_inst
add wave -noupdate -group DECODER /tb_system/dut/dp0/dec0/s_inst
add wave -noupdate -group DECODER /tb_system/dut/dp0/dec0/b_inst
add wave -noupdate -group DECODER /tb_system/dut/dp0/dec0/u_inst
add wave -noupdate -group DECODER /tb_system/dut/dp0/dec0/j_inst
add wave -noupdate -group DECODER /tb_system/dut/dp0/dec0/sfunct3
add wave -noupdate -group DECODER /tb_system/dut/dp0/dec0/inst_msb
add wave -noupdate -group REGFILE -expand /tb_system/dut/dp0/rf0/rf
add wave -noupdate -group REGFILE /tb_system/dut/dp0/rf0/next_rf
add wave -noupdate -group PC /tb_system/dut/dp0/pc0/tmp_pc
add wave -noupdate -group CSR_EXCEP -expand /tb_system/dut/dp0/csr_exception0/csr
add wave -noupdate -group CSR_EXCEP /tb_system/dut/dp0/csr_exception0/next_csr
add wave -noupdate -group CSR_EXCEP /tb_system/dut/dp0/csr_exception0/csr_psel
add wave -noupdate -group CSR_EXCEP /tb_system/dut/dp0/csr_exception0/uimm32
add wave -noupdate -group CSR_EXCEP /tb_system/dut/dp0/csr_exception0/exception_hit
add wave -noupdate -group CSR_EXCEP /tb_system/dut/dp0/csr_exception0/mtvec_base_addr
add wave -noupdate -group CSR_EXCEP /tb_system/dut/dp0/csr_exception0/cause_code
add wave -noupdate -group CSR_EXCEP /tb_system/dut/dp0/csr_exception0/trap_value
add wave -noupdate -group MINIBus /tb_system/dut/minibus_dec0/slavemmaps
add wave -noupdate -group MINIBus /tb_system/dut/cpuif/Master
add wave -noupdate -group MINIBus {/tb_system/dut/slave_dev_ifs[0]/slaveif_0}
add wave -noupdate -group MINIBus {/tb_system/dut/slave_dev_ifs[1]/slaveif_1}
add wave -noupdate -expand -group segment_regs /tb_system/dut/seg_disp/regs/outputs
add wave -noupdate -expand -group segment_regs /tb_system/dut/seg_disp/regs/regs
add wave -noupdate -expand -group segment_regs /tb_system/dut/seg_disp/regs/next_regs
add wave -noupdate -expand -group segment_regs /tb_system/dut/seg_disp/regs/rdy
add wave -noupdate -expand -group segment_regs /tb_system/dut/seg_disp/regs/n_rdy
add wave -noupdate -expand -group segment_regs /tb_system/dut/seg_disp/regs/err
add wave -noupdate -expand -group segment_regs /tb_system/dut/seg_disp/regs/n_err
add wave -noupdate -expand -group segment_regs /tb_system/dut/seg_disp/regs/rdata
add wave -noupdate -expand -group segment_regs /tb_system/dut/seg_disp/regs/n_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {114585 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 293
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {393246 ps}
