build {
  name = "liveboot"
  source "source.qemu.arch" {
    output_directory  = "${var.output_dir_archiso}"
    disk_size         = "15360M"
    boot_command      = [
      "<enter><wait20s><enter>",
      "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/prepare.sh",
      "<enter><wait2s>",
      "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/inst_liveboot.sh",
      "<enter><wait2s>",
      "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/dd.py",
      "<enter><wait2s>",
      "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/seed.iso",
      "<enter><wait2s>",
      "/bin/sh ./prepare.sh",
      "<enter>"
    ]
  }

  provisioner "shell" {
    script = "packer/bootstrap_liveboot.sh"
  }

  provisioner "file" {
    source = "artefacts/img/packer-arch"
    destination = "/mnt/archlinux.img"
    generated = true
  }

  provisioner "shell" {
    inline = [
      "systemd-nspawn -D /mnt /inst_liveboot.sh"
    ]
  }

}
