#!/bin/bash

if ! id | grep -q root; then
	echo "./07_fastboot_emmc.sh must be run as root:"
	echo "sudo ./07_fastboot_emmc.sh"
	exit
fi

fastboot flash ram ./deploy/u-boot-with-spl.bin
fastboot reboot
sleep 10
fastboot flash uboot ./deploy/u-boot-with-spl.bin
fastboot flash boot ./deploy/boot.ext4
fastboot reboot
