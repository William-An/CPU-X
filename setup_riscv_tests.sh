#! /bin/bash
git clone git@github.com:riscv-software-src/riscv-tests.git
cd riscv-tests
git submodule update --init --recursive
autoconf
./configure --prefix=$RISCV/target
# You might want to add -Mno-aliases -Mnumeric to the objdumo flags to view
# real instruction and numeric register name
make