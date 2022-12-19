# CPU-X

A RISC-V RV32IMA+Zicsr FPGA implementation.

## TODO

### Stage I: SingleCycle

1. [x] Implement unprivileged isa
2. [ ] Implement machine-mode (privileged) isa
   1. [ ] CSR register and instruction support
      1. [ ] What CSR registers needed?
         1. [ ] Those in machine-mode
            1. [ ] A total of 4096 CSRs
            2. [ ] Map those in user and supervisor mode to zeros
         2. [ ] Performance monitor could be optional
      2. [ ] Instruction needed: Zicsr extension
      3. [ ] Need to determine what additional signals needed to the CSR module
         1. [ ] Like interrupt and exception signals
   2. [ ] Interrupt/Exception generator/handler
      1. [ ] What are the interrupts and execptions needed to support?
3. [ ] Need to pass riscv isa tests in machine mode
4. [ ] Auto tester for unit test asm from riscv-tests
    1. Noted the `benchmarks` tests are with rv64?
    2. Can use ecall to pause on?
    3. Use different linker script for spike and the systemverilog one?
    4. Implement Machine-Level CSR and corresponding instructions after pipelined CPU passed
        1. Refer to the privileged ISA manual
        2. At least the Machine and the User side?

### Stage II: Pipeline

1. [ ] Implement pipeline CPU with machine-mode
2. [ ] Make sure the exception/interrupt are precise

### Stage III: Peripheral

1. [ ] Implement a memory bus to connect on-chip and off-chip RAM/ROM
2. [ ] Implement programmer? To program the chip without quartus, like a real embedded system
3. [ ] Also other embedded peripheral
4. [ ] Build a memory map

## Test cases passed

1. [x] rv32ui-p-add
2. [ ] rv32ui-p-

## Make commands

1. RISC-V Testsuite
   1. Use `make benchmark_BENCHMARK` or `make isa_ISATEST` to generate the `meminit.hex`
   2. Cannot use right now as it need some other instructions and special registers implemented (crrs)
2. asm
   1. Own unitest file, very much similar to the riscv official one

## References

1. [RISCV ISA Manual](https://github.com/riscv/riscv-isa-manual)
   1. Used 20191214-draft for unprivileged ISA
   2. Used 20211203 for privileged ISA
2. [RISCV ISA simulator](https://github.com/riscv-software-src/riscv-isa-sim)
3. [RISCV unit test benchmark suite](https://github.com/riscv-software-src/riscv-tests)
4. [Intel Quartus Lite](https://www.intel.com/content/www/us/en/software-kit/684215/intel-quartus-prime-lite-edition-design-software-version-21-1-for-linux.html)
   1. For linux
   2. Also if want to use the waveform simulator, need to register for a license