# Information

This folder contains machine-specific configurations, such as drivers, microcode updates, [nixos-hardware](https://github.com/NixOS/nixos-hardware), mounts, kernel modules, and more.

The configurations may contain machine-specific constant values, such as CPU frequencies, GPU make and models, and more, but this is okay because these configs are meant to be machine specific.

## Note

Always generate `hardware-configuration.nix` with `nixos-generate-config --no-filesystems`. Introduce all mounts into `mounts.nix`
