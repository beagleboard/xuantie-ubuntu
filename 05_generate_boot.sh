#!/bin/bash

mkdir -p ./ignore/.boot
cp -v ./deploy/fw_dynamic.bin ./ignore/.boot
cp -v ./bins/light_aon_fpga.bin ./ignore/.boot
cp -v ./bins/light_c906_audio.bin ./ignore/.boot
cp -v ./deploy/Image ./ignore/.boot
cp -v ./deploy/light-beagle.dtb ./ignore/.boot

dd if=/dev/zero of=./deploy/boot.ext4 count=10000 bs=4096
sudo mkfs.ext4 -F ./deploy/boot.ext4 -d ./ignore/.boot
