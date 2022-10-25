#!/bin/bash

wdir=`pwd`

image="2022-10-24"

if [ ! -f ./deploy/debian-sid-console-riscv64-${image}/riscv64-rootfs-debian-sid.tar ] ; then
	wget -c --directory-prefix=./deploy https://rcn-ee.net/rootfs/debian-riscv64-minimal/${image}/debian-sid-console-riscv64-${image}.tar.xz
	cd ./deploy/
	tar xf debian-sid-console-riscv64-${image}.tar.xz
	cd ../
fi

mkdir -p ./ignore/.root

sudo tar xfp ./deploy/debian-sid-console-riscv64-${image}/riscv64-rootfs-*.tar -C ./ignore/.root
sync

#if [ -f ./deploy/.modules ] ; then
#	version=$(cat ./deploy/.modules || true)
#	if [ -f ./deploy/${version}.tar.gz ] ; then
#		sudo tar xfv ./deploy/${version}.tar.gz -C ./ignore/.root
#	fi
#fi

dd if=/dev/zero of=./deploy/root.ext4 bs=1 count=0 seek=2000M
sudo mkfs.ext4 -F ./deploy/root.ext4 -d ./ignore/.root

cd ../

