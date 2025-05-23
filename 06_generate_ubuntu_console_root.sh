#!/bin/bash

if ! id | grep -q root; then
	echo "./06_generate_ubuntu_console_root.sh must be run as root:"
	echo "sudo ./06_generate_ubuntu_console_root.sh"
	exit
fi

wdir=`pwd`
distro="ubuntu"
version="24.04"
codename="noble"

if [ -f /tmp/latest ] ; then
	rm -rf /tmp/latest | true
fi
wget --quiet --directory-prefix=/tmp/ https://rcn-ee.net/rootfs/${distro}-riscv64-${version}-minimal/latest || true
if [ -f /tmp/latest ] ; then
	latest_rootfs=$(cat "/tmp/latest")
	datestamp=$(cat "/tmp/latest" | awk -F 'riscv64-' '{print $2}' | awk -F '.' '{print $1}')
	echo "${datestamp}"

	if [ ! -f ./deploy/${distro}-${version}-console-riscv64-${datestamp}/riscv64-rootfs-${distro}-${codename}.tar ] ; then
		echo "wget [${datestamp}/${latest_rootfs}]"
		if [ -f ./.gitlab-runner ] ; then
			wget -c --quiet --directory-prefix=./deploy http://192.168.1.98/mirror/rcn-ee.us/rootfs/${distro}-riscv64-${version}-minimal/${datestamp}/${latest_rootfs}
		else
			wget -c --directory-prefix=./deploy https://rcn-ee.net/rootfs/${distro}-riscv64-${version}-minimal/${datestamp}/${latest_rootfs}
		fi
		cd ./deploy/
		tar xf ${latest_rootfs}
		cd ../
		if [ ! -f ./deploy/${distro}-${version}-console-riscv64-${datestamp}/riscv64-rootfs-${distro}-${codename}.tar ] ; then
			echo "Corrupted file?"
			exit 2
		fi
	fi
else
	echo "Failure: getting image"
	exit 2
fi

if [ -d ./ignore/.root ] ; then
	rm -rf ./ignore/.root || true
fi
mkdir -p ./ignore/.root

echo "Extracting: ${distro}-${version}-console-riscv64-${datestamp}/riscv64-rootfs-${distro}-${codename}.tar"
tar xfp ./deploy/${distro}-${version}-console-riscv64-${datestamp}/riscv64-rootfs-${distro}-${codename}.tar -C ./ignore/.root
sync

mkdir -p ./ignore/.root/boot/firmware/ || true

echo '/dev/mmcblk0p2  /boot/firmware/  auto  defaults  0  2' >> ./ignore/.root/etc/fstab
echo '/dev/mmcblk0p3  /  auto  errors=remount-ro  0  1' >> ./ignore/.root/etc/fstab
echo 'debugfs  /sys/kernel/debug  debugfs  mode=755,uid=root,gid=gpio,defaults  0  0' >> ./ignore/.root/etc/fstab

rm -rf ./ignore/.root/usr/lib/systemd/system/snapd.service || true

#No USB support yet...
rm -rf ./ignore/.root/usr/lib/systemd/system/bb-usb-gadgets.service || true
rm -rf ./ignore/.root/etc/systemd/system/getty.target.wants/serial-getty@ttyGS0.service || true
rm -rf ./ignore/.root/etc/systemd/network/usb0.network || true
rm -rf ./ignore/.root/etc/systemd/network/usb1.network || true

cp -v ./ignore/.root/etc/bbb.io/templates/eth0-DHCP.network ./ignore/.root/etc/systemd/network/eth0.network || true

rm -rf ./ignore/.root/usr/lib/systemd/system/grow_partition.service || true
cd ./ignore/.root/
ln -L -f -s -v /lib/systemd/system/resize_filesystem.service --target-directory=./etc/systemd/system/multi-user.target.wants/
cd ../../

du -sh ./ignore/.root/usr/lib/firmware/
#Cleanup large firmware's..
rm -rf ./ignore/.root/usr/lib/firmware/amdgpu/ || true
rm -rf ./ignore/.root/usr/lib/firmware/dpaa2/ || true
rm -rf ./ignore/.root/usr/lib/firmware/i915/ || true
rm -rf ./ignore/.root/usr/lib/firmware/intel/ || true
rm -rf ./ignore/.root/usr/lib/firmware/liquidio/ || true
rm -rf ./ignore/.root/usr/lib/firmware/mediatek/ || true
rm -rf ./ignore/.root/usr/lib/firmware/mellanox/ || true
rm -rf ./ignore/.root/usr/lib/firmware/mrvl/ || true
rm -rf ./ignore/.root/usr/lib/firmware/netronome/ || true
rm -rf ./ignore/.root/usr/lib/firmware/nvidia/ || true
rm -rf ./ignore/.root/usr/lib/firmware/qcom/ || true
rm -rf ./ignore/.root/usr/lib/firmware/qed/ || true
rm -rf ./ignore/.root/usr/lib/firmware/radeon/ || true
rm -rf ./ignore/.root/usr/lib/firmware/ueagle-atm/ || true
rm -rf ./ignore/.root/usr/lib/firmware/vsc/ || true

rm -rf ./ignore/.root/usr/lib/firmware/iwlwifi-* || true
rm -rf ./ignore/.root/usr/lib/firmware/ipw* || true

cp -v ./bins/ap6203/* ./ignore/.root/usr/lib/firmware/ || true

mkdir -p ./ignore/.root/usr/lib/firmware/brcm/ || true
cp -v bins/BCM43013A0_001.001.006.1073.1102.hcd ./ignore/.root/usr/lib/firmware/brcm/BCM43013A0.hcd

du -sh ./ignore/.root/usr/lib/firmware/

# setuid root ping+ping6
chmod u+s ./ignore/.root/usr/bin/ping ./ignore/.root/usr/bin/ping6

#Default nginx export
rm -f ./ignore/.root/etc/nginx/sites-enabled/default || true
cp -v ./ignore/.root/etc/bbb.io/templates/nginx/nginx-autoindex ./ignore/.root/etc/nginx/sites-enabled/default
cp -v ./ignore/.root/etc/bbb.io/templates/nginx/*.html ./ignore/.root/var/www/html/
rm -f ./ignore/.root/var/www/html/index.nginx-debian.html || true

if [ -f ./deploy/.modules ] ; then
	version=$(cat ./deploy/.modules || true)
	if [ -f ./deploy/${version}-modules.tar.gz ] ; then
		tar xf ./deploy/${version}-modules.tar.gz -C ./ignore/.root/usr/
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
#
