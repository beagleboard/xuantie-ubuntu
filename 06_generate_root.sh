#!/bin/bash

wdir=`pwd`

image="2022-10-26"

if [ ! -f ./deploy/debian-sid-console-riscv64-${image}/riscv64-rootfs-debian-sid.tar ] ; then
	wget -c --directory-prefix=./deploy https://rcn-ee.net/rootfs/debian-riscv64-minimal/${image}/debian-sid-console-riscv64-${image}.tar.xz
	cd ./deploy/
	tar xf debian-sid-console-riscv64-${image}.tar.xz
	cd ../
fi

if [ -d ./ignore/.root ] ; then
	sudo rm -rf ./ignore/.root || true
fi
sudo mkdir -p ./ignore/.root

sudo tar xfp ./deploy/debian-sid-console-riscv64-${image}/riscv64-rootfs-*.tar -C ./ignore/.root
sync

sudo mkdir -p ./ignore/.root/boot/firmware/ || true

sudo sh -c "echo '/dev/mmcblk0p2  /boot/firmware/ auto  defaults  0  2' >> ./ignore/.root/etc/fstab"
sudo sh -c "echo '/dev/mmcblk0p3  /  auto  errors=remount-ro  0  1' >> ./ignore/.root/etc/fstab"

sudo rm -rf ./ignore/.root/usr/lib/modules/5.13.6-riscv64-r17/ || true

sudo rm -rf ./ignore/.root/usr/lib/systemd/system/bb-usb-gadgets.service || true
sudo rm -rf ./ignore/.root/usr/lib/systemd/system/grow_partition.service || true

if [ -f ./deploy/.modules ] ; then
	version=$(cat ./deploy/.modules || true)
	if [ -f ./deploy/${version}.tar.gz ] ; then
		sudo tar xfv ./deploy/${version}.tar.gz -C ./ignore/.root/usr/
	fi
fi

dd if=/dev/zero of=./deploy/root.ext4 bs=1 count=0 seek=1500M
sudo mkfs.ext4 -F ./deploy/root.ext4 -d ./ignore/.root

cd ../

