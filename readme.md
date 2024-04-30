# Mainline Status

# OpenSBI - [v1.3.1]
- Mainline: https://github.com/riscv-software-src/opensbi

# U-Boot - [v2020.01]
- Vendor Fork: https://github.com/beagleboard/beaglev-ahead-u-boot/tree/beaglev-v2020.01-1.1.2

# Linux - [v6.5-rc]
- Mainline: Basic Boot, gpio, serial, memory [submitted for v6.6-rc] - https://lore.kernel.org/linux-riscv/20230722-upstream-beaglev-ahead-dts-v1-0-ccda511357f4@baylibre.com/T/#t
- eMMC - [RFC, testing] - https://lore.kernel.org/linux-riscv/20230724-th1520-emmc-v1-0-cca1b2533da2@baylibre.com/T/#t

# Debian/Ubuntu RootFS generator:
- Ubuntu 24.04 Console: https://openbeagle.org/beagleboard/image-builder/-/blob/master/configs/bb.org-ubuntu-2404-console-riscv64.conf
- Ubuntu 23.04 Xfce: https://openbeagle.org/beagleboard/image-builder/-/blob/master/configs/bb.org-ubuntu-2304-xfce-riscv64.conf
- Debian (sid/ports) Console: https://openbeagle.org/beagleboard/image-builder/-/blob/master/configs/bb.org-debian-sid-console-riscv64.conf

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

# User Creditionals

```
cp sysconf.txt.example sysconf.txt
```

Then edit sysconf.txt and save before running `sudo ./05_generate_boot.sh` (which will copy it to the boot partition)

#

# Known issues (reboot)

Just hit the reset button for now..

```
[   30.187239] systemd-shutdown[1]: Rebooting.
[   30.196903] reboot: Restarting system
sbi_trap_error: hart0: trap handler failed (error -2)
sbi_trap_error: hart0: mcause=0x0000000000000003 mtval=0x0000000000000000
sbi_trap_error: hart0: mepc=0x000000000000a3a4 mstatus=0x0000000a00001822
sbi_trap_error: hart0: ra=0x000000000000186c sp=0x0000000000028d78
sbi_trap_error: hart0: gp=0xffffffff81505be8 tp=0xffffffd8004f8000
sbi_trap_error: hart0: s0=0x0000000000028d88 s1=0x0000000000000040
sbi_trap_error: hart0: a0=0x0000000000000001 a1=0x0000000000000000
sbi_trap_error: hart0: a2=0x0000000000000003 a3=0x0000000000000000
sbi_trap_error: hart0: a4=0x0000000000000000 a5=0x000000000000a39e
sbi_trap_error: hart0: a6=0x0000000000000000 a7=0x0000000053525354
sbi_trap_error: hart0: s2=0x0000000000000000 s3=0x000000000001a2f0
sbi_trap_error: hart0: s4=0x0000000000028d90 s5=0x0000000000000001
sbi_trap_error: hart0: s6=0x0000000000000000 s7=0x0000000000000001
sbi_trap_error: hart0: s8=0x0000000000000000 s9=0x0000000000029000
sbi_trap_error: hart0: s10=0x0000000000000000 s11=0x0000003fc431e8e0
sbi_trap_error: hart0: t0=0x0000000a00000822 t1=0x0000000000000001
sbi_trap_error: hart0: t2=0x52203a746f6f6265 t3=0xffffffff815198d7
sbi_trap_error: hart0: t4=0xffffffff815198d7 t5=0xffffffff815198d8
sbi_trap_error: hart0: t6=0xffffffc800023b68
```

