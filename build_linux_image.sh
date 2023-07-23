#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

CC=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu-

cd ./linux/
cp -rv ../BeagleBoard-DeviceTrees/src/thead/*.dts ./arch/riscv/boot/dts/thead/
echo "# SPDX-License-Identifier: GPL-2.0" > arch/riscv/boot/dts/thead/Makefile
echo "dtb-\$(CONFIG_ARCH_THEAD) += th1520-lichee-pi-4a.dtb" >> arch/riscv/boot/dts/thead/Makefile
echo "dtb-\$(CONFIG_ARCH_THEAD) += th1520-beaglev-ahead.dtb" >> arch/riscv/boot/dts/thead/Makefile

cd ../BeagleBoard-DeviceTrees/
make clean ; make
cd ../linux

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image

cp -v ./.config ../patches/linux/beaglev_defconfig
cp -v ./arch/riscv/boot/Image ../deploy/

cd ../

touch ./.05_generate_boot.sh
touch ./.06_generate_root.sh
