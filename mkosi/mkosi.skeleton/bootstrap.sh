#!/bin/bash

set -eo pipefail

# cloud-init creates a new system-id
# Work around this so the pacman hooks still work
MACHINE_ID="$(cat /etc/machine-id)"

find /efi -mindepth 1 -maxdepth 1 \
  -not -name "{MACHINE_ID}" \
  -not -name EFI \
  -not -name loader \
  -exec rm -rf {} \;
find /boot -type l \
  -not -name efi \
  -not -name loader \
  -delete
find /efi/loader/entries -type f \
  -not -name "${MACHINE_ID}*" \
  -delete

mkdir -pv "/efi/${MACHINE_ID}"
ln -sv  "../efi/${MACHINE_ID}" "/boot/${MACHINE_ID}"

# Fix for upstream bugs
# PRs upstream but may not be in distro pkgs yet
if [ -f /etc/pacman.d/hooks/91-mkosi-bootctl-update-hook ]
then
  # Work around this issue
  # https://github.com/systemd/mkosi/issues/750
  mv /etc/pacman.d/hooks/91-mkosi-bootctl-update{-,.}hook
fi
sed -i 's@/etc/pacman.d/mkosi-kernel-remove@/etc/pacman.d/scripts/mkosi-kernel-remove@' \
  /etc/pacman.d/hooks/60-mkosi-kernel-remove.hook

# Fire off the hook manually to create our new structure with correct machine-id
echo '' | /etc/pacman.d/scripts/mkosi-kernel-add

if [ -d /var/opt/ansible ]
then
  cd /var/opt/ansible
  ansible-playbook site.yaml -t postinst
fi

if [ -d /var/opt/ansible/tests ]
then
  cd /var/opt/ansible/tests
  ./test
fi

systemctl disable cloud-init cloud-config cloud-final

rm -rf /bootstrap.sh
