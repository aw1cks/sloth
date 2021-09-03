#!/bin/sh

set -ex

#
# Create partitions and initial install
#


sgdisk \
  -n1:0:+500M  -t1:ef00 -c1:LIVE_BOOT \
  -n2:0:+550M  -t2:8300 -c2:cidata \
  -N3          -t3:8304 -c3:LIVE_ROOT \
  /dev/vda


mkfs.fat -F32 -n LIVE_BOOT /dev/disk/by-partlabel/LIVE_BOOT
dd if=/root/seed.iso of=/dev/disk/by-partlabel/cidata bs=4M status=progress conv=fsync
mkfs.xfs -L LIVE_ROOT /dev/disk/by-partlabel/LIVE_ROOT


mount /dev/disk/by-partlabel/LIVE_ROOT /mnt
mkdir -pv /mnt/boot
mount /dev/disk/by-partlabel/LIVE_BOOT /mnt/boot


pacstrap /mnt \
  base base-devel \
  linux linux-firmware \
  btrfs-progs xfsprogs \
  dracut python3

genfstab -U /mnt >> /mnt/etc/fstab



#
# Continue install from systemd-nspawn
#


cp /root/inst_liveboot.sh /mnt
cp /root/dd.py /mnt/root/
chmod +x /mnt/inst_liveboot.sh /mnt/root/dd.py

# Trigger systemd-nspawn from inside packer
# Copy the disk image first
# See build_liveboot.pkr.hcl
