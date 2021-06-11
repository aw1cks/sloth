ansible: mkosi/mkosi.skeleton/var/opt/ansible
	@find mkosi/mkosi.skeleton/var/opt/ansible -mindepth 1 -not -name .keep -delete -print
	@cp -rv ansible mkosi/mkosi.skeleton/var/opt/
	@tree mkosi/mkosi.skeleton/var/opt/ 

artefacts/seed.iso:
cloudinit: artefacts/seed.iso
	@genisoimage -output artefacts/seed.iso -volid cidata -joliet -rock cloud-init/*
	@tree artefacts

artefacts/archlinux.img:
img: ansible cloudinit artefacts/archlinux.img 
	@cd mkosi; sudo mkosi --force
img-stty: ansible cloudinit artefacts/archlinux.img
	@cd mkosi; sudo mkosi --kernel-command-line='!* console=ttyS0 selinux=0 audit=0 rw' --force

qemu: img-stty
	@qemu-system-x86_64 \
	  -enable-kvm \
	  -bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	  -nographic \
	  -m 1024 -smp 4 \
	  -drive file=artefacts/archlinux.img,if=virtio,format=raw \
	  -drive file=artefacts/seed.iso,if=virtio,media=cdrom

clean:
	@find mkosi/mkosi.skeleton/var/opt/ansible -mindepth 1 -not -name .keep -delete -print
	@find artefacts -mindepth 1 -not -name .keep -delete -print

distclean: clean
	@sudo find mkosi/mkosi.cache/ -mindepth 1 -not -name .keep -delete -print
