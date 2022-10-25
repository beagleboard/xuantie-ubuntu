#!/bin/bash

sudo fastboot flash ram ./deploy/u-boot-with-spl.bin
sudo fastboot reboot
sleep 10
sudo fastboot flash uboot ./deploy/u-boot-with-spl.bin
sudo fastboot flash boot ./deploy/boot.ext4
sudo fastboot flash root ./deploy/root.ext4
sudo fastboot reboot
