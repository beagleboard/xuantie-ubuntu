# Mainline Status

# OpenSBI - [v1.3.1]
- Mainline: https://github.com/riscv-software-src/opensbi

# U-Boot - [v2020.01]
- Vendor Fork: https://github.com/beagleboard/beaglev-ahead-u-boot/tree/beaglev-v2020.01-1.1.2

# Linux - [v6.5-rc]
- Mainline: Basic Boot, gpio, serial, memory [submitted for v6.6-rc] - https://lore.kernel.org/linux-riscv/20230722-upstream-beaglev-ahead-dts-v1-0-ccda511357f4@baylibre.com/T/#t
- eMMC - [RFC, testing] - https://lore.kernel.org/linux-riscv/20230724-th1520-emmc-v1-0-cca1b2533da2@baylibre.com/T/#t

# Debian/Ubuntu RootFS generator:
- Ubuntu 23.04 Console: https://git.beagleboard.org/beagleboard/image-builder/-/blob/master/configs/bb.org-ubuntu-2304-console-riscv64.conf 
- Ubuntu 23.04 Xfce: https://git.beagleboard.org/beagleboard/image-builder/-/blob/master/configs/bb.org-ubuntu-2304-xfce-riscv64.conf
- Debian (sid/ports) Console: https://git.beagleboard.org/beagleboard/image-builder/-/blob/master/configs/bb.org-debian-sid-console-riscv64.conf

These are daily built and uploaded to: https://rcn-ee.net/rootfs/

# Clone repo:

```
git clone https://github.com/beagleboard/xuantie-ubuntu.git
cd ./xuantie-ubuntu/
```

# Merge Requests:

https://git.beagleboard.org/beaglev-ahead/xuantie-ubuntu

# CI builds:

https://git.beagleboard.org/beaglev-ahead/xuantie-ubuntu/-/pipelines

# Install Android Fastboot

```
sudo apt install fastboot
```

# Build Order

```
./01_git_sync.sh
./02_build_opensbi.sh
./03_build_uboot.sh
./04_build_linux.sh
sudo ./05_generate_boot.sh
sudo ./06_generate_ubuntu_console_root.sh
```

# Flash Board over USB

1. Connect board to PC with your USB3 cable.
2. Press the `USB` button near SD card holder and toggle the `RESET` button near the Ethernet Jack.
3. Now, Execute the command below and you should see the board flashing.


```
sudo ./07_fastboot_emmc.sh
```

# Default User and password:

Ubuntu:
- user: beagle
- pass: temppwd

Debian:
- user: debian
- pass: temppwd
