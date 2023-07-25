#!/bin/bash

OPENSBI_BRANCH="v1.3.1"
UBOOT_BRANCH="beaglev-v2020.01-1.1.2"
DTB_BRANCH="v6.5.x"
#LINUX_BRANCH="beaglev-v5.10.113-1.1.2"
GIT_DEPTH="20"

if [ ! -f ./mirror/Xuantie-900-gcc-linux-5.10.4-glibc-x86_64-V2.6.1-20220906.tar.gz ] ; then
	###FIXME, move to public when released...
	echo "wget -c --directory-prefix=./mirror/ https://occ-oss-prod.oss-cn-hangzhou.aliyuncs.com/resource//1663142514282/Xuantie-900-gcc-linux-5.10.4-glibc-x86_64-V2.6.1-20220906.tar.gz"
	wget -c --directory-prefix=./mirror/ https://occ-oss-prod.oss-cn-hangzhou.aliyuncs.com/resource//1663142514282/Xuantie-900-gcc-linux-5.10.4-glibc-x86_64-V2.6.1-20220906.tar.gz
fi

if [ ! -f ./riscv-toolchain/bin/riscv64-unknown-linux-gnu-gcc-10.2.0 ] ; then
	echo "tar xf ./mirror/Xuantie-900-gcc-linux-5.10.4-glibc-x86_64-V2.6.1-20220906.tar.gz --strip-components=1 -C ./riscv-toolchain/"
	tar xf ./mirror/Xuantie-900-gcc-linux-5.10.4-glibc-x86_64-V2.6.1-20220906.tar.gz --strip-components=1 -C ./riscv-toolchain/
fi

if [ -d ./opensbi ] ; then
	rm -rf ./opensbi || true
fi

echo "git clone -b ${OPENSBI_BRANCH} https://github.com/riscv-software-src/opensbi.git ./opensbi/ --depth=${GIT_DEPTH}"
git clone -b ${OPENSBI_BRANCH} https://github.com/riscv-software-src/opensbi.git ./opensbi/ --depth=${GIT_DEPTH}

if [ -d ./u-boot ] ; then
	rm -rf ./u-boot || true
fi

if [ -f ./.gitlab-runner ] ; then
	echo "git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-u-boot/ -b ${UBOOT_BRANCH} https://github.com/beagleboard/beaglev-ahead-u-boot.git ./u-boot/ --depth=1"
	git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-u-boot/ -b ${UBOOT_BRANCH} https://github.com/beagleboard/beaglev-ahead-u-boot.git ./u-boot/ --depth=1
else
	echo "git clone -b ${UBOOT_BRANCH} https://github.com/beagleboard/beaglev-ahead-u-boot.git ./u-boot/ --depth=${GIT_DEPTH}"
	git clone -b ${UBOOT_BRANCH} https://github.com/beagleboard/beaglev-ahead-u-boot.git ./u-boot/ --depth=${GIT_DEPTH}
fi

if [ -d ./BeagleBoard-DeviceTrees ] ; then
	rm -rf ./BeagleBoard-DeviceTrees || true
fi

echo "git clone -b ${DTB_BRANCH} https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees.git"
git clone -b ${DTB_BRANCH} https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees.git

if [ -d ./linux ] ; then
	rm -rf ./linux || true
fi

if [ -f ./.gitlab-runner ] ; then
	#echo "git clone --reference-if-able /mnt/yocto-cache/git/linux-src/ -b ${LINUX_BRANCH} https://github.com/beagleboard/linux.git ./linux/ --depth=${GIT_DEPTH}"
	#git clone --reference-if-able /mnt/yocto-cache/git/linux-src/ -b ${LINUX_BRANCH} https://github.com/beagleboard/linux.git ./linux/ --depth=${GIT_DEPTH}
	echo "git clone --reference-if-able /mnt/yocto-cache/git/linux-src/  https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ./linux/ --depth=${GIT_DEPTH}"
	git clone --reference-if-able /mnt/yocto-cache/git/linux-src/  https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ./linux/ --depth=${GIT_DEPTH}
else
	#echo "git clone -b ${LINUX_BRANCH} https://github.com/beagleboard/linux.git ./linux/ --depth=${GIT_DEPTH}"
	#git clone -b ${LINUX_BRANCH} https://github.com/beagleboard/linux.git ./linux/ --depth=${GIT_DEPTH}
	echo "git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ./linux/ --depth=${GIT_DEPTH}"
	git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ./linux/ --depth=${GIT_DEPTH}
fi

cd ./linux/
git pull --no-edit https://git.beagleboard.org/beaglev-ahead/linux.git v6.5-rc3-BeagleV-Ahead-dts-mmc --no-rebase
cd ../

if [ -f ./.gitlab-runner ] ; then
	rm -f ./.gitlab-runner || true
fi

#FIXME: We need to solve the 0.7.1 vector enabled blobs, with mainline ubuntu/debian...
#if [ ! -d ./baremetal-drivers ] ; then
#	echo "Log baremetal-drivers: [git clone git@git.beagleboard.org:beaglev-ahead/baremetal-drivers.git --depth=${GIT_DEPTH}]"
#	git clone git@git.beagleboard.org:beaglev-ahead/baremetal-drivers.git --depth=${GIT_DEPTH}
#else
#	cd ./baremetal-drivers/
#	echo "Log baremetal-drivers: [git pull --rebase]"
#	git pull --rebase
#	cd -
#fi
#
#if [ ! -d ./video_memory ] ; then
#	echo "Log video_memory: [git clone git@git.beagleboard.org:beaglev-ahead/video_memory.git --depth=${GIT_DEPTH}]"
#	git clone git@git.beagleboard.org:beaglev-ahead/video_memory.git --depth=${GIT_DEPTH}
#else
#	cd ./video_memory/
#	echo "Log video_memory: [git pull --rebase]"
#	git pull --rebase
#	cd -
#fi
#
#if [ ! -d ./vi-kernel ] ; then
#	echo "Log vi-kernel: [git clone git@git.beagleboard.org:beaglev-ahead/vi-kernel.git --depth=${GIT_DEPTH}]"
#	git clone git@git.beagleboard.org:beaglev-ahead/vi-kernel.git --depth=${GIT_DEPTH}
#else
#	cd ./vi-kernel/
#	echo "Log vi-kernel: [git pull --rebase]"
#	git pull --rebase
#	cd -
#fi
#
#if [ ! -d ./gpu_bxm_4_64-kernel ] ; then
#	echo "Log gpu_bxm_4_64-kernel: [git clone git@git.beagleboard.org:beaglev-ahead/gpu_bxm_4_64-kernel.git --depth=${GIT_DEPTH}]"
#	git clone git@git.beagleboard.org:beaglev-ahead/gpu_bxm_4_64-kernel.git --depth=${GIT_DEPTH}
#else
#	cd ./gpu_bxm_4_64-kernel/
#	echo "Log gpu_bxm_4_64-kernel: [git pull --rebase]"
#	git pull --rebase
#	cd -
#fi

#if [ ! -d ./light-images-proprietary ] ; then
#	echo "Log light-images-proprietary: [git clone https://git.beagleboard.org/beaglev-ahead/light-images-proprietary.git --depth=${GIT_DEPTH}]"
#	git clone https://git.beagleboard.org/beaglev-ahead/light-images-proprietary.git --depth=${GIT_DEPTH}
#else
#	cd ./light-images-proprietary/
#	echo "Log light-images-proprietary: [git pull --rebase]"
#	git pull --rebase
#	cd -
#fi

#
