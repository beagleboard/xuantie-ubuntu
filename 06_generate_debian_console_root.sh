#!/bin/bash

if ! id | grep -q root; then
	echo "./06_generate_debian_console_root.sh must be run as root:"
	echo "sudo ./06_generate_debian_console_root.sh"
	exit
fi

wdir=`pwd`

if [ -f /tmp/latest ] ; then
	rm -rf /tmp/latest | true
fi
wget --quiet --directory-prefix=/tmp/ https://rcn-ee.net/rootfs/debian-riscv64-sid-minimal/latest || true
if [ -f /tmp/latest ] ; then
	latest_rootfs=$(cat "/tmp/latest")
	datestamp=$(cat "/tmp/latest" | awk -F 'riscv64-' '{print $2}' | awk -F '.' '{print $1}')

	if [ ! -f ./deploy/debian-sid-console-riscv64-${datestamp}/riscv64-rootfs-debian-sid.tar ] ; then
		wget -c --directory-prefix=./deploy https://rcn-ee.net/rootfs/debian-riscv64-sid-minimal/${datestamp}/${latest_rootfs}
		cd ./deploy/
		tar xf ${latest_rootfs}
		cd ../
	fi
else
	echo "Failure: getting image"
	exit 2
fi

if [ -d ./ignore/.root ] ; then
	rm -rf ./ignore/.root || true
fi
mkdir -p ./ignore/.root

tar xfp ./deploy/debian-sid-console-riscv64-${datestamp}/riscv64-rootfs-*.tar -C ./ignore/.root
sync

mkdir -p ./ignore/.root/boot/firmware/ || true

echo '/dev/mmcblk0p2  /boot/firmware/ auto  defaults  0  2' >> ./ignore/.root/etc/fstab
echo '/dev/mmcblk0p3  /  auto  errors=remount-ro  0  1' >> ./ignore/.root/etc/fstab
echo 'debugfs  /sys/kernel/debug  debugfs  mode=755,uid=root,gid=gpio,defaults  0  0' >> ./ignore/.root/etc/fstab

rm -rf ./ignore/.root/usr/lib/systemd/system/bb-usb-gadgets.service || true
rm -rf ./ignore/.root/etc/systemd/system/getty.target.wants/serial-getty@ttyGS0.service || true
rm -rf ./ignore/.root/etc/systemd/network/usb0.network || true
rm -rf ./ignore/.root/etc/systemd/network/usb1.network || true

rm -rf ./ignore/.root/usr/lib/systemd/system/grow_partition.service || true
cd ./ignore/.root/
ln -L -f -s -v /lib/systemd/system/resize_filesystem.service --target-directory=./etc/systemd/system/multi-user.target.wants/
cd ../../

cp -v ./ignore/.root/etc/bbb.io/templates/eth0-DHCP.network ./ignore/.root/etc/systemd/network/eth0.network || true
cp -v ./bins/ap6203/* ./ignore/.root/lib/firmware/ || true

mkdir -p ./ignore/.root/usr/lib/firmware/brcm/ || true
cp -v bins/BCM43013A0_001.001.006.1073.1102.hcd ./ignore/.root/usr/lib/firmware/brcm/BCM43013A0.hcd

# setuid root ping+ping6
chmod u+s ./ignore/.root/usr/bin/ping ./ignore/.root/usr/bin/ping6

if [ -f ./deploy/.modules ] ; then
	version=$(cat ./deploy/.modules || true)
	if [ -f ./deploy/${version}-modules.tar.gz ] ; then
		tar xf ./deploy/${version}-modules.tar.gz -C ./ignore/.root/usr/
	fi
fi

#FIXME: We need to solve the 0.7.1 vector enabled blobs, with mainline ubuntu/debian...
#mkdir -p ./ignore/.root/usr/lib/modules/${version}/extra/
#cp -v ./gpu_bxm_4_64-kernel/rogue_km/binary_thead_linux_lws-generic_release/target_riscv64/kbuild/drm_nulldisp.ko ./ignore/.root/usr/lib/modules/${version}/extra/
#cp -v ./gpu_bxm_4_64-kernel/rogue_km/binary_thead_linux_lws-generic_release/target_riscv64/kbuild/pvrsrvkm.ko ./ignore/.root/usr/lib/modules/${version}/extra/
#cp -v ./vi-kernel/output/rootfs/bsp/isp/ko/*.ko ./ignore/.root/usr/lib/modules/${version}/extra/
#cp -v ./baremetal-drivers/output/rootfs/bsp/baremetal/ko/*.ko ./ignore/.root/usr/lib/modules/${version}/extra/
#cp -v ./video_memory/output/rootfs/bsp/vidmem/ko/*.ko ./ignore/.root/usr/lib/modules/${version}/extra/
#depmod -a -b ./ignore/.root/usr ${version}

#cp -v ./vi-kernel/output/rootfs/bsp/isp/ko/*.sh ./ignore/.root/home/beagle/

#mkdir -p ./ignore/.root/usr/share/vidmem/test/bin/
#cp -v video_memory/output/rootfs/bsp/vidmem/test/vidmem_test ./ignore/.root/usr/share/vidmem/test/bin/
#cp -v video_memory/output/rootfs/bsp/vidmem/lib/libvmem.so ./ignore/.root/usr/lib/

echo '---------------------'
echo 'File Size'
du -sh ignore/.root/ || true
echo '---------------------'

dd if=/dev/zero of=./deploy/root.ext4 bs=1 count=0 seek=4000M
mkfs.ext4 -F ./deploy/root.ext4 -d ./ignore/.root

if [ -f ./.06_generate_root.sh ] ; then
	rm -f ./.06_generate_root.sh || true
fi
