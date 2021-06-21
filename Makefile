.PHONY: clean distclean qemushell

ansible_example:
	@cp -rv examples/ansible .
cloud-init_example:
	@cp -rv examples/cloud-init .
example_conf: ansible_example cloud-init_example

mkosi/mkosi.skeleton/var/opt/ansible:
	@mkdir -pv mkosi/mkosi.skeleton/var/opt/ansible
ansible: mkosi/mkosi.skeleton/var/opt/ansible
	@rm -rfv mkosi/mkosi.skeleton/var/opt/ansible
	@cp -rv ansible mkosi/mkosi.skeleton/var/opt/
	@tree mkosi/mkosi.skeleton/var/opt/ 

artefacts/seed.iso:
	@mkdir -pv artefacts
cloudinit: artefacts/seed.iso
	@genisoimage -output artefacts/seed.iso -volid cidata -joliet -rock cloud-init/*
	@tree artefacts

artefacts/archlinux.img:
	@mkdir -pv artefacts
mkosi_cache:
	@mkdir -pv mkosi/mkosi.cache
img: ansible cloudinit artefacts/archlinux.img mkosi_cache
	@cd mkosi; sudo mkosi --force
img-stty: ansible cloudinit artefacts/archlinux.img mkosi_cache
	@cd mkosi; sudo mkosi --kernel-command-line='!* console=ttyS0 selinux=0 audit=0 rw' --force

usb:
	@sudo rm -rfv archlive/ /tmp/archiso/ resources/disk "artefacts/archlinux-ddinst*.iso"
	@python3 resources/dd.py --noop
	@cp -rv /usr/share/archiso/configs/baseline/ archlive/
	@rm -fv archlive/profiledef.sh
	@mkdir -pv archlive/airootfs/root/ /tmp/archiso
	@cp -v resources/profiledef.sh archlive/profiledef.sh
	@cp -v resources/dd.py archlive/airootfs/root/dd.py
	@cp -v resources/dot_bashrc archlive/airootfs/root/.bashrc
	@sudo mkarchiso -v -w /tmp/archiso -o artefacts/ archlive
	@sudo dd if="$$(find artefacts -name 'archlinux-ddinst*')" of="$$(cat resources/disk)" bs=4M status=progress conv=fsync

qemu: img-stty
	@qemu-system-x86_64 \
	  -enable-kvm \
	  -bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	  -nographic \
	  -m 4096 -smp "$$(nproc)" \
	  -netdev user,id=ens3 \
	  -device e1000,netdev=ens3 \
	  -drive file=artefacts/archlinux.img,if=virtio,format=raw \
	  -drive file=artefacts/seed.iso,if=virtio,media=cdrom

qemushell:
	@qemu-system-x86_64 \
	  -enable-kvm \
	  -bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	  -nographic \
	  -m 4096 -smp "$$(nproc)" \
	  -netdev user,id=ens3 \
	  -device e1000,netdev=ens3 \
	  -drive file=artefacts/archlinux.img,if=virtio,format=raw \
	  -drive file=artefacts/seed.iso,if=virtio,media=cdrom

clean:
	@sudo rm -rfv artefacts/
	@rm -rfv mkosi/mkosi.skeleton/var/opt/ansible/
	@rm -rfv liveboot/
	@rm -fv resources/disk

distclean: clean
	@sudo rm -rfv mkosi/mkosi.cache/
