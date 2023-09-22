#!/bin/bash

if ! id | grep -q root; then
	echo "./06_generate_ubuntu_xfce_root.sh must be run as root:"
	echo "sudo ./06_generate_ubuntu_xfce_root.sh"
	exit
fi

wdir=`pwd`

if [ -f /tmp/latest ] ; then
	rm -rf /tmp/latest | true
fi
wget --quiet --directory-prefix=/tmp/ https://rcn-ee.net/rootfs/ubuntu-riscv64-23.04-xfce/latest || true
if [ -f /tmp/latest ] ; then
	latest_rootfs=$(cat "/tmp/latest")
	datestamp=$(cat "/tmp/latest" | awk -F 'riscv64-' '{print $2}' | awk -F '.' '{print $1}')

	if [ ! -f ./deploy/ubuntu-23.04-xfce-riscv64-${datestamp}/riscv64-rootfs-ubuntu-lunar.tar ] ; then
		if [ -f ./.gitlab-runner ] ; then
			wget -c --directory-prefix=./deploy http://192.168.1.98/rcn-ee.us/rootfs/ubuntu-riscv64-23.04-xfce/${datestamp}/${latest_rootfs}
		else
			wget -c --directory-prefix=./deploy https://rcn-ee.net/rootfs/ubuntu-riscv64-23.04-xfce/${datestamp}/${latest_rootfs}
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

echo "Extracting: ubuntu-23.04-xfce-riscv64-${datestamp}/riscv64-rootfs-ubuntu-lunar.tar"
tar xfp ./deploy/ubuntu-23.04-xfce-riscv64-${datestamp}/riscv64-rootfs-ubuntu-lunar.tar -C ./ignore/.root
sync

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

cp -v ./bins/ap6203/* ./ignore/.root/lib/firmware/ || true

mkdir -p ./ignore/.root/usr/lib/firmware/brcm/ || true
cp -v bins/BCM43013A0_001.001.006.1073.1102.hcd ./ignore/.root/usr/lib/firmware/brcm/BCM43013A0.hcd

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

dd if=/dev/zero of=./deploy/root.ext4 bs=1 count=0 seek=4500M
mkfs.ext4 -F ./deploy/root.ext4 -d ./ignore/.root

if [ -f ./.06_generate_root.sh ] ; then
	rm -f ./.06_generate_root.sh || true
fi
