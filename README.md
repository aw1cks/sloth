# Sloth

*Linux provisioning, for the lazy*

This is a hands-off provisioning method primarily intended for installing Arch Linux on bare-metal.

Clone this repository, build the image, and `dd` it to your disk.

## Requirements

 - `cloud-utils`
 - `edk2-ovmf`
 - `packer`
 - `qemu`

## How this works

 - An ISO containing cloud-init config is created (`artefacts/seed.iso`)
 - Packer creates a golden image (`artefacts/img/packer-arch`)
 - The cloud-init config from `seed.iso` is used at first boot
 - For bare-metal, an arch liveboot (`artefacts/iso/packer-arch`) is generated which can be copied to a USB stick, which will automatically `dd` the image to the specified disk
 - The provisioning script (`packer/http/postinst.sh`) is run, which runs `ansible` on the machine against itself

To use this, place your ansible config under `ansible/` and cloud-init files under `cloud-init/`. Then run `make packer`.

## Building an image

1. Place your cloud-init configuration in `cloud-init/` (see the example configuration in `examples/cloud-init/`).
2. Place your Ansible configuration in `ansible/` (see the example configuration in `examples/ansible`). Make sure you have a `site.yaml` which will run your desired configuration.
3. Build the images using the `packer` target of the Makefile:
```shell
$ make packer
```
4. `dd` the resultant image `artefacts/iso/packer-arch` to your USB stick.
5. Boot from your USB stick, and select the disk you'd like to copy your install to. **THIS WILL WIPE THE CONTENTS OF THE DISK!**

The following variables can be overridden in the Makefile:

| Variable  | Description                                                                          | Example                                |
|-----------|--------------------------------------------------------------------------------------|----------------------------------------|
| `VERSION` | The Arch ISO version to download & use for image builds                              | `VERSION=2021.09.01`                   |
| `MIRROR`  | Log contents - freetext field                                                        | `MIRROR=https://mirror.bytemark.co.uk` |
| `CRYPT`   | Set this to `1` to enable an encrypted root. Will prompt for password at build time. | `CRYPT=1`

For example, to use a specific version of the Arch ISO from a specific mirror:

```shell
make packer VERSION='2021.09.01' MIRROR='https://mirror.bytemark.co.uk'
```

To make an image with an encrypted root (will prompt for password when building):

```shell
$ make packer CRYPT=1
```

## Ansible

Example configuration can be found under `examples/ansible/`.

The [AUR module](https://github.com/kewlfft/ansible-aur) is baked into the golden image, along with `yay`.

This allows provisioning of packages.
