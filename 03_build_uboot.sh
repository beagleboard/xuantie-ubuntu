#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- distclean
echo "make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- light_beagle_defconfig"
make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- light_beagle_defconfig
echo "make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- all"
make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- all

cp -v ./u-boot/u-boot-with-spl.bin ./deploy/

touch ./.05_generate_boot.sh
