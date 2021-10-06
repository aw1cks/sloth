MIRROR ?= https://mirror.bytemark.co.uk

# Use previous month's release for the first few days of the month
YEAR := $(shell sh -c '[ "$$(date +'%d')" -gt "5" ] && date +"%Y" || date --date="-1 month" +"%Y"')
MONTH := $(shell sh -c '[ "$$(date +'%d')" -gt "5" ] && date +"%m" || date --date="-1 month" +"%m"')
VERSION ?= $(YEAR).$(MONTH).01

CPU_ARCH ?= x86_64

ARCH_URL := $(MIRROR)/archlinux/iso/$(VERSION)/archlinux-$(VERSION)-$(CPU_ARCH).iso
ARCH_CHECKSUM_URL := $(MIRROR)/archlinux/iso/$(VERSION)/sha1sums.txt

QEMU_IMG ?= img

ifdef TTY
	QEMU_TTY := -nographic
else
	QEMU_TTY :=
endif

.PHONY: clean
.PHONY: cloudinit
.PHONY: ansible
.PHONY: passwd_prompt
.PHONY: passwd
.PHONY: packer_img
.PHONY: packer_iso
.PHONY: packer
.PHONY: qemu_img
.PHONY: qemu_iso
.PHONY: qemu

clean: 
	@./log.sh warn 'Cleaning old artefacts'
	@rm -rf artefacts/ packer/http/ansible-tree.tgz packer/http/seed.iso
	@printf '\n'

cloudinit:
	@./log.sh info 'Generating cloud-init ISO'
	@printf '\n'
	@cloud-localds -v --network-config=cloud-init/network-config packer/http/seed.iso cloud-init/user-data cloud-init/meta-data
	@printf '\n\n'

ansible:
	@./log.sh info 'Tarring ansible tree'
	@tar -czf packer/http/ansible-tree.tgz ansible
	@printf '\n\n'

passwd_prompt:
	@./log.sh warn 'Please enter your LUKS password (output will be hidden):'
passwd: passwd_prompt
	$(eval passwd := $(shell bash -c 'read -s CRYPT_PASSWD; echo "$${CRYPT_PASSWD}"'))
	@printf '\n\n'

ifdef CRYPT
packer_img: clean ansible passwd
else
packer_img: clean ansible
	$(eval passwd := )
endif
	@./log.sh info 'Building packer disk image'
	@printf '\n'
	@packer build \
	  -var 'iso_url=$(ARCH_URL)' \
		-var 'iso_checksum_url=$(ARCH_CHECKSUM_URL)' \
		-var 'crypt_passwd=$(passwd)' \
		-timestamp-ui \
		-only=img.qemu.arch \
		packer/
	@printf '\n\n'

packer_iso: cloudinit
	@./log.sh info 'Building packer liveboot image'
	@printf '\n'
	@packer build \
	  -var 'iso_url=$(ARCH_URL)' \
		-var 'iso_checksum_url=$(ARCH_CHECKSUM_URL)' \
		-timestamp-ui \
		-only=liveboot.qemu.arch \
		packer/
	@printf '\n\n'
packer: packer_img packer_iso

qemu_img:
	@qemu-system-x86_64 $(QEMU_TTY) \
	  -enable-kvm \
	  -bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	  -m 4096 -smp "$(nproc)" \
	  -netdev user,id=ens3 \
	  -device e1000,netdev=ens3 \
	  -drive file=artefacts/img/packer-arch,if=virtio,format=raw

qemu_iso:
	@qemu-system-x86_64 $(QEMU_TTY) \
	  -enable-kvm \
	  -bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	  -m 4096 -smp "$(nproc)" \
	  -netdev user,id=ens3 \
	  -device e1000,netdev=ens3 \
	  -drive file=artefacts/iso/packer-arch,if=virtio,format=raw \
	  -drive file=artefacts/img/packer-arch,if=virtio,format=raw

qemu:
	@qemu-system-x86_64 $(QEMU_TTY) \
	  -enable-kvm \
	  -bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	  -m 4096 -smp "$(nproc)" \
	  -netdev user,id=ens3 \
	  -device e1000,netdev=ens3 \
	  -drive file=artefacts/img/packer-arch,if=virtio,format=raw \
	  -drive file=artefacts/iso/packer-arch,if=virtio,format=raw
