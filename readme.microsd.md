# Manually setup microSD

```
export DISK=/dev/sdc
```

```
sudo dd if=/dev/zero of=${DISK} bs=1M count=10
```

```
sudo sfdisk ${DISK} <<-__EOF__
1M,,L,*
__EOF__
```


```
sudo mkfs.ext4 -L rootfs ${DISK}1
```

```
sudo mount ${DISK}1 /media/rootfs/
```

```
sudo tar xfvp ./deploy/debian-sid-console-riscv64-2022-10-26/riscv64-rootfs-debian-sid.tar -C /media/rootfs/
sync
```

```
sudo sh -c "echo '/dev/mmcblk1p1  /  auto  errors=remount-ro  0  1' >> /media/rootfs/etc/fstab"
```

```
sudo tar xfv ./deploy/5.10.113+-modules.tar.gz -C /media/rootfs/usr/
```
