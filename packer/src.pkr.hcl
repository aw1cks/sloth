source "qemu" "arch" {
  cpus              = "${var.cpus}"
  memory            = "${var.memory}"
  headless          = "${var.headless}"
  accelerator       = "${var.accelerator}"
  net_device        = "${var.net_dev}"
  disk_interface    = "${var.disk_type}"
  machine_type      = "${var.machine_type}"
  firmware          = "${var.ovmf_path}"

  iso_url           = "${var.iso_url}"
  iso_checksum      = "file:${var.iso_checksum_url}"

  format            = "${var.output_disk_format}"

  http_directory    = "${var.http_dir}"

  boot_wait         = "5s"

  ssh_username      = "${var.user}"
  ssh_password      = "${var.passwd}"
  ssh_timeout       = "${var.ssh_timeout}"

  shutdown_command  = "${var.shutdown_cmd}"
}
