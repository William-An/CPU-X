# Compile test asm for spike and SystermVerilog implementation

RISCV_PREFIX := riscv64-unknown-elf-
RISCV_CFLAGS := -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles 
RISCV_OBJDUMP_FLAGS := -Mno-aliases -Mnumeric --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data

LINKER_OPTS			:= -T systemverilog.lds
SPIKE_LINKER_OPTS	:= -T spike32.lds 

# Disable auto rules for .S files
.SUFFIXES:

# TODO Find all files with .S postfix and use as source files?
ASM_FILES := 

%.riscv: %.S
	@$(RISCV_PREFIX)gcc $(RISCV_CFLAGS) $(LINKER_OPTS) -o $*.riscv $<

# Compile using spike linker script and enable macros in util.h for spike
# TODO Right now the spike will run indefinitely in a deadloop, need to check
# TODO the value in x3 or gp register. If zero, all tests passed, else contains the failed test num
%.spike: %.S
	@$(RISCV_PREFIX)gcc $(RISCV_CFLAGS) $(SPIKE_LINKER_OPTS) -DSPIKE -o $*.spike $<

%.dump: %.riscv
	@$(RISCV_PREFIX)objdump $(RISCV_OBJDUMP_FLAGS) $< > $@

%.spike_dump: %.spike
	@$(RISCV_PREFIX)objdump $(RISCV_OBJDUMP_FLAGS) $< > $@

%.hex: %.riscv
	@$(RISCV_PREFIX)objcopy -v -O ihex $< $*.hex.tmp > /dev/null
	@srec_cat $*.hex.tmp -intel -output $*.hex -Intel -line-length=20
	@rm -f $*.hex.tmp

clean:
	@rm -f *.dump *.hex *.riscv *.spike *.spike_dump

