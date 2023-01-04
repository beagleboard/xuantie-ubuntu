#!/bin/bash

UBOOT_BRANCH="beaglev-v2020.01-1.0.3"

if [ -d ./riscv-toolchain ] ; then
	rm -rf ./riscv-toolchain || true
fi
if [ -f ./.gitlab-runner ] ; then
	git clone --reference-if-able /mnt/yocto-cache/git/riscv-toolchain/ git@git.beagleboard.org:beaglev-ahead/riscv-toolchain.git --depth=1
else
	git clone git@git.beagleboard.org:beaglev-ahead/riscv-toolchain.git --depth=1
fi

if [ -d ./opensbi ] ; then
	rm -rf ./opensbi || true
fi

if [ -f ./.gitlab-runner ] ; then
	git clone --reference-if-able /mnt/yocto-cache/git/opensbi/ git@git.beagleboard.org:beaglev-ahead/opensbi.git --depth=1
else
	git clone git@git.beagleboard.org:beaglev-ahead/opensbi.git --depth=10
fi

if [ -d ./beaglev-ahead-u-boot ] ; then
	rm -rf ./beaglev-ahead-u-boot || true
fi

if [ -d ./u-boot ] ; then
	rm -rf ./u-boot || true
fi

if [ -f ./.gitlab-runner ] ; then
	git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-u-boot/ -b ${UBOOT_BRANCH} git@git.beagleboard.org:beaglev-ahead/beaglev-ahead-u-boot.git ./u-boot/ --depth=1
else
	git clone -b ${UBOOT_BRANCH} git@git.beagleboard.org:beaglev-ahead/beaglev-ahead-u-boot.git ./u-boot/ --depth=10
fi

if [ -d ./beaglev-ahead-linux ] ; then
	rm -rf ./beaglev-ahead-linux || true
fi

if [ -f ./.gitlab-runner ] ; then
	git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-linux/ -b beaglev-ahead-v5.10.113-0.9.5 git@git.beagleboard.org:beaglev-ahead/beaglev-ahead-linux.git --depth=1
else
	git clone -b beaglev-ahead-v5.10.113-0.9.5 git@git.beagleboard.org:beaglev-ahead/beaglev-ahead-linux.git --depth=10
fi

if [ -f ./.gitlab-runner ] ; then
	rm -f ./.gitlab-runner || true
fi
#
