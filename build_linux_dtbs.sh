#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

CC=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux-

cd ./linux/

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} dtbs

cp -v ./arch/riscv/boot/dts/thead/light-beagle.dts ../patches/linux/
cp -v ./arch/riscv/boot/dts/thead/light-beagle-ref.dts ../patches/linux/
cp -v ./arch/riscv/boot/dts/thead/light-vi-devices.dtsi ../patches/linux/
cp -v ./arch/riscv/boot/dts/thead/light.dtsi ../patches/linux/
cp -v ./arch/riscv/boot/dts/thead/light-beagle.dtb ../deploy/
cp -v ./.config ../patches/linux/beaglev_defconfig

cd ../

touch ./.05_generate_boot.sh
touch ./.06_generate_root.sh
