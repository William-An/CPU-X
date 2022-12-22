transcript on

# This is the file that RTL and Gate sim
# 	will call after compilation
# Now we need to decide if the current simulation
# 	is RTL or Gate level
# If Gate level, we will need to recompile the test bench
# 	with `define MAPPED, else we do nothing
# To do so, first use `vmap work` to get the current library
#	that QuestaSim is working on

# First write the worklib info to file and read into a variable
vmap work > curr_worklib.out
set fp [open curr_worklib.out r]
set curr_worklib [read $fp]
close $fp

# If Gate level simulation, recompile testbench
if {[string first "gate_work" $curr_worklib] != -1} {
	if {[file exists gate_work]} {
		vdel -lib gate_work -all
	}

	vlib gate_work
	vmap work gate_work

	vlog +define+MAPPED -sv -work work +incdir+. {top.svo}

	vlog +define+MAPPED -sv -work work +incdir+../../testbench {../../testbench/tb_system.sv}

	vsim -t 1ps -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  tb_system
} else {
	# Compile testbench and launch simulation in RTL mode
	vlog -sv -work work +incdir+../../testbench {../../testbench/tb_system.sv}
	vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_system
}

# Load waveform file
do "../../scripts/singlecycle_waveform.do"

# Run simulation
run -all