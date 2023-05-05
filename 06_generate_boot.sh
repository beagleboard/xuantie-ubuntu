#!/bin/bash

if ! id | grep -q root; then
	echo "./06_generate_boot.sh must be run as root:"
	echo "sudo ./06_generate_boot.sh"
	exit
fi

mkdir -p ./ignore/.boot || true
cp -v ./deploy/fw_dynamic.bin ./ignore/.boot
cp -v ./bins/light_aon_fpga.bin ./ignore/.boot
cp -v ./bins/light_c906_audio.bin ./ignore/.boot
if [ ! -f ./deploy/Image ] ; then
	echo "Missing Kernel Image"
	exit 2
fi
cp -v ./deploy/Image ./ignore/.boot
cp -v ./deploy/light-beagle.dtb ./ignore/.boot

mkdir -p ./ignore/.boot/overlays/ || true
cp -v ./BeagleBoard-DeviceTrees/src/riscv/overlays/*.dtbo ./ignore/.boot/overlays/

mkdir -p ./ignore/.boot/extlinux/ || true
echo "label Linux eMMC" > ./ignore/.boot/extlinux/extlinux.conf
echo "    kernel /Image" >> ./ignore/.boot/extlinux/extlinux.conf
echo "    append root=/dev/mmcblk0p3 ro rootfstype=ext4 rootwait console=ttyS0,115200 earlycon clk_ignore_unused net.ifnames=0" >> ./ignore/.boot/extlinux/extlinux.conf
echo "    fdtdir /" >> ./ignore/.boot/extlinux/extlinux.conf
echo "    #fdtoverlays /overlays/<file>.dtbo" >> ./ignore/.boot/extlinux/extlinux.conf

dd if=/dev/zero of=./deploy/boot.ext4 bs=1 count=0 seek=190M
mkfs.ext4 -F ./deploy/boot.ext4 -d ./ignore/.boot

if [ -f ./.06_generate_boot.sh ] ; then
	rm -f ./.06_generate_boot.sh || true
fi