#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

cd ./linux/
#cp -rv ../BeagleBoard-DeviceTrees/src/thead/*.dtsi ./arch/riscv/boot/dts/thead/
#cp -rv ../BeagleBoard-DeviceTrees/src/thead/*.dts ./arch/riscv/boot/dts/thead/

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

#TH1520 MMC
./scripts/config --enable CONFIG_MMC_SDHCI_OF_DWCMSHC
./scripts/config --enable CONFIG_DW_AXI_DMAC
./scripts/config --disable CONFIG_ARCH_R9A07G043
#CONFIG_DMA_GLOBAL_POOL breaks ADMA

#TH1520 PHY
./scripts/config --enable CONFIG_DWMAC_THEAD

#Cleanup large PCI/DRM...
./scripts/config --disable CONFIG_PCI
./scripts/config --disable CONFIG_DRM

#Optimize:
./scripts/config --enable CONFIG_IP_NF_IPTABLES
./scripts/config --enable CONFIG_NETFILTER_XTABLES

#iwd
./scripts/config --enable CONFIG_CRYPTO_USER_API_HASH
./scripts/config --enable CONFIG_CRYPTO_USER_API_SKCIPHER
./scripts/config --enable CONFIG_ASYMMETRIC_KEY_TYPE
./scripts/config --enable CONFIG_KEY_DH_OPERATIONS
./scripts/config --enable CONFIG_CRYPTO_ECB
./scripts/config --enable CONFIG_CRYPTO_MD5
./scripts/config --enable CONFIG_CRYPTO_CBC
./scripts/config --enable CONFIG_CRYPTO_AES
./scripts/config --enable CONFIG_CRYPTO_DES
./scripts/config --enable CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE
./scripts/config --enable CONFIG_CRYPTO_CMAC
./scripts/config --enable CONFIG_PKCS7_MESSAGE_PARSER
./scripts/config --enable CONFIG_CRYPTO_HMAC
./scripts/config --enable CONFIG_X509_CERTIFICATE_PARSER
./scripts/config --enable CONFIG_PKCS8_PRIVATE_KEY_PARSER

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

cp -v ./arch/riscv/boot/dts/thead/th1520-beaglev-ahead.dts ../BeagleBoard-DeviceTrees/src/thead/
cp -v ./.config ../patches/linux/beaglev_defconfig
cp -v ./arch/riscv/boot/Image ../deploy/
cp -v ./arch/riscv/boot/dts/thead/*.dtb ../deploy/

cd ../

git diff > log.txt ; cat log.txt ; rm log.txt

touch ./.05_generate_boot.sh
touch ./.06_generate_root.sh
#
