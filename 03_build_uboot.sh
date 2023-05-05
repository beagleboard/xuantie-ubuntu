#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- distclean

#make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- light_beagle_defconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- menuconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- savedefconfig
#cp -v ./u-boot/defconfig ./u-boot/configs/light_beagle_defconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- distclean

echo "make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- light_beagle_defconfig"
make -C u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- light_beagle_defconfig
echo "make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- all"
make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu- all

cp -v ./u-boot/u-boot-with-spl.bin ./deploy/

touch ./.06_generate_boot.sh
