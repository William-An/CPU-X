# Makefile for generating hex files
RISCV_TEST_DIR 		:= riscv-tests
HEX_INIT_FILE		:= meminit.hex
RISCV_ELF_PREFIX	:= riscv64-unknown-elf

BENCHMARKS_DIR	:= $(RISCV_TEST_DIR)/benchmarks
UNIT_TEST_DIR	:= $(RISCV_TEST_DIR)/isa

benchmark_%: $(BENCHMARKS_DIR)/%.riscv
	@$(RISCV_ELF_PREFIX)-objcopy -v -O ihex $< tmp.hex > /dev/null
	@srec_cat tmp.hex -intel -output $(HEX_INIT_FILE) -Intel -line-length=20
	@rm tmp.hex

isa_%: $(UNIT_TEST_DIR)/%
	@$(RISCV_ELF_PREFIX)-objcopy -v -O ihex $< tmp.hex > /dev/null
	@srec_cat tmp.hex -intel -output $(HEX_INIT_FILE) -Intel -line-length=20
	@rm tmp.hex

clean:
	@rm tmp.hex meminit.hex