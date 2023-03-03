#!/bin/bash

if ! id | grep -q root; then
	echo "./06_generate_root.sh must be run as root:"
	echo "sudo ./06_generate_root.sh"
	exit
fi

wdir=`pwd`

image="2023-03-03"

if [ ! -f ./deploy/debian-sid-console-riscv64-${image}/riscv64-rootfs-debian-sid.tar ] ; then
	wget -c --directory-prefix=./deploy https://rcn-ee.net/rootfs/debian-riscv64-minimal/${image}/debian-sid-console-riscv64-${image}.tar.xz
	cd ./deploy/
	tar xf debian-sid-console-riscv64-${image}.tar.xz
	cd ../
fi

if [ -d ./ignore/.root ] ; then
	rm -rf ./ignore/.root || true
fi
mkdir -p ./ignore/.root

tar xfp ./deploy/debian-sid-console-riscv64-${image}/riscv64-rootfs-*.tar -C ./ignore/.root
sync

mkdir -p ./ignore/.root/boot/firmware/ || true

echo '/dev/mmcblk0p2  /boot/firmware/ auto  defaults  0  2' >> ./ignore/.root/etc/fstab
echo '/dev/mmcblk0p3  /  auto  errors=remount-ro  0  1' >> ./ignore/.root/etc/fstab
echo 'debugfs  /sys/kernel/debug  debugfs  mode=755,uid=root,gid=gpio,defaults  0  0' >> ./ignore/.root/etc/fstab

rm -rf ./ignore/.root/usr/lib/systemd/system/grow_partition.service || true

cp -v ./ignore/.root/etc/bbb.io/templates/eth0-DHCP.network ./ignore/.root/etc/systemd/network/eth0.network || true
cp -v ./bins/ap6203/* ./ignore/.root/usr/lib/firmware/ || true

mkdir -p ./ignore/.root/usr/lib/firmware/brcm/ || true
cp -v bins/BCM43013A0_001.001.006.1073.1102.hcd ./ignore/.root/usr/lib/firmware/brcm/BCM43013A0.hcd

# setuid root ping+ping6
chmod u+s ./ignore/.root/usr/bin/ping ./ignore/.root/usr/bin/ping6

if [ -f ./deploy/.modules ] ; then
	version=$(cat ./deploy/.modules || true)
	if [ -f ./deploy/${version}.tar.gz ] ; then
		tar xfv ./deploy/${version}.tar.gz -C ./ignore/.root/usr/
	fi
fi

echo '---------------------'
echo 'File Size'
du -sh ignore/.root/ || true
echo '---------------------'

dd if=/dev/zero of=./deploy/root.ext4 bs=1 count=0 seek=4000M
mkfs.ext4 -F ./deploy/root.ext4 -d ./ignore/.root

if [ -f ./.06_generate_root.sh ] ; then
	rm -f ./.06_generate_root.sh || true
fi
