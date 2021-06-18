#!/bin/sh

if [ -d /var/opt/ansible ]
then
  cd /var/opt/ansible
  ansible-playbook site.yaml
fi

if [ -d /var/opt/ansible/tests ]
then
  cd /var/opt/ansible/tests
  ./test
fi

systemctl disable cloud-init cloud-config cloud-final

rm -rf /bootstrap.sh
