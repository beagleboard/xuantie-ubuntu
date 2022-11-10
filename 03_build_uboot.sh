#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

cd ./beaglev-ahead-u-boot/
git reset HEAD --hard

cp -v ../patches/u-boot/light-c910.h ./include/configs/

cd ../

wdir=`pwd`

make -C beaglev-ahead-u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- distclean
echo "make -C beaglev-ahead-u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- light_beagle_defconfig"
make -C beaglev-ahead-u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- light_beagle_defconfig
echo "make -C beaglev-ahead-u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- all"
make -C beaglev-ahead-u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- all

cp -v ./beaglev-ahead-u-boot/u-boot-with-spl.bin ./deploy/

cd ./beaglev-ahead-u-boot/
git reset HEAD --hard
cd ../

touch ./.05_generate_boot.sh
