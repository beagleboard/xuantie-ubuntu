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
# General setup
#
./scripts/config --enable CONFIG_AUDIT

#
# Scheduler features
#
# end of Scheduler features
./scripts/config --enable CONFIG_MEMCG
./scripts/config --enable CONFIG_MEMCG_KMEM
./scripts/config --enable CONFIG_BLK_CGROUP
./scripts/config --enable CONFIG_CGROUP_SCHED
./scripts/config --enable CONFIG_RT_GROUP_SCHED
./scripts/config --enable CONFIG_SCHED_MM_CID
./scripts/config --enable CONFIG_CGROUP_PIDS
./scripts/config --enable CONFIG_CGROUP_FREEZER
./scripts/config --enable CONFIG_CGROUP_RDMA
./scripts/config --enable CONFIG_CGROUP_HUGETLB
./scripts/config --enable CONFIG_CPUSETS
./scripts/config --enable CONFIG_PROC_PID_CPUSET
./scripts/config --enable CONFIG_CGROUP_BPF
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
./scripts/config --enable CONFIG_SCHED_AUTOGROUP
./scripts/config --enable CONFIG_RELAY

#
# Kernel Performance Events And Counters
#
./scripts/config --enable CONFIG_PROFILING

#
# CPU frequency scaling drivers
#
./scripts/config --enable CONFIG_SUSPEND

#
# General architecture-dependent options
#
./scripts/config --enable CONFIG_KPROBES
./scripts/config --enable CONFIG_JUMP_LABEL

#
# GCOV-based kernel profiling
#
./scripts/config --enable CONFIG_MODULE_FORCE_LOAD
./scripts/config --enable CONFIG_MODULE_FORCE_UNLOAD
./scripts/config --enable CONFIG_MODVERSIONS
./scripts/config --enable CONFIG_MODULE_COMPRESS
./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ

#
# Executable file formats
#
./scripts/config --enable CONFIG_BINFMT_MISC

#
# Networking options
#
./scripts/config --module CONFIG_PACKET_DIAG
./scripts/config --module CONFIG_UNIX_DIAG
./scripts/config --enable CONFIG_XFRM
./scripts/config --enable CONFIG_NETFILTER

#Optimize:
./scripts/config --enable CONFIG_IP_NF_IPTABLES
./scripts/config --enable CONFIG_NETFILTER_XTABLES


./scripts/config --enable CONFIG_NET_SCHED

#
# LPDDR & LPDDR2 PCM memory drivers
#
./scripts/config --enable CONFIG_OF_OVERLAY

#
# SCSI support type (disk, tape, CD-ROM)
#
./scripts/config --module CONFIG_WIREGUARD

#
# SPI Protocol Masters
#
./scripts/config --module CONFIG_SPI_SPIDEV
./scripts/config --enable CONFIG_SPI_SLAVE
./scripts/config --module CONFIG_SPI_SLAVE_TIME
./scripts/config --enable CONFIG_PPS

#
# USB Imaging devices
#
./scripts/config --enable CONFIG_USB_DWC3
./scripts/config --enable CONFIG_USB_DWC3_DUAL_ROLE
./scripts/config --enable CONFIG_USB_DWC3_THEAD

#
# USB Physical Layer drivers
#
./scripts/config --enable CONFIG_USB_GADGET
./scripts/config --enable CONFIG_USB_CONFIGFS
./scripts/config --enable CONFIG_CONFIGFS_FS
./scripts/config --enable CONFIG_USB_CONFIGFS_SERIAL
./scripts/config --enable CONFIG_USB_CONFIGFS_ACM
./scripts/config --enable CONFIG_USB_CONFIGFS_OBEX
./scripts/config --enable CONFIG_USB_CONFIGFS_NCM
./scripts/config --enable CONFIG_USB_CONFIGFS_ECM
./scripts/config --enable CONFIG_USB_CONFIGFS_ECM_SUBSET
./scripts/config --enable CONFIG_USB_CONFIGFS_RNDIS
./scripts/config --enable CONFIG_USB_CONFIGFS_EEM
./scripts/config --enable CONFIG_USB_CONFIGFS_PHONET
./scripts/config --enable CONFIG_USB_CONFIGFS_MASS_STORAGE
./scripts/config --enable CONFIG_USB_CONFIGFS_F_LB_SS
./scripts/config --enable CONFIG_USB_CONFIGFS_F_FS
./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC1
./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC2
./scripts/config --enable CONFIG_USB_CONFIGFS_F_MIDI
./scripts/config --enable CONFIG_USB_CONFIGFS_F_HID
./scripts/config --enable CONFIG_USB_CONFIGFS_F_UVC
./scripts/config --enable CONFIG_USB_CONFIGFS_F_PRINTER

#
# LED Triggers
#
./scripts/config --enable CONFIG_LEDS_TRIGGERS

./scripts/config --enable CONFIG_IIO_BUFFER

#
# File systems
#
./scripts/config --enable CONFIG_VALIDATE_FS_PARSER
./scripts/config --enable CONFIG_EXT4_FS_SECURITY
./scripts/config --enable CONFIG_BTRFS_FS
./scripts/config --enable CONFIG_BTRFS_FS_POSIX_ACL
./scripts/config --enable CONFIG_F2FS_FS
./scripts/config --enable CONFIG_F2FS_FS_SECURITY
./scripts/config --enable CONFIG_FS_ENCRYPTION
./scripts/config --enable CONFIG_FANOTIFY
./scripts/config --enable CONFIG_FSCACHE
./scripts/config --enable CONFIG_FSCACHE_STATS
./scripts/config --enable CONFIG_FSCACHE_HISTOGRAM
./scripts/config --enable CONFIG_CACHEFILES
./scripts/config --enable CONFIG_NFS_V3_ACL
./scripts/config --enable CONFIG_NFS_SWAP

#
# Security options
#
./scripts/config --enable CONFIG_SECURITY
./scripts/config --enable CONFIG_SECURITYFS
./scripts/config --enable CONFIG_SECURITY_NETWORK
./scripts/config --enable CONFIG_SECURITY_SELINUX
./scripts/config --enable CONFIG_SECURITY_TOMOYO
./scripts/config --enable CONFIG_SECURITY_APPARMOR
./scripts/config --enable CONFIG_SECURITY_YAMA
./scripts/config --enable CONFIG_DEFAULT_SECURITY_APPARMOR

#
# Library routines
#
./scripts/config --disable CONFIG_RAID6_PQ_BENCHMARK

#
# Compile-time checks and compiler options
#
./scripts/config --disable CONFIG_DEBUG_INFO

#
# Scheduler Debugging
#
./scripts/config --enable CONFIG_SCHEDSTATS

#
# Kernel Testing and Coverage
#
./scripts/config --disable CONFIG_RUNTIME_TESTING_MENU

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
