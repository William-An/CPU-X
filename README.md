# CPU-X

[![wakatime](https://wakatime.com/badge/user/b8ccd381-59c8-4b8b-8a80-7f93d4fd2d03/project/2e5364bf-f6cc-41c4-8a2f-6bccabc19451.svg)](https://wakatime.com/badge/user/b8ccd381-59c8-4b8b-8a80-7f93d4fd2d03/project/2e5364bf-f6cc-41c4-8a2f-6bccabc19451)

A RISC-V RV32I+Zicsr FPGA implementation.

## Mini-Bus protocol

Mini-Bus is a simple bus protocol used to connect the CPU core with other components like memory and memory-mapped peripherals in this project.

### Mini-Bus signals

- `clk`: bus clock
- `nrst`: bus reset
- `addr`: bus address signals, 32-bit
- `wdata`: bus write data signals, 32-bit
  - Always right-aligned for storing byte or half-word
- `rdata`: bus read data signals, 32-bit
- `width`: bus data width, 2-bit
  - `00`: byte access
  - `01`: half word access
  - `10`: full word access
- `ren`: bus read enable
  - If set, signaling this request is a read request
- `wen`: bus write enable
  - If set, signaling this is a write request
- `err`: bus master error signal
  - Connect to the current slave device being selected
- `ack`: bus master acknowledge
  - If set, signaling the request is completed and master should read available data/start next request
- Slave signals
  - `selx`: bus slave x select signal
    - Set based on the memory address assigned to each slave device
  - `ackx`: bus slave x acknowledge signal
  - `errx`: bus slave x error signal

### Waveform examples

Using [Wavedrom](https://github.com/wavedrom/wavedrom) for visualization.

#### Mini-Bus Write

<div style="background-color: #EBEBEB">
<img src="https://svg.wavedrom.com/github/William-An/CPU-X/main/docs/mini-bus-write-waveform.json5"/>
</div>

#### Mini-Bus Read

<div style="background-color: #EBEBEB">
<img src="https://svg.wavedrom.com/github/William-An/CPU-X/main/docs/mini-bus-read-waveform.json5"/>
</div>

#### Mini-Bus read and write

<div style="background-color: #EBEBEB">
<img src="https://svg.wavedrom.com/github/William-An/CPU-X/main/docs/mini-bus-read-write-waveform.json5"/>
</div>

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
   3. [x] Multi-cycle latency RAM
      1. [x] 0 cycle latency
      2. [x] 2 cycles latency
      3. [x] 3 cycles latency
      4. [x] 7 cycles latency
      5. [x] 10 cycles latency
      6. [x] For odd cycles latency, dhit/ihit will need hit twice
         1. Since the first hit is on the failing edge of CPU clock (RAM clk is twice as fast as the CPU clk)
         2. So the effective latency will be double if we don't sync the RAM ack with CPU clock
         3. Fix this in later iteration since we don't want single cycle to be burdened with performance. 
      7. [x] Need to update processor state only once in a multi-cycle wait for inst fetch
         1. [x] By updating CSR and regfile only when ihit for regular inst
         2. [x] Update regfile for load operation only when dhit
4. [x] Auto tester for unit test asm from riscv-tests

### Stage I.a: Simple Peripheral

1. [x] Mini-Bus protocol
2. [x] For non-word loads, put data in right-aligned format or maintain same offset in memory?
   1. If load a byte `0xAA` at address `0x1`, do we want `0x000000AA` or `0x0000AA00`?
   2. Probably the first one as the address bus already contain the offset information, no need to include redundant information on the data bus as well
   3. [x] Also no need on RISCV side to shift the offseted data
   4. [x] Add this to Mini-Bus protocol
3. [ ] Simple IO
   1. [x] LED Segement
   2. [ ] Off-chip RAM

### Stage I.b: Dev tool improvement

1. [ ] Create a custom testbench compilation script to properly load folders in `components` with simulator
   1. [ ] The default one will prompt `Folder exists` error if rerun simulation, requiring manually deletion of the `modelsim` folder everytime
2. [ ] Create different revisions for testbench mapped simulation and FPGA download
   1. [ ] The FPGA one is with `system_fpga.sv` and the testbench should have `system.sv` as top module
3. [ ] CI/CD integration with coverage report?

### Stage II: Pipeline

1. [ ] Implement pipeline CPU with machine-mode
2. [ ] Make sure the exception/interrupt are precise
3. [ ] Group interface signals into event packet struct, like instruction fetch, memory_ldst

### Stage II.a: M- and A- extensions support

1. [ ] Add `M-` extension
2. [ ] Add `A-` extension

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
   2. Use `make own_PROG` to compile programs inside `prog` folder

## References

1. [RISCV ISA Manual](https://github.com/riscv/riscv-isa-manual)
   1. Used 20191214-draft for unprivileged ISA
   2. Used 20211203 for privileged ISA
2. [RISCV ISA simulator](https://github.com/riscv-software-src/riscv-isa-sim)
3. [RISCV unit test benchmark suite](https://github.com/riscv-software-src/riscv-tests)
4. [Intel Quartus Lite](https://www.intel.com/content/www/us/en/software-kit/684215/intel-quartus-prime-lite-edition-design-software-version-21-1-for-linux.html)
   1. For linux
   2. Also if want to use the waveform simulator, need to register for a license
