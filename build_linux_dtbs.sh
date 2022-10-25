#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

CC=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux-

cd ./beaglev-ahead-linux/

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} dtbs

cp -v ./arch/riscv/boot/dts/thead/light-beagle.dtb ../deploy/

cd ../

