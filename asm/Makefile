# Compile test asm for spike and SystermVerilog implementation
# Use bash
SHELL := bash

# Compiler and objdump flags
RISCV_PREFIX := riscv64-unknown-elf-
RISCV_CFLAGS := -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles 
RISCV_OBJDUMP_FLAGS := -Mno-aliases -Mnumeric --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data --section=.tohost

LINKER_OPTS			:= -T systemverilog.lds
SPIKE_LINKER_OPTS	:= -T spike32.lds 

# Simulator configs
SIM_RBB_PORT_NUM	:= 9824
SIM_GDB_FILE		:= spike_dump.gdbcmd

# Halt if reg 31 has value of 0xbeefbeef
HALT_REG			:= 31
HALT_REG_VALUE		:= 0xbeefbeef

# Disable auto rules for .S files
.SUFFIXES:

# TODO Find all files with .S postfix and use as source files?
ASM_FILES := 

# Making executables and source files
%.riscv: %.S
	@$(RISCV_PREFIX)gcc $(RISCV_CFLAGS) $(LINKER_OPTS) -o $*.riscv $<

%.riscv_expand_macro: %.S
	@$(RISCV_PREFIX)gcc -E $(RISCV_CFLAGS) $(LINKER_OPTS) -o $*.riscv_expand_macro $<

# Compile using spike linker script and enable macros in util.h for spike
%.spike: %.S
	@$(RISCV_PREFIX)gcc $(RISCV_CFLAGS) $(SPIKE_LINKER_OPTS) -DSPIKE -o $*.spike $<

%.spike_expand_macro: %.S
	@$(RISCV_PREFIX)gcc -E $(RISCV_CFLAGS) $(SPIKE_LINKER_OPTS) -DSPIKE -o $*.spike_expand_macro $<

%.dump: %.riscv
	@$(RISCV_PREFIX)objdump $(RISCV_OBJDUMP_FLAGS) $< > $@

%.spike_dump: %.spike
	@$(RISCV_PREFIX)objdump $(RISCV_OBJDUMP_FLAGS) $< > $@

# Making launch memory map for Quartus
%.hex: %.riscv
	@$(RISCV_PREFIX)objcopy -v -O ihex $< $*.hex.tmp > /dev/null
	@srec_cat $*.hex.tmp -intel -output $*.hex -Intel -line-length=20
	@rm -f $*.hex.tmp

# Launch spike simulator
%.sim: %.spike spike.cfg spike_dump.gdbcmd
	spike -p1 --priv=m --isa=RV32I --rbb-port=$(SIM_RBB_PORT_NUM) $<

# Get simulator memory dump, need to launch the simulator first
%.sim.dump: %.spike
	openocd -f spike.cfg &
	riscv64-unknown-elf-gdb -l 1 -x $(SIM_GDB_FILE) $< > $*.gdblog
	srec_cat memsim.hex.tmp -intel -output memsim.hex -Intel -line-length=20
	rm memsim.hex.tmp
	killall -SIGKILL openocd


clean:
	@rm -f *.dump *.hex *.riscv *.spike *.spike_dump *.spike_expand_macro *.gdblog

# Clean supportive files
clean_support:
	@rm -f *.dump *.hex *.spike_dump *.spike_expand_macro *.gdblog
