onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_minibus/tb_clk
add wave -noupdate /tb_minibus/tb_nrst
add wave -noupdate -expand /tb_minibus/tb_seg_ctrl
add wave -noupdate -group tb_msif /tb_minibus/tb_msif/clk
add wave -noupdate -group tb_msif /tb_minibus/tb_msif/nrst
add wave -noupdate -group tb_msif /tb_minibus/tb_msif/req
add wave -noupdate -group tb_msif /tb_minibus/tb_msif/res
add wave -noupdate -group ram_slaveif {/tb_minibus/slave_dev_ifs[0]/clk}
add wave -noupdate -group ram_slaveif {/tb_minibus/slave_dev_ifs[0]/nrst}
add wave -noupdate -group ram_slaveif {/tb_minibus/slave_dev_ifs[0]/sel}
add wave -noupdate -group ram_slaveif {/tb_minibus/slave_dev_ifs[0]/req}
add wave -noupdate -group ram_slaveif {/tb_minibus/slave_dev_ifs[0]/res}
add wave -noupdate -group seg_slaveif {/tb_minibus/slave_dev_ifs[1]/clk}
add wave -noupdate -group seg_slaveif {/tb_minibus/slave_dev_ifs[1]/nrst}
add wave -noupdate -group seg_slaveif {/tb_minibus/slave_dev_ifs[1]/sel}
add wave -noupdate -group seg_slaveif {/tb_minibus/slave_dev_ifs[1]/req}
add wave -noupdate -group seg_slaveif -subitemconfig {{/tb_minibus/slave_dev_ifs[1]/res.rdata} -expand} {/tb_minibus/slave_dev_ifs[1]/res}
add wave -noupdate -expand -group slave_regs /tb_minibus/seg_disp/regs/outputs
add wave -noupdate -expand -group slave_regs /tb_minibus/seg_disp/regs/regs
add wave -noupdate -expand -group slave_regs /tb_minibus/seg_disp/regs/next_regs
add wave -noupdate -expand -group slave_regs /tb_minibus/seg_disp/regs/rdy
add wave -noupdate -expand -group slave_regs /tb_minibus/seg_disp/regs/n_rdy
add wave -noupdate -expand -group slave_regs /tb_minibus/seg_disp/regs/err
add wave -noupdate -expand -group slave_regs /tb_minibus/seg_disp/regs/n_err
add wave -noupdate -expand -group slave_regs /tb_minibus/seg_disp/regs/rdata
add wave -noupdate -expand -group slave_regs /tb_minibus/seg_disp/regs/n_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {123849 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {157500 ps}
