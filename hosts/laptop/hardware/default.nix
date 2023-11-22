{ pkgs, ... }:
{
    imports = [
        ./hardware-configuration.nix
    ];

    # cpu
    hardware.cpu.intel.updateMicrocode = true;

    # gpu
    hardware.opengl.extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
        intel-ocl
    ];

    # firmware
    nixpkgs.config.allowUnfree = true;
    hardware.enableAllFirmware = true;

    # drive health
    services.fstrim.enable = true;
    services.btrfs.autoScrub = {
        enable = true;
        fileSystems = [ "/archive" ];
    };

    # mounts
    fileSystems = {
        "/" = {
            device = "none";
            fsType = "tmpfs";
            options = [ "defaults" "size=1G" "mode=755" ];
        };
        "/archive" = {
            device = "/dev/nvme0n1p3";
            fsType = "btrfs";
            options = [ "defaults" "compress-force=zstd:15" ];
        };
        "/boot" = {
            device = "/dev/nvme0n1p1";
            fsType = "vfat";
            options = [ "defaults" "fmask=0077" "dmask=0077" ];
        };
        "/nix" = {
            device = "/dev/nvme0n1p2";
            fsType = "ext4";
            options = [ "rw" "noatime" ];
        };
    };

    # impermanence
    environment.persistence."/nix/persist" = {
        directories = [
            "/etc/NetworkManager/system-connections"
            "/etc/nixos"

            "/var/db/sudo/lectured"
            "/var/log"
        ];
        files = [
            "/etc/machine-id"
        ];
    };
}
