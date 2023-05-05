#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

CC=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu-

cd ./gpu_bxm_4_64-kernel/rogue_km/
echo "make ARCH=riscv CROSS_COMPILE=${CC} KERNELDIR=${wdir}/linux/ RGX_BVNC=36.52.104.182 PVR_ARCH=rogue PVR_BUILD_DIR=thead_linux WINDOW_SYSTEM="lws-generic""
make ARCH=riscv CROSS_COMPILE=${CC} KERNELDIR=${wdir}/linux/ RGX_BVNC=36.52.104.182 PVR_ARCH=rogue PVR_BUILD_DIR=thead_linux WINDOW_SYSTEM=lws-generic clean
make ARCH=riscv CROSS_COMPILE=${CC} KERNELDIR=${wdir}/linux/ RGX_BVNC=36.52.104.182 PVR_ARCH=rogue PVR_BUILD_DIR=thead_linux WINDOW_SYSTEM=lws-generic

cp -v ./binary_thead_linux_lws-generic_release/target_riscv64/kbuild/drm_nulldisp.ko ${wdir}/deploy/
cp -v ./binary_thead_linux_lws-generic_release/target_riscv64/kbuild/pvrsrvkm.ko ${wdir}/deploy/
cd ../

touch ./.07_generate_root.sh
