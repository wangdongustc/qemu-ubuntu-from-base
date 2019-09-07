# Run Ubuntu in Qemu, Starting from Ubuntu-Base!

## Steps

### Prepare

- Install `qemu` (via `apt` or `pacman`, etc).

- Download `ubuntu-base` .iso, e.g. `amd64` version of [Ubuntu Base 18.04.3 LTS (Bionic Beaver)](http://cdimage.ubuntu.com/ubuntu-base/releases/18.04.3/release/).

- Download the latest kernel from [kernel.org](https://www.kernel.org/).

### Build the kernel

Build the kernel image with:
``` bash
# export OUTPUT_PATH=path/to/kernel/build/output
make O=$OUTPUT_PATH defconfig
make O=$OUTPUT_PATH -j6 bzImage
``` 

The built kernel can be found at: `$OUTPUT_PATH/arch/x86_64/boot/bzImage` .

### Make Rootfs

- Create (~8GB) raw image `rootfs.img`:
``` bash
dd if=/dev/zero of=rootfs.img bs=8192 count=1024000 status=progress
```

- Partition the disk:
``` bash
# use fdisk to handle the img file
fdisk rootfs.img
# create DOS partition table with "o"
# add a new partition with "n" 
# write to the disk with "w"
```
- Mount the disk via loop device:
``` bash
# create a mounting point folder
sudo mkdir /mnt/tmp
# rootfs -> /dev/loopX
sudo losetup -fP rootfs.img
# list all used loop devices
sudo losetup -a
# assuming rootfs.img was setup on /dev/loop0
# then the partition will be setup on /dev/loop0p1

# make ext4 format on /dev/loop0p1
sudo mkfs.ext4 /dev/loop0p1
#mount the filesystem on the mounting point
sudo mount /dev/loop0p1 /mnt/tmp
```

- Extract `ubuntu-base-*.tar.gz` files into `rootfs`:
``` bash
cd /mnt/tmp
sudo tar -xvf path/to/ubuntu-base-*.tar.gz
```

- Configure the `rootfs` via `chroot`:
``` bash
# resolv.conf shell be replaced in order to use network
sudo cp /etc/resolv.conf /mnt/tmp/etc/resolv.conf
# files under /dev, /sys and /proc shell be mounted on the rootfs, and this can be done via chroot.sh
sudo ./chroot.sh /mnt/tmp
```

- Install anything via `apt` under chroot:
``` bash
# should do this because the default $PATH is not correct
export PATH=$PATH:/usr/sbin:/sbin
export LC_ALL="C"
apt update
apt upgrade
apt install init
```

- Unmount `rootfs` after quit chroot:
``` bash
sudo umount -R /mnt/tmp
sudo losetup -d /dev/loop0
```

### Run with Qemu!

Run Qemu with terms in qemu_term.sh. Note that `$KERNEL`, `$DISK`, `$RAM` shell be modified accordingly.

``` bash
./qemu_term.sh
```
