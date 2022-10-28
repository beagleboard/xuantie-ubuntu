#!/bin/bash

if ! id | grep -q root; then
	echo "./fastboot_emmc.sh must be run as root:"
	echo "sudo ./fastboot_emmc.sh"
	exit
fi

fastboot flash ram ./u-boot-with-spl.bin
fastboot reboot
sleep 10
fastboot flash uboot ./u-boot-with-spl.bin
fastboot flash boot ./boot.ext4
fastboot flash root ./root.ext4
fastboot reboot
