#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

cd ./linux/
#cp -rv ../BeagleBoard-DeviceTrees/src/riscv/*.dtsi ./arch/riscv/boot/dts/thead/
#cp -rv ../BeagleBoard-DeviceTrees/src/riscv/*.dts ./arch/riscv/boot/dts/thead/

#if [ ! -d ./arch/riscv/boot/dts/thead/overlays/ ] ; then
#	mkdir -p ./arch/riscv/boot/dts/thead/overlays/
#fi
#cp -rv ../BeagleBoard-DeviceTrees/src/riscv/overlays/*.dts ./arch/riscv/boot/dts/thead/overlays/

#if [ ! -d ./include/dt-bindings/board/ ] ; then
#	mkdir -p ./include/dt-bindings/board/
#fi
#cp -v ../BeagleBoard-DeviceTrees/include/dt-bindings/board/light-fm-bone-pins.h ./include/dt-bindings/board/
#cp -v ../BeagleBoard-DeviceTrees/include/dt-bindings/pinctrl/light.h ./include/dt-bindings/pinctrl/

#cd ../BeagleBoard-DeviceTrees/
#make clean ; make
#cd ../linux

make ARCH=riscv CROSS_COMPILE=${CC} clean

if [ ! -f ./arch/riscv/configs/beaglev_defconfig ] ; then
	cp -v ./arch/riscv/configs/light_defconfig ./arch/riscv/configs/beaglev_defconfig
fi
echo "make ARCH=riscv CROSS_COMPILE=${CC} beaglev_defconfig"
make ARCH=riscv CROSS_COMPILE=${CC} beaglev_defconfig

#
# Scheduler features
#
# end of Scheduler features

./scripts/config --enable CONFIG_MEMCG
./scripts/config --enable CONFIG_MEMCG_KMEM
./scripts/config --enable CONFIG_RT_GROUP_SCHED
./scripts/config --enable CONFIG_SCHED_MM_CID
./scripts/config --enable CONFIG_CGROUP_PIDS
./scripts/config --enable CONFIG_CGROUP_FREEZER
./scripts/config --enable CONFIG_CGROUP_HUGETLB
./scripts/config --enable CONFIG_CPUSETS
./scripts/config --enable CONFIG_PROC_PID_CPUSET
./scripts/config --enable CONFIG_CGROUP_DEVICE
./scripts/config --enable CONFIG_CGROUP_CPUACCT
./scripts/config --enable CONFIG_CGROUP_PERF
./scripts/config --enable CONFIG_NAMESPACES
./scripts/config --enable CONFIG_UTS_NS
./scripts/config --enable CONFIG_TIME_NS
./scripts/config --enable CONFIG_IPC_NS
./scripts/config --enable CONFIG_USER_NS
./scripts/config --enable CONFIG_PID_NS
./scripts/config --enable CONFIG_NET_NS
./scripts/config --enable CONFIG_CHECKPOINT_RESTORE

#Optimize:
./scripts/config --enable CONFIG_IP_NF_IPTABLES
./scripts/config --enable CONFIG_NETFILTER_XTABLES

echo "make ARCH=riscv CROSS_COMPILE=${CC} olddefconfig"
make ARCH=riscv CROSS_COMPILE=${CC} olddefconfig

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs

if [ ! -f ./arch/riscv/boot/Image ] ; then
	echo "Build Failed"
	exit 2
fi

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
#
