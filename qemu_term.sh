#!/bin/bash

KERNEL="/home/wangdong/Projects/kernel/linux-5.2.13.build/arch/x86_64/boot/bzImage"
RAM=2G
DISK="/home/wangdong/Projects/qemu-ubuntu-from-base/rootfs.img"

qemu-system-x86_64 \
        -enable-kvm \
        -drive file=$DISK,format=raw\
        -m $RAM \
        -device e1000,netdev=net0 \
        -netdev user,id=net0,hostfwd=tcp::5555-:22 \
        -serial stdio \
        -kernel $KERNEL \
        -append "root=/dev/sda1 console=tty0 rw"  \
