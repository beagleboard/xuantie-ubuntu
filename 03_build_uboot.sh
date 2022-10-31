#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

cd ./beaglev-ahead-u-boot/
rm -f board/thead/light-c910/version_rollback.c || true
git reset HEAD --hard
patch -p1 < ../patches/u-boot/0001-no-strip-fw_printenv.patch
patch -p1 < ../patches/u-boot/0002-Add-factory-reset-env-to-uboot.patch
patch -p1 < ../patches/u-boot/0003-LIGHT-Automatic-version-rollback-when-upgrade-fails.patch
patch -p1 < ../patches/u-boot/0004-fix-scripts-dtc-dtc-lexer.l-for-gcc10.patch

cp -v ../patches/u-boot/light-c910.h ./include/configs/

cd ../

wdir=`pwd`

make -C beaglev-ahead-u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- distclean
echo "make -C beaglev-ahead-u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- light_beagle_defconfig"
make -C beaglev-ahead-u-boot ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- light_beagle_defconfig
echo "make -C beaglev-ahead-u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- all"
make -C beaglev-ahead-u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${wdir}/riscv-toolchain/riscv-toolchain/bin/riscv64-linux- all

cp -v ./beaglev-ahead-u-boot/u-boot-with-spl.bin ./deploy/

cd ./beaglev-ahead-u-boot/
rm -f board/thead/light-c910/version_rollback.c || true
git reset HEAD --hard
cd ../

touch ./.05_generate_boot.sh
