#!/bin/bash

wdir=`pwd`

CC=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux-

cd ./beaglev-ahead-linux/

make ARCH=riscv CROSS_COMPILE=${CC} clean
make ARCH=riscv CROSS_COMPILE=${CC} beaglev_defconfig
#make ARCH=riscv CROSS_COMPILE=${CC} menuconfig
make -j8 ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs

cp -v ./arch/riscv/boot/Image ../deploy/
cp -v ./arch/riscv/boot/dts/thead/light-beagle.dtb ../deploy/

cd ../

