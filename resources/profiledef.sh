#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux-ddinst"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="Alex Wicks <https://github.com/aw1cks>"
iso_application="Sloth Bootstrap environment"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlz4hc,12')
file_permissions=(
  ["/root/dd.py"]="0:0:755"
  ["/etc/shadow"]="0:0:400"
)
