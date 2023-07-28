#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} distclean

#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} light_beagle_defconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} menuconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} savedefconfig
#cp -v ./u-boot/defconfig ./u-boot/configs/light_beagle_defconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} distclean

echo "make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} light_beagle_defconfig"
make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} light_beagle_defconfig
echo "make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} all"
make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} all

cp -v ./u-boot/u-boot-with-spl.bin ./deploy/

touch ./.06_generate_boot.sh
