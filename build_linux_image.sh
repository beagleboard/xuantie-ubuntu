#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

CC=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux-

cd ./linux/
cp -rv ../BeagleBoard-DeviceTrees/src/riscv/*.dtsi ./arch/riscv/boot/dts/thead/
cp -rv ../BeagleBoard-DeviceTrees/src/riscv/*.dts ./arch/riscv/boot/dts/thead/
cp -v ../BeagleBoard-DeviceTrees/include/dt-bindings/board/light-fm-bone-pins.h ./include/dt-bindings/board/
cp -v ../BeagleBoard-DeviceTrees/include/dt-bindings/pinctrl/light.h ./include/dt-bindings/pinctrl/

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
