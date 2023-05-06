#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

CC=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu-

cd ${wdir}/gpu_bxm_4_64-kernel/rogue_km/
echo "make ARCH=riscv CROSS_COMPILE=${CC} KERNELDIR=${wdir}/linux/ RGX_BVNC=36.52.104.182 PVR_ARCH=rogue PVR_BUILD_DIR=thead_linux WINDOW_SYSTEM="lws-generic""
make ARCH=riscv CROSS_COMPILE=${CC} KERNELDIR=${wdir}/linux/ RGX_BVNC=36.52.104.182 PVR_ARCH=rogue PVR_BUILD_DIR=thead_linux WINDOW_SYSTEM=lws-generic clean
make ARCH=riscv CROSS_COMPILE=${CC} KERNELDIR=${wdir}/linux/ RGX_BVNC=36.52.104.182 PVR_ARCH=rogue PVR_BUILD_DIR=thead_linux WINDOW_SYSTEM=lws-generic

cd ${wdir}/vi-kernel/
echo "make ARCH=riscv CROSS_COMPILE=${CC} LINUX_DIR=${wdir}/linux/ BOARD_NAME=light-beagle"
make ARCH=riscv CROSS_COMPILE=${CC} LINUX_DIR=${wdir}/linux/ BOARD_NAME=light-beagle clean
make ARCH=riscv CROSS_COMPILE=${CC} LINUX_DIR=${wdir}/linux/ BOARD_NAME=light-beagle

cd ${wdir}/baremetal-drivers/
echo "make ARCH=riscv CROSS_COMPILE=${CC} LINUX_DIR=${wdir}/linux/ BOARD_NAME=light-beagle"
make ARCH=riscv CROSS_COMPILE=${CC} LINUX_DIR=${wdir}/linux/ BOARD_NAME=light-beagle clean
make ARCH=riscv CROSS_COMPILE=${CC} LINUX_DIR=${wdir}/linux/ BOARD_NAME=light-beagle

cd ${wdir}/

touch ./.07_generate_root.sh
