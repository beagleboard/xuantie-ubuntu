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
sudo ./06_generate_ubuntu_root.sh
```

# Flash Board over USB

1. Press the `USB` button near SD card holder and then connect the board to PC with your USB3 cable.
2. Now, Execute the command below and you should see the board flashing.

```
sudo ./07_fastboot_emmc.sh
```
