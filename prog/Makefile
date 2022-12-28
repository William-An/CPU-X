# Compile test program
# Use bash
SHELL := bash

# Compiler and objdump flags
RISCV_PREFIX := riscv64-unknown-elf-
RISCV_CFLAGS := -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles 
RISCV_OBJDUMP_FLAGS := -Mno-aliases -Mnumeric --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data --section=.tohost
OBJCOPY_FLAGS		:= --only-section=.text --only-section=.text.startup --only-section=.text.init \
					   --only-section=.data -v --set-start 0x00 --reverse-bytes=4 -O ihex

LINKER_OPTS			:= -T cpu_x.lds
START_FILE			:= _start.S

# Disable auto rules for .S files
.SUFFIXES:

# TODO Find all files with .S postfix and use as source files?
# TODO 
ASM_FILES := 

# Making executables and source files
%.riscv: %.c $(START_FILE)
	@$(RISCV_PREFIX)gcc $(RISCV_CFLAGS) $(LINKER_OPTS) -o $*.riscv $^

%.dump: %.riscv
	@$(RISCV_PREFIX)objdump $(RISCV_OBJDUMP_FLAGS) $< > $@

# Making launch memory map for Quartus
%.hex: %.riscv
	@$(RISCV_PREFIX)objcopy $(OBJCOPY_FLAGS) $< $*.hex.tmp > /dev/null
	@srec_cat $*.hex.tmp -intel -output $*.hex -Intel -line-length=20
	@rm -f $*.hex.tmp

clean:
	@rm -f *.dump *.hex *.riscv

# Clean supportive files
clean_support:
	@rm -f *.dump *.hex
