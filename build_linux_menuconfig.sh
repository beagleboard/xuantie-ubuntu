#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu-"}

cd ./linux/
cp -rv ../BeagleBoard-DeviceTrees/src/riscv/*.dtsi ./arch/riscv/boot/dts/thead/
cp -rv ../BeagleBoard-DeviceTrees/src/riscv/*.dts ./arch/riscv/boot/dts/thead/
cp -v ../BeagleBoard-DeviceTrees/include/dt-bindings/board/light-fm-bone-pins.h ./include/dt-bindings/board/
cp -v ../BeagleBoard-DeviceTrees/include/dt-bindings/pinctrl/light.h ./include/dt-bindings/pinctrl/

cd ../BeagleBoard-DeviceTrees/
make clean ; make
cd ../linux

cp -v ../patches/linux/beaglev_defconfig ./arch/riscv/configs/beaglev_defconfig
make ARCH=riscv CROSS_COMPILE=${CC} clean
make ARCH=riscv CROSS_COMPILE=${CC} beaglev_defconfig
make ARCH=riscv CROSS_COMPILE=${CC} menuconfig
echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs

KERNEL_UTS=$(cat "${wdir}/linux/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )

make -s ARCH=riscv CROSS_COMPILE=${CC} modules_install INSTALL_MOD_PATH="${wdir}/deploy/tmp"

if [ -f "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" ] ; then
	rm -rf "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" || true
fi
echo "Compressing ${KERNEL_UTS}-modules.tar.gz..."
echo "${KERNEL_UTS}" > "${wdir}/deploy/.modules"
cd "${wdir}/deploy/tmp" || true
tar --create --gzip --file "../${KERNEL_UTS}-modules.tar.gz" ./*
cd "${wdir}/linux/" || exit
rm -rf "${wdir}/deploy/tmp" || true

cp -v ./.config ../patches/linux/beaglev_defconfig
cp -v ./.config ./arch/riscv/configs/beaglev_defconfig
cp -v ./arch/riscv/boot/dts/thead/light-beagle.dts ../BeagleBoard-DeviceTrees/src/riscv/
cp -v ./arch/riscv/boot/dts/thead/light-beagle-ref.dts ../BeagleBoard-DeviceTrees/src/riscv/
cp -v ./arch/riscv/boot/dts/thead/light-vi-devices.dtsi ../BeagleBoard-DeviceTrees/src/riscv/
cp -v ./arch/riscv/boot/dts/thead/light.dtsi ../BeagleBoard-DeviceTrees/src/riscv/
cp -v ./arch/riscv/boot/Image ../deploy/
cp -v ./arch/riscv/boot/dts/thead/light-beagle.dtb ../deploy/

cd ../

touch ./.05_generate_boot.sh
touch ./.06_generate_root.sh
