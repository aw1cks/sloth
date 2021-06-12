#!/bin/sh
cd /var/opt/ansible
ansible-playbook site.yaml
cd /
systemctl disable cloud-init cloud-config cloud-final
rm -rf /bootstrap.sh
