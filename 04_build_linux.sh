#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

cd ./linux/
cp -rv ../BeagleBoard-DeviceTrees/src/riscv/thead/*.dtsi ./arch/riscv/boot/dts/thead/
cp -rv ../BeagleBoard-DeviceTrees/src/riscv/thead/*.dts ./arch/riscv/boot/dts/thead/

#if [ ! -d ./arch/riscv/boot/dts/thead/overlays/ ] ; then
#	mkdir -p ./arch/riscv/boot/dts/thead/overlays/
#fi
#cp -rv ../BeagleBoard-DeviceTrees/src/thead/overlays/*.dts ./arch/riscv/boot/dts/thead/overlays/

git diff > log.txt ; cat log.txt ; rm log.txt

cd ../BeagleBoard-DeviceTrees/
make clean ; make
cd ../linux

echo "make ARCH=riscv CROSS_COMPILE=${CC} clean"
make ARCH=riscv CROSS_COMPILE=${CC} clean

echo "make ARCH=riscv CROSS_COMPILE=${CC} defconfig"
make ARCH=riscv CROSS_COMPILE=${CC} defconfig

./scripts/config --disable CONFIG_LOCALVERSION_AUTO
./scripts/config --set-str CONFIG_LOCALVERSION "-$(date +%Y%m%d)"

./scripts/config --enable CONFIG_OF_OVERLAY

#Ethernet
./scripts/config --enable CONFIG_DWMAC_THEAD

#TH1520 MMC
./scripts/config --enable CONFIG_MMC_SDHCI_OF_DWCMSHC
./scripts/config --enable CONFIG_DW_AXI_DMAC
./scripts/config --disable CONFIG_ARCH_R9A07G043
#CONFIG_DMA_GLOBAL_POOL breaks ADMA

#TH1520 RESET
./scripts/config --enable CONFIG_RESET_TH1520

#GPIO:
./scripts/config --enable CONFIG_GPIO_SYSFS
./scripts/config --enable CONFIG_GPIO_DWAPB
./scripts/config --enable CONFIG_PINCTRL_TH1520

#SPI
./scripts/config --enable CONFIG_SPI_DESIGNWARE
./scripts/config --enable CONFIG_SPI_DW_MMIO

#CLOCK
./scripts/config --enable CONFIG_CLK_THEAD_TH1520_AP

#Mailbox
./scripts/config --enable CONFIG_THEAD_TH1520_MBOX

#Cleanup large PCI/DRM...
./scripts/config --disable CONFIG_PCI
./scripts/config --disable CONFIG_DRM

#Optimize:
./scripts/config --enable CONFIG_IP_NF_IPTABLES
./scripts/config --enable CONFIG_NETFILTER_XTABLES
./scripts/config --disable CONFIG_RAID6_PQ_BENCHMARK

#iwd
./scripts/config --enable CONFIG_CRYPTO_USER_API_HASH
./scripts/config --enable CONFIG_CRYPTO_USER_API_SKCIPHER
./scripts/config --enable CONFIG_ASYMMETRIC_KEY_TYPE
./scripts/config --enable CONFIG_KEY_DH_OPERATIONS
./scripts/config --enable CONFIG_CRYPTO_ECB
./scripts/config --enable CONFIG_CRYPTO_MD4
./scripts/config --enable CONFIG_CRYPTO_MD5
./scripts/config --enable CONFIG_CRYPTO_CBC
./scripts/config --enable CONFIG_CRYPTO_SHA1
./scripts/config --enable CONFIG_CRYPTO_SHA256
./scripts/config --enable CONFIG_CRYPTO_SHA512
./scripts/config --enable CONFIG_CRYPTO_AES
./scripts/config --enable CONFIG_CRYPTO_DES
./scripts/config --enable CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE
./scripts/config --enable CONFIG_CRYPTO_CMAC
./scripts/config --enable CONFIG_PKCS7_MESSAGE_PARSER
./scripts/config --enable CONFIG_CRYPTO_HMAC
./scripts/config --enable CONFIG_X509_CERTIFICATE_PARSER
./scripts/config --enable CONFIG_PKCS8_PRIVATE_KEY_PARSER

./scripts/config --disable CONFIG_RT_GROUP_SCHED

./scripts/config --enable CONFIG_BLK_CGROUP
./scripts/config --enable CONFIG_CGROUP_WRITEBACK
./scripts/config --enable CONFIG_BLK_CGROUP_RWSTAT
./scripts/config --enable CONFIG_BLK_DEV_THROTTLING
./scripts/config --enable CONFIG_BFQ_GROUP_IOSCHED
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_MARK
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_BPF

#Docker.io
./scripts/config --enable CONFIG_NETFILTER_XT_MATCH_IPVS
./scripts/config --enable CONFIG_CGROUP_BPF
./scripts/config --enable CONFIG_BLK_DEV_THROTTLING
./scripts/config --enable CONFIG_NET_CLS_CGROUP
./scripts/config --enable CONFIG_CGROUP_NET_PRIO
./scripts/config --enable CONFIG_IP_NF_TARGET_REDIRECT
./scripts/config --enable CONFIG_IP_VS
./scripts/config --enable CONFIG_IP_VS_NFCT
./scripts/config --enable CONFIG_IP_VS_PROTO_TCP
./scripts/config --enable CONFIG_IP_VS_PROTO_UDP
./scripts/config --enable CONFIG_IP_VS_RR
./scripts/config --enable CONFIG_SECURITY_SELINUX
./scripts/config --enable CONFIG_SECURITY_APPARMOR
./scripts/config --enable CONFIG_VXLAN
./scripts/config --enable CONFIG_IPVLAN
./scripts/config --enable CONFIG_DUMMY
./scripts/config --enable CONFIG_NF_NAT_FTP
./scripts/config --enable CONFIG_NF_CONNTRACK_FTP
./scripts/config --enable CONFIG_NF_NAT_TFTP
./scripts/config --enable CONFIG_NF_CONNTRACK_TFTP
./scripts/config --enable CONFIG_DM_THIN_PROVISIONING
./scripts/config --enable CONFIG_CGROUP_MISC

#enable CONFIG_DYNAMIC_FTRACE
./scripts/config --enable CONFIG_FUNCTION_TRACER
./scripts/config --enable CONFIG_DYNAMIC_FTRACE

./scripts/config --enable CONFIG_MODULE_COMPRESS
./scripts/config --disable CONFIG_MODULE_COMPRESS_GZIP
./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ
./scripts/config --disable CONFIG_MODULE_COMPRESS_ZSTD
./scripts/config --enable CONFIG_MODULE_COMPRESS_ALL

./scripts/config --module CONFIG_ZRAM
./scripts/config --enable CONFIG_ZRAM_BACKEND_LZ4
./scripts/config --enable CONFIG_ZRAM_BACKEND_LZ4HC
./scripts/config --enable CONFIG_ZRAM_BACKEND_ZSTD
./scripts/config --enable CONFIG_ZRAM_BACKEND_DEFLATE
./scripts/config --enable CONFIG_ZRAM_DEF_COMP_LZ4
./scripts/config --set-str CONFIG_ZRAM_DEF_COMP "lz4"

./scripts/config --enable CONFIG_ZSWAP

./scripts/config --enable CONFIG_FW_LOADER_COMPRESS
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_XZ
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_ZSTD

echo "make ARCH=riscv CROSS_COMPILE=${CC} olddefconfig"
make ARCH=riscv CROSS_COMPILE=${CC} olddefconfig

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE="ccache ${CC}" Image modules dtbs

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

cp -v ./arch/riscv/boot/dts/thead/th1520-beaglev-ahead.dts ../BeagleBoard-DeviceTrees/src/riscv/thead/
cp -v ./.config ../patches/linux/beaglev_defconfig
cp -v ./arch/riscv/boot/Image ../deploy/
cp -v ./arch/riscv/boot/dts/thead/*.dtb ../deploy/

cd ../

git diff > log.txt ; cat log.txt ; rm log.txt

touch ./.05_generate_boot.sh
touch ./.06_generate_root.sh
#
