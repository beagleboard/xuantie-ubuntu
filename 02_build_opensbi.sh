#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

make -C opensbi ARCH=riscv CROSS_COMPILE=${CC} PLATFORM=generic clean
echo "make -C opensbi -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} PLATFORM=generic"
make -C opensbi -j${CORES} ARCH=riscv CROSS_COMPILE="ccache ${CC}" PLATFORM=generic

cp -v ./opensbi/build/platform/generic/firmware/fw_dynamic.bin ./deploy/

touch ./.06_generate_boot.sh
