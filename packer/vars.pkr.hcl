// LUKS password
variable "crypt_passwd" {
  type = string
  sensitive = true
  default = ""
}

// QEMU Settings
variable "cpus" {
  type = number
  default = 4
}
variable "memory" {
  type = number
  default = 4096
}
variable "headless" {
  type = bool
  default = true
}
variable "accelerator" {
  type = string
  default = "kvm"
}
variable "net_dev" {
  type = string
  default = "virtio-net"
}
variable "disk_type" {
  type = string
  default = "virtio"
}
variable "machine_type" {
  type = string
  default = "q35"
}
variable "ovmf_path" {
  type = string
  default = "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd"
}
variable "iso_url" {
  type = string
}
variable "iso_checksum_url" {
  type = string
}
variable "http_dir" {
  type = string
  default = "packer/http"
}

// Connection settings
variable "user" {
  type = string
  default = "root"
}
variable "passwd" {
  type = string
  default = "init"
}
variable "ssh_timeout" {
  type = string
  default = "5m"
}
variable "shutdown_cmd" {
  type = string
  default = "systemctl poweroff"
}

// Output settings
variable "output_disk_format" {
  type = string
  default = "raw"
}
variable "output_dir_arch" {
  type = string
  default = "artefacts/img"
}
variable "output_dir_archiso" {
  type = string
  default = "artefacts/iso"
}
