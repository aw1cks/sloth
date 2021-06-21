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

# To find the command to re-pack the iso, use bash -x on the script e.g.
# sudo bash -x /usr/bin/mkarchiso -v -w archiso.cache/ -o artefacts/ archlive
# Look for xorriso in the output
# Original command:
# xorriso -as mkisofs -iso-level 3 -full-iso9660-filenames -joliet -joliet-long -rational-rock -volid ARCH_202106 -appid 'Sloth Bootstrap environment' -publisher 'Alex Wicks <https://github.com/aw1cks>' -preparer 'prepared by mkarchiso' -isohybrid-mbr /home/alex/sloth/archiso.cache/iso/syslinux/isohdpfx.bin --mbr-force-bootable -partition_offset 16 -eltorito-boot syslinux/isolinux.bin -eltorito-catalog syslinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -append_partition 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B /home/alex/sloth/archiso.cache/efiboot.img -eltorito-alt-boot -e --interval:appended_partition_2:all:: -no-emul-boot -isohybrid-gpt-basdat -output /home/alex/sloth/artefacts/archlinux-ddinst-2021.06.21-x86_64.iso /home/alex/sloth/archiso.cache/iso/

usb: usbselect img
	@sudo rm -rfv archlive/ archiso.cache/ "artefacts/archlinux-ddinst-$$(date +%Y.%m.%d)-x86_64.iso"
	@cp -rv /usr/share/archiso/configs/baseline/ archlive/
	@cp -rv /usr/share/archiso/configs/releng/airootfs/etc/systemd/system/getty@tty1.service.d/ archlive/airootfs/etc/systemd/system/
	@sudo mv -fv artefacts/archlinux.img archlive/airootfs/
	@rm -fv archlive/profiledef.sh
	@mkdir -pv archlive/airootfs/root/ archiso.cache/
	@cp -v resources/profiledef.sh archlive/profiledef.sh
	@cp -v resources/dd.py archlive/airootfs/root/dd.py
	@cp -v resources/dot_bashlogin archlive/airootfs/root/.bash_login
	@sudo mkarchiso -v -w archiso.cache/ -o artefacts/ archlive
	@find cloud-init -type f -exec cp -v {} archiso.cache/ \;
	@xorriso \
	    -as mkisofs -iso-level 3 \
	    -full-iso9660-filenames \
	    -joliet -joliet-long \
	    -rational-rock -volid ARCH_202106 \
	    -appid 'Sloth Bootstrap environment' \
	    -publisher 'Alex Wicks <https://github.com/aw1cks>' \
	    -preparer 'prepared by mkarchiso' \
	    -isohybrid-mbr "$${PWD}/archiso.cache/iso/syslinux/isohdpfx.bin" \
	    --mbr-force-bootable -partition_offset 16 \
	    -eltorito-boot syslinux/isolinux.bin \
	    -eltorito-catalog syslinux/boot.cat \
	    -no-emul-boot -boot-load-size 4 \
	    -boot-info-table \
	    -append_partition 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B "$${PWD}/archiso.cache/efiboot.img" \
	    -eltorito-alt-boot \
	    -e --interval:appended_partition_2:all:: \
	    -no-emul-boot -isohybrid-gpt-basdat \
	    -output "$${PWD}/artefacts/archlinux-ddinst-$$(date +%Y.%m.%d)-x86_64.iso" \
	    "$${PWD}/archiso.cache/iso/"
	@sudo dd if="artefacts/archlinux-ddinst-$$(date +%Y.%m.%d)-x86_64.iso" of="$$(cat resources/disk)" bs=4M status=progress conv=fsync

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
