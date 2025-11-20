# Frontear's Dotfiles

Declarative and reproducible configuration for my systems, powered by NixOS ❄️.

## Installation

1. Build the latest ISO image through Nix:

    ```console
    $ nix build github:Frontear/dotfiles#ISO-3DT4F02.config.system.build.isoImage
    ```

    Then, copy it to a USB drive and boot from it.

2. Create the expected partition table using the following script:
    ```bash
    #!/usr/bin/env bash

    # NOTE: run this as root.

    # Declare the target disk ahead-of-time
    export DISK="/dev/<DEVICE>" # e.g. /dev/sda, /dev/nvme0n1, ...

    # Wipe all existing partitions from the drive
    sfdisk --delete "$DISK"

    # Use the GPT partition layout
    sfdisk "$DISK" <<< "label: gpt"

    # Create the EFI partition
    sfdisk --append "$DISK" <<< ",1G,U"

    # Create the Nix partition
    sfdisk --append "$DISK" <<< ",,L"

    # Label the newly created partitions
    sfdisk --part-label "$DISK" 1 "boot"
    sfdisk --part-label "$DISK" 2 "nix"
    ```

3. Format the created partitions with the expected fs types:

    ```console
    $ wipefs --all /dev/disk/by-partlabel/boot
    $ wipefs --all /dev/disk/by-partlabel/nix
    $ mkfs.fat -F 32 /dev/disk/by-partlabel/boot
    $ mkfs.btrfs -n 64k /dev/disk/by-partlabel/nix
    ```

4. Mount them into `/mnt` for the installer:

    ```console
    $ mount -t tmpfs -o mode=0755,noatime,noswap,size=1G tmpfs /mnt --mkdir
    $ mount -o dmask=0022,fmask=0022,noatime /dev/disk/by-partlabel/boot /mnt/boot --mkdir
    $ mount -o compress=zstd:15,noatime /dev/disk/by-partlabel/nix /mnt/nix --mkdir
    ```

5. Install configuration to target root in `/mnt`:

   ```console
   $ nixos-install --flake "github:Frontear/dotfiles#<HOST>" --no-channel-copy --no-root-password
   ```

<!--
## Usage

## Contributing
-->

## License

[GNU AGPL v3 or later](LICENSE)