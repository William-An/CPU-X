# CPU-X

A RISC-V RV32IMA FPGA implementation.

## TODO

1. [ ] Own UNIT test asm files
    1. [ ] Use `ebreak` to generate a halt signal
    1. [ ] `add`
    1. [ ] `addi`
    1. [ ] `and`
    1. [ ] `andi`
    1. [ ] `auipc`
    1. [ ] `beq`
    1. [ ] `bge`
    1. [ ] `bgeu`
    1. [ ] `blt`
    1. [ ] `bltu`
    1. [ ] `bne`
    1. [ ] `fenci_i`
    1. [ ] `jal`
    1. [ ] `jalr`
    1. [ ] `lb`
    1. [ ] `lbu`
    1. [ ] `lh`
    1. [ ] `lhu`
    1. [ ] `lui`
    1. [ ] `lw`
    1. [ ] `or`
    1. [ ] `ori`
    1. [ ] `sb`
    1. [ ] `sh`
    1. [ ] `sll`
    1. [ ] `slli`
    1. [ ] `slt`
    1. [ ] `sltu`
    1. [ ] `sra`
    1. [ ] `srai`
    1. [ ] `srl`
    1. [ ] `srli`
    1. [ ] `sub`
    1. [ ] `sw`
    1. [ ] `xor`
    1. [ ] `xori`

1. [ ] Auto tester for unit test asm from riscv-tests
    1. Noted the `benchmarks` tests are with rv64?
    2. Can use ecall to pause on?
    3. Use different linker script for spike and the systemverilog one?
    4. Implement Machine-Level CSR and corresponding instructions after pipelined CPU passed
        1. Refer to the privileged ISA manual
        2. At least the Machine and the User side?

## Test cases passed

1. [x] rv32ui-p-add
2. [ ] rv32ui-p-
