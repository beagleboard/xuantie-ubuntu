# Build Order

```
./01_git_sync.sh
./02_build_opensbi.sh
./03_build_uboot.sh
./04_build_linux.sh
sudo ./05_generate_boot.sh
sudo ./06_generate_root.sh
```

# Flash Board over USB

```
sudo ./07_fastboot_emmc.sh
```
