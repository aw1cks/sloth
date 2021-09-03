build {
  name = "img"
  source "source.qemu.arch" {
    output_directory  = "${var.output_dir_arch}"
    disk_size         = "7680M"
    boot_command      = [
      "<enter><wait20s><enter>",
      "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/prepare.sh",
      "<enter><wait2s>",
      "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/inst.sh",
      "<enter><wait2s>",
      "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/postinst.sh",
      "<enter><wait2s>",
      "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/ansible-tree.tgz",
      "<enter><wait2s>",
      "/bin/sh ./prepare.sh",
      "<enter>"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "CRYPT_PASSWD=${var.crypt_passwd}"
    ]
    script = "packer/bootstrap.sh"
  }
}
