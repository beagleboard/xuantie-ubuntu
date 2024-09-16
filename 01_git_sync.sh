#!/bin/bash

GIT_DEPTH="20"
GCC_VERSION="13.3.0"

OPENSBI_BRANCH="lpi4a"
OPENSBI_REPO="https://github.com/revyos/thead-opensbi.git"
LOCAL_OPENSBI_REPO="https://github.com/revyos/thead-opensbi.git"

UBOOT_BRANCH="beaglev-v2020.01-1.1.2-ubuntu"
UBOOT_REPO="https://github.com/beagleboard/beaglev-ahead-u-boot.git"
LOCAL_UBOOT_REPO="https://git.gfnd.rcn-ee.org/BeagleBoard.org/beaglev-ahead-u-boot.git"

DTB_BRANCH="v6.9.x"

#LINUX_BRANCH="master"
#LINUX_REPO="https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git"

LINUX_BRANCH="linux-6.9.y"
LINUX_REPO="https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git"
LOCAL_LINUX_REPO="https://git.gfnd.rcn-ee.org/kernel.org/mirror-linux-stable.git"

LINUX_BBBIO_BRANCH="v6.9-rc2-BeagleV-Ahead"
LINUX_BBBIO_REPO="https://openbeagle.org/beaglev-ahead/linux.git"

if [ ! -f ./mirror/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz ] ; then
	echo "wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/${GCC_VERSION}/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz"
	wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/${GCC_VERSION}/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz
fi

if [ ! -f ./riscv-toolchain/bin/riscv64-linux-gcc-${GCC_VERSION} ] ; then
	echo "tar xf ./mirror/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/"
	tar xf ./mirror/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/
fi

if [ -d ./opensbi ] ; then
	rm -rf ./opensbi || true
fi

if [ -f ./.gitlab-runner ] ; then
	echo "git clone -b ${OPENSBI_BRANCH} ${LOCAL_OPENSBI_REPO} ./opensbi/ --depth=${GIT_DEPTH}"
	git clone -b ${OPENSBI_BRANCH} ${LOCAL_OPENSBI_REPO} ./opensbi/ --depth=${GIT_DEPTH}
else
	echo "git clone -b ${OPENSBI_BRANCH} ${OPENSBI_REPO} ./opensbi/ --depth=${GIT_DEPTH}"
	git clone -b ${OPENSBI_BRANCH} ${OPENSBI_REPO} ./opensbi/ --depth=${GIT_DEPTH}
fi

if [ -d ./u-boot ] ; then
	rm -rf ./u-boot || true
fi

if [ -f ./.gitlab-runner ] ; then
	echo "git clone -b ${UBOOT_BRANCH} ${LOCAL_UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}"
	git clone -b ${UBOOT_BRANCH} ${LOCAL_UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}
else
	echo "git clone -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}"
	git clone -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}
fi

if [ -d ./BeagleBoard-DeviceTrees ] ; then
	rm -rf ./BeagleBoard-DeviceTrees || true
fi

echo "git clone -b ${DTB_BRANCH} https://openbeagle.org/beagleboard/BeagleBoard-DeviceTrees.git"
git clone -b ${DTB_BRANCH} https://openbeagle.org/beagleboard/BeagleBoard-DeviceTrees.git

if [ -d ./linux ] ; then
	rm -rf ./linux || true
fi

if [ -f ./.gitlab-runner ] ; then
	echo "git clone --reference-if-able /opt/linux-src/ -b ${LINUX_BRANCH} ${LOCAL_LINUX_REPO} ./linux/"
	git clone --reference-if-able /opt/linux-src/ -b ${LINUX_BRANCH} ${LOCAL_LINUX_REPO} ./linux/
else
	echo "git clone --reference-if-able ~/linux-src/ -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/"
	git clone --reference-if-able ~/linux-src/ -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/
fi

if [ "${LINUX_BBBIO_BRANCH}" ] ; then
	cd ./linux/
		echo "git pull --no-edit ${LINUX_BBBIO_REPO} ${LINUX_BBBIO_BRANCH} --no-rebase"
		git pull --no-edit ${LINUX_BBBIO_REPO} ${LINUX_BBBIO_BRANCH} --no-rebase
	cd ../
fi

#
