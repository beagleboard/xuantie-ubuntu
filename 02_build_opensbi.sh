#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

make -C opensbi ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- PLATFORM=generic clean
echo "make -C opensbi -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- PLATFORM=generic"
make -C opensbi -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- PLATFORM=generic

cp -v ./opensbi/build/platform/generic/firmware/fw_dynamic.bin ./deploy/

touch ./.05_generate_boot.sh
