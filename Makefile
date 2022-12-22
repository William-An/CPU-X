# Makefile for generating hex files
RISCV_TEST_DIR 		:= riscv-tests
OWN_TEST_DIR		:= asm
HEX_INIT_FILE		:= meminit.hex
RISCV_ELF_PREFIX	:= riscv64-unknown-elf

BENCHMARKS_DIR	:= $(RISCV_TEST_DIR)/benchmarks
UNIT_TEST_DIR	:= $(RISCV_TEST_DIR)/isa

PROJECT		:= CPU-X
REVISION 	:= top
SIMULATION_SCRIPT := /home/william/intelFPGA_lite/21.1/quartus/common/tcl/internal/nativelink/qnativesim.tcl
QSHELL_SIMULATION_FLAGS := --no_gui

# All testcase programs
# Need to modify linker script to have start address of 0x00000000
# instead of  0x80000000
RV32I_TEST_PROGRAMS := $(filter-out %.dump, $(wildcard $(RISCV_TEST_DIR)/isa/rv32ui-p-*))
RV32_PRIVI_TEST_PROGRAMS := $(filter-out %.dump, $(wildcard $(RISCV_TEST_DIR)/isa/rv32mi-p-*))
TEST_PROGRAMS += $(notdir $(RV32I_TEST_PROGRAMS))

# TODO Implement the rest of M-mode support in later iteration
# TEST_PROGRAMS += $(notdir $(RV32_PRIVI_TEST_PROGRAMS))

sim: rtl_sim gate_sim

rtl_sim: build
	@for test in $(TEST_PROGRAMS); do \
		$(MAKE) -s rtl_sim_$${test}; \
	done

gate_sim: build
	@for test in $(TEST_PROGRAMS); do \
		$(MAKE) -s gate_level_sim_$${test}; \
	done

# RISCV benchmark
benchmark_%: $(BENCHMARKS_DIR)/%.riscv
	@$(RISCV_ELF_PREFIX)-objcopy -v --set-start 0x00 -O ihex $< tmp.hex > /dev/null
	@srec_cat tmp.hex -intel -output $(HEX_INIT_FILE) -Intel -line-length=20
	@rm tmp.hex

# RISCV ISA unit test
isa_%: $(UNIT_TEST_DIR)/%
	@$(RISCV_ELF_PREFIX)-objcopy -v --set-start 0x00 -O ihex $< tmp.hex > /dev/null
	@srec_cat tmp.hex -intel -output $(HEX_INIT_FILE) -Intel -line-length=20
	@rm tmp.hex

# Build project
build:
	@quartus_sh --flow compile $(PROJECT) -c $(REVISION)

# Update meminit into the RAM
update_meminit: $(HEX_INIT_FILE)
	@quartus_cdb $(PROJECT) -c $(REVISION) --update_mif

update_meminit_silent: $(HEX_INIT_FILE)
	@quartus_cdb $(PROJECT) -c $(REVISION) --update_mif 2>&1 > /dev/null

rtl_sim_%: isa_% update_meminit_silent
	@printf "\033[0;33m[-] Simulating $@..."
	@if quartus_sh -t $(SIMULATION_SCRIPT) --rtl_sim \
		$(PROJECT) $(REVISION) $(QSHELL_SIMULATION_FLAGS) \
		| grep -q "All test passed!"; then \
		printf "\r\033[0;32m[+] RTL Sim Passed for $* test\n"; \
	else \
		printf "\r\033[0;31m[!] RTL Sim Failed for $* test\n"; \
	fi 

gate_level_sim_%: isa_% update_meminit_silent
	@printf "\033[0;33m[-] Simulating $@..."
	@if quartus_sh -t $(SIMULATION_SCRIPT) \
		$(PROJECT) $(REVISION) $(QSHELL_SIMULATION_FLAGS) \
		| grep -q "All test passed!"; then \
		printf "\r\033[K\033[0;32m[+] Gate level Sim Passed for $* test\n"; \
	else \
		printf "\r\033[0;31m[!] Gate level Sim Failed for $* test\n"; \
	fi 

test:
	@echo $(TEST_PROGRAMS)

clean:
	@rm -f tmp.hex $(HEX_INIT_FILE)