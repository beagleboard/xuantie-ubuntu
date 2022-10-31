#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

CC=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux-

cd ./beaglev-ahead-linux/

cp -v ../patches/linux/beaglev_defconfig ./arch/riscv/configs/beaglev_defconfig
cp -v ../patches/linux/light-beagle.dts ./arch/riscv/boot/dts/thead/
cp -v ../patches/linux/light-ant-evt.dts ./arch/riscv/boot/dts/thead/
cp -v ../patches/linux/light.dtsi ./arch/riscv/boot/dts/thead/
make ARCH=riscv CROSS_COMPILE=${CC} clean
make ARCH=riscv CROSS_COMPILE=${CC} beaglev_defconfig
echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs

KERNEL_UTS=$(cat "${wdir}/beaglev-ahead-linux/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )

make -s ARCH=riscv CROSS_COMPILE=${CC} modules_install INSTALL_MOD_PATH="${wdir}/deploy/tmp"

if [ -f "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" ] ; then
	rm -rf "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" || true
fi
echo "Compressing ${KERNEL_UTS}-modules.tar.gz..."
echo "${KERNEL_UTS}-modules" > "${wdir}/deploy/.modules"
cd "${wdir}/deploy/tmp" || true
tar --create --gzip --file "../${KERNEL_UTS}-modules.tar.gz" ./*
cd "${wdir}/beaglev-ahead-linux/" || exit
rm -rf "${wdir}/deploy/tmp" || true

cp -v ./.config ../patches/linux/beaglev_defconfig
cp -v ./arch/riscv/boot/dts/thead/light-beagle.dts ../patches/linux/
cp -v ./arch/riscv/boot/dts/thead/light-ant-evt.dts ../patches/linux/
cp -v ./arch/riscv/boot/dts/thead/light.dtsi ../patches/linux/
cp -v ./arch/riscv/boot/Image ../deploy/
cp -v ./arch/riscv/boot/dts/thead/light-beagle.dtb ../deploy/

cd ../

