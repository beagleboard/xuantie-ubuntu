#!/bin/bash

image_dir="ubuntu-riscv64-23.04-xfce"
image_pre="ubuntu-23.04"
image_post="ubuntu-lunar"
image_type="xfce"

if ! id | grep -q root; then
	echo "./06_generate_ubuntu_xfce_root.sh must be run as root:"
	echo "sudo ./06_generate_ubuntu_xfce_root.sh"
	exit
fi

wdir=`pwd`

if [ -f /tmp/latest ] ; then
	rm -rf /tmp/latest | true
fi
wget --quiet --directory-prefix=/tmp/ https://rcn-ee.net/rootfs/${image_dir}/latest || true
if [ -f /tmp/latest ] ; then
	latest_rootfs=$(cat "/tmp/latest")
	datestamp=$(cat "/tmp/latest" | awk -F 'riscv64-' '{print $2}' | awk -F '.' '{print $1}')

	if [ ! -f ./deploy/${image_pre}-${image_type}-riscv64-${datestamp}/riscv64-rootfs-${image_post}.tar ] ; then
		if [ -f ./.gitlab-runner ] ; then
			wget -c --directory-prefix=./deploy http://192.168.1.98/mirror/rcn-ee.us/rootfs/${image_dir}/${datestamp}/${latest_rootfs}
		else
			wget -c --directory-prefix=./deploy https://rcn-ee.net/rootfs/${image_dir}/${datestamp}/${latest_rootfs}
		fi
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

echo "Extracting: ${image_pre}-${image_type}-riscv64-${datestamp}/riscv64-rootfs-${image_post}.tar"
tar xfp ./deploy/${image_pre}-${image_type}-riscv64-${datestamp}/riscv64-rootfs-${image_post}.tar -C ./ignore/.root
sync

if [ ! -f ./ignore/.root/etc/fstab ] ; then
	echo "RootFS Error"
	exit 2
fi

mkdir -p ./ignore/.root/boot/firmware/ || true

echo '/dev/mmcblk0p2  /boot/firmware/ auto  defaults  0  2' >> ./ignore/.root/etc/fstab
echo '/dev/mmcblk0p3  /  auto  errors=remount-ro  0  1' >> ./ignore/.root/etc/fstab
echo 'debugfs  /sys/kernel/debug  debugfs  mode=755,uid=root,gid=gpio,defaults  0  0' >> ./ignore/.root/etc/fstab

rm -rf ./ignore/.root/usr/lib/systemd/system/snapd.service || true

#No USB support yet...
rm -rf ./ignore/.root/usr/lib/systemd/system/bb-usb-gadgets.service || true
rm -rf ./ignore/.root/etc/systemd/system/getty.target.wants/serial-getty@ttyGS0.service || true
rm -rf ./ignore/.root/etc/systemd/network/usb0.network || true
rm -rf ./ignore/.root/etc/systemd/network/usb1.network || true

rm -rf ./ignore/.root/usr/lib/systemd/system/grow_partition.service || true
cd ./ignore/.root/
ln -L -f -s -v /lib/systemd/system/resize_filesystem.service --target-directory=./etc/systemd/system/multi-user.target.wants/
cd ../../

du -sh ./ignore/.root/lib/firmware/
#Cleanup large firmware's..
rm -rf ./ignore/.root/lib/firmware/amdgpu/ || true
rm -rf ./ignore/.root/lib/firmware/dpaa2/ || true
rm -rf ./ignore/.root/lib/firmware/i915/ || true
rm -rf ./ignore/.root/lib/firmware/intel/ || true
rm -rf ./ignore/.root/lib/firmware/liquidio/ || true
rm -rf ./ignore/.root/lib/firmware/mediatek/ || true
rm -rf ./ignore/.root/lib/firmware/mellanox/ || true
rm -rf ./ignore/.root/lib/firmware/mrvl/ || true
rm -rf ./ignore/.root/lib/firmware/netronome/ || true
rm -rf ./ignore/.root/lib/firmware/nvidia/ || true
rm -rf ./ignore/.root/lib/firmware/qcom/ || true
rm -rf ./ignore/.root/lib/firmware/qed/ || true
rm -rf ./ignore/.root/lib/firmware/radeon/ || true
rm -rf ./ignore/.root/lib/firmware/ueagle-atm/ || true
rm -rf ./ignore/.root/lib/firmware/vsc/ || true

rm -rf ./ignore/.root/lib/firmware/iwlwifi-* || true
rm -rf ./ignore/.root/lib/firmware/ipw* || true

cp -v ./bins/ap6203/* ./ignore/.root/lib/firmware/ || true

mkdir -p ./ignore/.root/usr/lib/firmware/brcm/ || true
cp -v bins/BCM43013A0_001.001.006.1073.1102.hcd ./ignore/.root/lib/firmware/brcm/BCM43013A0.hcd

du -sh ./ignore/.root/lib/firmware/

mkdir -p ./ignore/.root/usr/share/backgrounds/bbb.io/ || true
cp -v ./bins/xfce/beagleboard-logo.svg ./ignore/.root/usr/share/backgrounds/bbb.io/

mkdir -p ./ignore/.root/home/beagle/.config/xfce4/xfconf/xfce-perchannel-xml/ || true
cp -v ./bins/xfce/xfce4-desktop.xml ./ignore/.root/home/beagle/.config/xfce4/xfconf/xfce-perchannel-xml/
chown -R 1000:1000 ./ignore/.root/home/beagle/.config/

#Disable dpms mode and screen blanking
#Better fix for missing cursor
wfile="./ignore/.root/home/beagle/.xsessionrc"
echo "#!/bin/sh" > ${wfile}
echo "" >> ${wfile}
echo "xset -dpms" >> ${wfile}
echo "xset s off" >> ${wfile}
echo "xsetroot -cursor_name left_ptr" >> ${wfile}
chown -R 1000:1000 ${wfile}

# setuid root ping+ping6
chmod u+s ./ignore/.root/usr/bin/ping ./ignore/.root/usr/bin/ping6

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

dd if=/dev/zero of=./deploy/root.ext4 bs=1 count=0 seek=4500M
mkfs.ext4 -F ./deploy/root.ext4 -d ./ignore/.root

if [ -f ./.06_generate_root.sh ] ; then
	rm -f ./.06_generate_root.sh || true
fi
