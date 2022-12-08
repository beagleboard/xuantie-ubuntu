#!/bin/bash

if [ -d ./beaglev-ahead-linux ] ; then
	cd ./beaglev-ahead-linux/
	git reset HEAD --hard
	cd ../
fi

git submodule init && git submodule sync && git submodule update --remote

if [ -d ./riscv-toolchain ] ; then
	rm -rf ./riscv-toolchain || true
fi

git clone git@git.beagleboard.org:beaglev-ahead/riscv-toolchain.git --depth=1

if [ -d ./opensbi ] ; then
	rm -rf ./opensbi || true
fi

git clone git@git.beagleboard.org:beaglev-ahead/opensbi.git --depth=1

if [ -d ./beaglev-ahead-u-boot ] ; then
	rm -rf ./beaglev-ahead-u-boot || true
fi

git clone -b beaglev-ahead-v2020.01-0.9.5 git@git.beagleboard.org:beaglev-ahead/beaglev-ahead-u-boot.git --depth=10

#
