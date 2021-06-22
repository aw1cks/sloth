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

usbselect:
	@rm -fv resources/disk
	@python3 resources/dd.py --noop

usb: usbselect img
	@sudo rm -rfv archlive/ archiso.cache/ "artefacts/archlinux-ddinst-$$(date +%Y.%m.%d)-x86_64.iso"
	@cp -rv /usr/share/archiso/configs/baseline/ archlive/
	@cp -rv /usr/share/archiso/configs/releng/airootfs/etc/systemd/system/getty@tty1.service.d/ archlive/airootfs/etc/systemd/system/
	@sudo mv -fv artefacts/archlinux.img archlive/airootfs/
	@rm -rfv archlive/profiledef.sh archlive/airootfs/etc/systemd/system/cloud-init.target.wants
	@mkdir -pv archlive/airootfs/root/ archiso.cache/
	@cp -v resources/profiledef.sh archlive/profiledef.sh
	@cp -v resources/dd.py archlive/airootfs/root/dd.py
	@cp -v resources/dot_bashlogin archlive/airootfs/root/.bash_login
	@sudo mkarchiso -v -w archiso.cache/ -o artefacts/ archlive
	@sudo dd if="artefacts/archlinux-ddinst-$$(date +%Y.%m.%d)-x86_64.iso" of="$$(cat resources/disk)" bs=4M status=progress conv=fsync
	@printf "%s\nstart=%s, size=102400, type=83\n" "$$(sudo sfdisk -d $$(readlink -f $$(cat resources/disk)))" "$$(sudo sfdisk -d $$(readlink -f $$(cat resources/disk)) | tail -1 | awk '{print $$4 $$6 }' | sed 's/,/ /g' | awk '{print int($$1) + int($$2) + 1}')" | sudo sfdisk "$$(readlink -f $$(cat resources/disk))"
	@sudo dd if="artefacts/seed.iso" of="$$(cat resources/disk)-part3" bs=4M status=progress conv=fsync
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
	@rm -rfv mkosi/mkosi.skeleton/var/opt/ansible/ liveboot/ resources/disk

distclean: clean
	@sudo rm -rfv mkosi/mkosi.cache/ archiso.cache/
