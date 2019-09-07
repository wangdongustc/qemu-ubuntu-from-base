#!/bin/bash

# the first arguement should be the rootfs path
if [[ -z "$1" ]]; then
    echo "Usage: sudo ./chroot.sh path/to/rootfs"
    exit 1
fi

# check if current user is root
# https://askubuntu.com/questions/15853/how-can-a-script-check-if-its-being-run-as-root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "chroot to " "$1"

# mount /sys /proc /dev 
# https://superuser.com/questions/165116/mount-dev-proc-sys-in-a-chroot-environment
for f in /sys /proc /dev ; do 
    if [[ -e "$1/$f" ]]; then
        # need to be root
        mount --rbind "$f" "$1"/"$f"
        mount --make-rslave "$1"/"$f"
    fi
done

# now chroot to the rootfs
chroot "$1"

# umount /sys /proc /dev 
for f in /sys /proc /dev ; do 
    umount -R  "$1"/"$f"
done
