#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

CC=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux-

cd ./beaglev-ahead-linux/

cp -v ../patches/linux/light-beagle.dts ./arch/riscv/boot/dts/thead/
cp -v ../patches/linux/light-ant-evt.dts ./arch/riscv/boot/dts/thead/
cp -v ../patches/linux/light.dtsi ./arch/riscv/boot/dts/thead/
echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} dtbs

cp -v ./arch/riscv/boot/dts/thead/light-beagle.dts ../patches/linux/
cp -v ./arch/riscv/boot/dts/thead/light-ant-evt.dts ../patches/linux/
cp -v ./arch/riscv/boot/dts/thead/light.dtsi ../patches/linux/
cp -v ./arch/riscv/boot/dts/thead/light-beagle.dtb ../deploy/

cd ../

touch ./.05_generate_boot.sh
touch ./.06_generate_root.sh
