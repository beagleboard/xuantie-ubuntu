#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

cd ./linux/
cp -rv ../BeagleBoard-DeviceTrees/src/riscv/thead/*.dts ./arch/riscv/boot/dts/thead/

#if [ ! -d ./arch/riscv/boot/dts/thead/overlays/ ] ; then
#	mkdir -p ./arch/riscv/boot/dts/thead/overlays/
#fi
#cp -rv ../BeagleBoard-DeviceTrees/src/thead/overlays/*.dts ./arch/riscv/boot/dts/thead/overlays/

git diff > log.txt ; cat log.txt ; rm log.txt

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
#
