#!/bin/bash

wdir=`pwd`

make -C opensbi ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- PLATFORM=generic clean
make -C opensbi ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- PLATFORM=generic

cp -v ./opensbi/build/platform/generic/firmware/fw_dynamic.bin ./deploy/
