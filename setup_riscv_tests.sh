#! /bin/bash
git clone git@github.com:riscv-software-src/riscv-tests.git
cd riscv-tests
git submodule update --init --recursive
autoconf
./configure --prefix=$RISCV/target
make