# Compile test asm for spike and SystermVerilog implementation

RISCV_PREFIX := riscv64-unknown-elf-
RISCV_CFLAGS := -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -T systemverilog.lds
RISCV_OBJDUMP_FLAGS := -Mno-aliases -Mnumeric --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data

.SUFFIXES:

# TODO Find all files with .S postfix and use as source files?
ASM_FILES := 

%.riscv: %.S
	@$(RISCV_PREFIX)gcc $(RISCV_CFLAGS) -o $*.riscv $<

%.dump: %.riscv
	@$(RISCV_PREFIX)objdump $(RISCV_OBJDUMP_FLAGS) $< > $@

%.hex: %.riscv
	@$(RISCV_PREFIX)objcopy -v -O ihex $< $*.hex.tmp > /dev/null
	@srec_cat $*.hex.tmp -intel -output $*.hex -Intel -line-length=20
	@rm -f $*.hex.tmp

clean:
	@rm -f *.dump *.hex *.riscv

