#!/bin/sh

set -ex

#
# Create partitions and initial install
#

env

if [ -n "${CRYPT_PASSWD}" ]
then
  ROOT_PARTLABEL='cryptroot'
  ROOT_DISK='/dev/mapper/root'
else
  ROOT_PARTLABEL='root'
  ROOT_DISK='/dev/disk/by-partlabel/root'
fi

sgdisk \
  -n1:0:+500M  -t1:ef00 -c1:EFISYSTEM \
  -n2:0:+1000M -t2:ea00 -c2:XBOOTLDR \
  -N3          -t3:8304 "-c3:${ROOT_PARTLABEL}" \
  /dev/vda

lsblk

mkfs.fat -F32 -n EFISYSTEM /dev/disk/by-partlabel/EFISYSTEM
mkfs.fat -F32 -n XBOOTLDR /dev/disk/by-partlabel/XBOOTLDR

if [ -n "${CRYPT_PASSWD}" ]
then
  printf "${CRYPT_PASSWD}" | cryptsetup luksFormat  \
    -v -q \
    --align-payload=8192 \
    -s 256 \
    -c aes-xts-plain64 \
    "/dev/disk/by-partlabel/${ROOT_PARTLABEL}" -

  printf "${CRYPT_PASSWD}" | cryptsetup open -v "/dev/disk/by-partlabel/${ROOT_PARTLABEL}" root -
fi

mkfs.btrfs -L linux "${ROOT_DISK}"


mount "${ROOT_DISK}" /mnt

btrfs su cr /mnt/@
btrfs su set-default /mnt/@

btrfs su cr /mnt/@home
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt

umount /mnt


mount -o relatime,commit=120,space_cache,subvol=@ "${ROOT_DISK}" /mnt

for DIR in home var opt boot efi; do mkdir -pv "/mnt/${DIR}"; done

mount -o defaults,relatime,commit=120,compress=zstd,space_cache,subvol=@home "${ROOT_DISK}" /mnt/home
mount -o defaults,relatime,commit=120,space_cache,subvol=@opt "${ROOT_DISK}" /mnt/opt
mount -o defaults,subvol=@var "${ROOT_DISK}" /mnt/var

mount /dev/disk/by-partlabel/EFISYSTEM /mnt/efi
mount /dev/disk/by-partlabel/XBOOTLDR /mnt/boot


pacstrap /mnt \
  base base-devel \
  linux linux-firmware btrfs-progs \
  ansible cloud-guest-utils \
  cloud-init cloud-utils crda \
  dhcpcd dracut git go neovim \
  netplan networkmanager \
  openbsd-netcat openssh \
  reflector tmux wget zsh


genfstab -t PARTLABEL /mnt >> /mnt/etc/fstab



#
# Continue install from systemd-nspawn
#


for FILE in inst.sh postinst.sh
do
  cp "/root/${FILE}" /mnt
  chmod +x "/mnt/${FILE}"
done

mkdir -pv /mnt/var/opt/ansible
tar -xvzf /root/ansible-tree.tgz -C /mnt/var/opt/ansible --strip-components=1


systemd-nspawn -D /mnt /inst.sh "${CRYPT_PASSWD}" "$(blkid -s UUID -o value "/dev/disk/by-partlabel/${ROOT_PARTLABEL}")"
