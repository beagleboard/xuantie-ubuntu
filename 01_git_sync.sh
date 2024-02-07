#!/bin/bash

GIT_DEPTH="20"
GCC_VERSION="13.2.0"

#OPENSBI_BRANCH="master"
#OPENSBI_BRANCH="v1.3.1"
#OPENSBI_REPO="https://github.com/riscv-software-src/opensbi.git"

OPENSBI_BRANCH="lpi4a"
OPENSBI_REPO="https://github.com/revyos/thead-opensbi.git"

UBOOT_BRANCH="beaglev-v2020.01-1.1.2-ubuntu"
UBOOT_REPO="https://github.com/beagleboard/beaglev-ahead-u-boot.git"

DTB_BRANCH="v6.8.x"

#LINUX_BRANCH="beaglev-v5.10.113-1.1.2"
#LINUX_REPO="https://github.com/beagleboard/linux.git"

LINUX_BRANCH="master"
LINUX_REPO="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"

#LINUX_BRANCH="linux-6.8.y"
#LINUX_REPO="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"

#git pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
#git pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
#git push origin master
#git fetch https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
#git push origin master --tags
#git checkout v6.6-rc3 -b v6.6-rc3-BeagleV-Ahead
##git pull --no-edit git://git.kernel.org/pub/scm/linux/kernel/git/palmer/linux.git for-next --rebase
#git pull --no-edit https://openbeagle.org/beaglev-ahead/linux.git v6.6-rc2-BeagleV-Ahead --no-rebase
#git rebase v6.6-rc3
#git push origin v6.6-rc3-BeagleV-Ahead

LINUX_BBBIO_BRANCH="v6.8-rc3-BeagleV-Ahead"
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

echo "git clone -b ${OPENSBI_BRANCH} ${OPENSBI_REPO} ./opensbi/ --depth=${GIT_DEPTH}"
git clone -b ${OPENSBI_BRANCH} ${OPENSBI_REPO} ./opensbi/ --depth=${GIT_DEPTH}

if [ -d ./u-boot ] ; then
	rm -rf ./u-boot || true
fi

if [ -f ./.gitlab-runner ] ; then
	echo "git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-u-boot/ -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=1"
	git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-u-boot/ -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=1
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
	echo "git clone --reference-if-able /mnt/yocto-cache/git/linux-src/ -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/"
	git clone --reference-if-able /mnt/yocto-cache/git/linux-src/ -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/
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
