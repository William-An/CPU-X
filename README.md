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
      3. [x] Instruction needed: machine-level privileged instructions
         1. [X] `ecall`
         2. [X] `ebreak`
         3. [x] `mret`: need to modify CSR `mstatus`
         4. [x] ~~`fence`~~ (Implemented as NOP for now)
         5. [X] `wfi`: could be a nop
      4. [ ] CSR R/W permission protection, check `index[11:10]` bits
      5. [ ] CSR fields WARL, WLRL protection
      6. [x] Need to determine what additional signals needed to the CSR module
         1. [x] Like interrupt and exception signals
   2. [x] Interrupt/Exception generator/handler
      1. [x] Merge with the CSR unit to faciliate easy CSR values modification 
      2. [x] What are the interrupts and execptions needed to support?
         1. [x] Just implement Exception for now?
            1. [x] Inst addr misalign
            2. [x] Inst illegal
            3. [x] environment breakpoint
            4. [x] load/store addr misalign
            5. [x] environment call m-mode
            6. [x] Also need to set epc
            7. [x] ~~Also need to save context?~~ Unlike STM32, software saves the context
3. [x] Need to pass riscv isa tests in machine mode
   1. [x] RTL Level
   2. [x] GATE Level
      1. [x] Let TB listen on the RAM signals, waiting for writes to toHOST memory region with the value
   3. [ ] Multi-cycle latency RAM
      1. [ ] For odd cycles latency, multiple ihit/dhit will occur
      2. [x] Need to update processor state only once in a multi-cycle wait for inst fetch
         1. [x] By updating CSR and regfile only when ihit for regular inst
         2. [x] Update regfile for load operation only when dhit
4. [x] Auto tester for unit test asm from riscv-tests

### Stage II: Pipeline

1. [ ] Implement pipeline CPU with machine-mode
2. [ ] Make sure the exception/interrupt are precise
3. [ ] Group interface signals into event packet struct, like instruction fetch, memory_ldst

### Stage III: Peripheral

1. [ ] Implement a memory bus to connect on-chip and off-chip RAM/ROM
2. [ ] `FENCE` and RISCV memory consistency model?
3. [ ] Implement programmer? To program the chip without quartus, like a real embedded system
4. [ ] Debugger support? Like On-chip breakpoints
5. [ ] Also other embedded peripheral
6. [ ] Build a memory map
7. [ ] Coverage report?

## Make commands

1. RISC-V Testsuite
   1. Use `make benchmark_BENCHMARK` or `make isa_ISATEST` to generate the `meminit.hex`

## References

1. [RISCV ISA Manual](https://github.com/riscv/riscv-isa-manual)
   1. Used 20191214-draft for unprivileged ISA
   2. Used 20211203 for privileged ISA
2. [RISCV ISA simulator](https://github.com/riscv-software-src/riscv-isa-sim)
3. [RISCV unit test benchmark suite](https://github.com/riscv-software-src/riscv-tests)
4. [Intel Quartus Lite](https://www.intel.com/content/www/us/en/software-kit/684215/intel-quartus-prime-lite-edition-design-software-version-21-1-for-linux.html)
   1. For linux
   2. Also if want to use the waveform simulator, need to register for a license