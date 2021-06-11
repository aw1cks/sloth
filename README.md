# Sloth

*Linux provisioning, for the lazy*

This is a hands-off provisioning method primarily intended for installing Arch Linux on bare-metal.

Clone this repository, build the image, and `dd` it to your disk.

## Requirements

### Building the image

 - `arch-install-scripts`
 - `genisoimage`
 - `mkosi` and its requirements

### Testing the image in a VM

 - `edk2-ovmf`
 - `qemu`

## How this works

 - An ISO containing cloud-init config is created (`seed.iso`)
 - A golden image is created using `mkosi` (`archlinux.img`)
 - The cloud-init config from `seed.iso` is used at first boot
 - The provisioning script is run, which runs `ansible` on the machine against itself

To use this, place your ansible config under `ansible/` and cloud-init files in `cloud-init`

Examples are available in `examples`.

For a quick start to see this in action:

```shell
$ make example_conf qemu
```

## Golden Image

```shell
$ make img
```

### Testing with QEMU

```shell
$ make qemu
```

### Copying to bare-metal

```shell
# dd if=archlinux.img of=/dev/<your-blockdev> bs=4M status=progress oflag=sync
```

## Ansible

Example configuration can be found under `ansible/`.

The [AUR module](https://github.com/kewlfft/ansible-aur) is baked into the golden image, along with `yay`.

This allows provisioning of packages.
