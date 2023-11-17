# Frontear's dotfiles

My work-in-progress dotfiles powered by NixOS. They will stay WIP for a while as I learn Nix, the language, Nix, the package manager(?), and Nix, the command line.

## Setup Impermanence

My dotfiles are explicitly designed to make use of [impermanence](https://github.com/nix-community/impermanence). As such, I recommend setting up an impermanence-styled mount setup.

Upon first installation, do:
```console
[root@nixos:~]# mount -t tmpfs none /mnt --mkdir
[root@nixos:~]# mount /dev/boot_device /mnt/boot --mkdir
[root@nixos:~]# mount /dev/nix_device /mnt/nix --mkdir
[root@nixos:~]# nixos-generate-config --root /mnt
```

If you're already running a NixOS system, you can add the following snippet in-place:
```nix
fileSystems = {
    "/" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "defaults" "size=1G" "mode=755" ]; # won't ever need more than 1G usually
    };
    "/boot" = {
        device = "/dev/boot_device";
        fsType = "fsType"; # probably vfat
    };
    "/nix" = {
        device = "/dev/nix_device";
        fsType = "fsType";
    };
};
```
