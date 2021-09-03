#!/bin/sh

set -e

echo 'root:init' | chpasswd -c SHA512
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl restart sshd
