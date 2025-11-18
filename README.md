# Frontear's Dotfiles

Declarative and reproducible configuration for my systems, powered by NixOS ❄️.

## Installation

1. Build the latest ISO image and copy it to a USB drive

    ```console
    $ nix build github:Frontear/dotfiles#ISO-3DT4F02.config.system.build.isoImage
    ```

2. Format drives in the following format:

    |  **Mount**  | **FS Type** | **Size** |
    |:------------|:-----------:|:--------:|
    | `/`         |   `tmpfs`   |   256M   |
    | `/boot`     |   `fat32`   |    1G    |
    | `/nix`      |   `btrfs`   |   rest   |

3. Install configuration to target root in `/mnt`

   ```console
   $ nixos-install --flake github:Frontear/dotfiles#<HOST> --no-channel-copy --no-root-password
   ```

<!--
## Usage

## Contributing
-->

## License

[GNU AGPL v3 or later](LICENSE)