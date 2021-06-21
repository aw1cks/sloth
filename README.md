# Sloth

*Linux provisioning, for the lazy*

This is a hands-off provisioning method primarily intended for installing Arch Linux on bare-metal.

Clone this repository, build the image, and `dd` it to your disk.

## Requirements

### Building the image

 - `arch-install-scripts`
 - `genisoimage`
 - `mkosi` and its requirements

### Building the bootstrap ISO

 - `archiso`

### Testing the image in a VM

 - `edk2-ovmf`
 - `qemu`

## How this works

 - An ISO containing cloud-init config is created (`seed.iso`)
 - A golden image is created using `mkosi` (`archlinux.img`)
 - The cloud-init config from `seed.iso` is used at first boot
 - For bare-metal, an arch ISO is generated which can be copied to a USB stick, which will automatically `dd` the image to the specified disk
 - The provisioning script is run, which runs `ansible` on the machine against itself

To use this, place your ansible config under `ansible/` and cloud-init files under `cloud-init/`.

Examples are available in `examples/`.

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
$ make usb
```

This will dd an ISO to a USB stick. Plug this USB stick in to the target PC, then let it dd the OS to the disk of that machine.

## Ansible

Example configuration can be found under `examples/ansible/`.

The [AUR module](https://github.com/kewlfft/ansible-aur) is baked into the golden image, along with `yay`.

This allows provisioning of packages.
