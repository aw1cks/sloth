#!/bin/bash

set -eo pipefail
set -x

CRYPT_PASSWD="${1}"
CRYPT_UUID="${2}"

echo 'root:init' | chpasswd

echo "EDITOR='nvim'
alias vim='nvim'
alias vi='nvim'" > /etc/profile.d/editor.sh

# Create AUR user
sudo useradd -u 500 -g nobody -b /var/opt -m aurbuilder
echo 'aurbuilder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-aurbuilder

# Install yay
TMPDIR="$(sudo -u aurbuilder mktemp -d)"
pushd "${TMPDIR}" || exit 1
curl -sL https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz | sudo -u aurbuilder tar --strip-components=1 -xvzf - -C "${TMPDIR}"
sudo -u aurbuilder makepkg -si --noconfirm
popd || exit 1
rm -rf "${TMPDIR}"

# Install ansible AUR module
sudo -u aurbuilder yay -S --noconfirm ansible-aur-git

# Set some default repos
echo 'Server = http://mirrors.evowise.com/archlinux/$repo/os/$arch
Server = http://mirror.rackspace.com/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# Cloud-init config
printf '\ndatasource_list: [ NoCloud ]\n' >> /etc/cloud/cloud.cfg
printf 'datasource: NoCloud\n' > /etc/cloud/ds-identify.cfg
rm -fv /etc/ssh/ssh_host_*

# Enable cloud-init
systemctl enable \
  cloud-init.service \
  cloud-init-local.service \
  cloud-config.service \
  cloud-final.service

# Configure dracut
if [ -n "${CRYPT_PASSWD}" ]
then
  mkdir -pv /etc/dracut.conf.d/
  echo "kernel_cmdline=\"rd.luks.name=${CRYPT_UUID}=root root=/dev/mapper/root\""
fi

sudo -u aurbuilder yay -S --noconfirm dracut-uefi-hook

# Configure systemd-boot
bootctl install

# Misc
echo "HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
bindkey -e

autoload -Uz promptinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
          promptinit;
  else
            promptinit -C;
fi;
setopt PROMPT_SUBST

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
                compinit;
        else
                        compinit -C;
fi;
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select

alias ls='ls --color=auto'
PS1='[%n@%m %~]%# '" > /etc/skel/.zshrc
