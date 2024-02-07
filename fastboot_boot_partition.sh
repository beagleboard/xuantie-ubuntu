#!/bin/bash

if ! id | grep -q root; then
	echo "./fastboot_boot_partition.sh must be run as root:"
	echo "sudo ./fastboot_boot_partition.sh"
	exit
fi

if [ -f ./.05_generate_boot.sh ] ; then
	echo "ERROR: run: [sudo ./05_generate_boot.sh] first"
else
	fastboot --version
	fastboot flash ram ./deploy/u-boot-with-spl.bin
	fastboot reboot
	sleep 10
	fastboot flash uboot ./deploy/u-boot-with-spl.bin
	fastboot flash boot ./deploy/boot.ext4
	fastboot reboot
fi
