# CPU-X

A RISC-V RV32IMA+Zicsr FPGA implementation.

## TODO

### Stage I: SingleCycle

1. [x] Implement unprivileged isa
2. [ ] Implement machine-mode (privileged) isa
   1. [ ] CSR register and instruction support
      1. [x] What CSR registers needed?
         1. [x] Those in machine-mode
            1. [ ] A total of 4096 CSRs with default values
               1. [x] `misa`
               2. [x] `mvendorid`: zeros
               3. [x] `marchid`: zeros
               4. [x] `mimpid`: zeros
               5. [x] `mhartid`: zeros
               6. [x] `mstatus`
               7. [x] `mstatush`
               8. [x] `mtvec`
               9. [ ] ~~`medeleg` and `mideleg`~~
               10. [ ] ~~`mie` and `mip`~~
               11. [x] `mscratch`
               12. [x] `mepc`
               13. [x] `mcause`
               14. [x] `mtval`
            2. [x] Map those in user and supervisor mode to zeros
         2. [x] Performance monitor could be optional
      2. [x] Instruction needed: Zicsr extension
      3. [ ] Instruction needed: machine-level privileged instructions
         1. [ ] `ecall`
         2. [ ] `ebreak`
         3. [ ] `mret`: need to modify CSR `mstatus`
         4. [ ] `wfi`: could be a nop
      4. [ ] CSR R/W permission protection, check `index[11:10]` bits
      5. [ ] CSR fields WARL, WLRL protection
      6. [x] Need to determine what additional signals needed to the CSR module
         1. [x] Like interrupt and exception signals
   2. [ ] Interrupt/Exception generator/handler
      1. [ ] Merge with the CSR unit to faciliate easy CSR values modification 
      2. [ ] What are the interrupts and execptions needed to support?
         1. [ ] Just implement Exception for now?
            1. [ ] Inst addr misalign
            2. [ ] Inst illegal
            3. [ ] breakpoint
            4. [ ] load/store addr misalign
            5. [ ] environment call m-mode
            6. [ ] Also need to set epc
            7. [x] ~~Also need to save context?~~ Unlike STM32, software saves the context
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
3. [ ] Debugger support? Like On-chip breakpoints
4. [ ] Also other embedded peripheral
5. [ ] Build a memory map

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