#!/bin/bash

#https://forum.beagleboard.org/t/flashing-beaglev-from-osx-m2-mac/35405
#brew install --cask android-platform-tools

if [ -f boot.ext4.xz ] ; then
	unxz -v boot.ext4.xz
fi

if [ -f root.ext4.xz ] ; then
	unxz -v root.ext4.xz
fi

fastboot --version
fastboot flash ram ./u-boot-with-spl.bin
fastboot reboot
sleep 10
fastboot oem format
fastboot flash uboot ./u-boot-with-spl.bin
fastboot flash boot ./boot.ext4
fastboot flash root ./root.ext4
fastboot reboot
