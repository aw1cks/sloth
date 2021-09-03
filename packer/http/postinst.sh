#!/bin/bash

set -eo pipefail

# cloud-init can be buggy with applying out netconf
# Do this explicitly just to be sure
netplan apply

until nc -zvw3 google.com 443
do
  printf 'Waiting for network...\n'
  sleep 3
done


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


chown -R alex:alex /var/opt/ansible
rm /inst.sh /postinst.sh
pacman -R --noconfirm cloud-init
