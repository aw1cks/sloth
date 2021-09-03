#!/bin/bash

set -eo pipefail
set -x

echo 'root:init' | chpasswd
mkdir -pv /etc/systemd/system/getty@tty1.service.d/
echo '[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin root --noclear %I $TERM' > /etc/systemd/system/getty@tty1.service.d/override.conf

# Create AUR user
sudo useradd -u 500 -g nobody -b /var/opt -m aurbuilder
echo 'aurbuilder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-aurbuilder

# Install yay
TMPDIR="$(sudo -u aurbuilder mktemp -d)"
pushd "${TMPDIR}" || exit 1
curl -sL https://aur.archlinux.org/cgit/aur.git/snapshot/dracut-uefi-hook.tar.gz | sudo -u aurbuilder tar --strip-components=1 -xvzf - -C "${TMPDIR}"
sudo -u aurbuilder makepkg -si --noconfirm
popd || exit 1
rm -rf "${TMPDIR}"

mkdir -pv /etc/dracut.conf.d/
echo "kernel_cmdline=\"$(blkid -s UUID -o value /dev/disk/by-partlabel/LIVE_ROOT)\"" > /etc/dracut.conf.d/cmdline.conf

# Configure systemd-boot
bootctl install

# Add our bash profile to autolaunch DD script
echo 'python3 /root/dd.py && systemctl reboot' > /root/.bash_login
