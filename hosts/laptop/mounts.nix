{ ... }: let
    impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in {
    imports = [
        "${impermanence}/nixos.nix"
    ];

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
            options = [ "defaults" "fmask=0077" "dmask=0077" ]; # permission fix for world-readible bootctl seed
        };
        #"/home" = {
        #    device = "none";
        #    fsType = "tmpfs";
        #    options = [ "defaults" "size=1G" "mode=755" ];
        #};
        "/nix" = {
            device = "/dev/nvme0n1p2";
            fsType = "ext4";
            options = [ "rw" "noatime" ];
        };
    };

    # setup persistence for impermanence
    environment.persistence."/nix/persist" = {
        directories = [
            "/etc/NetworkManager/system-connections" # only works with unencrypted passwords
            "/etc/nixos"

            "/var/db/sudo/lectured"
            "/var/log"
        ];
        files = [
            "/etc/machine-id" # for /var/log entries
        ];
    };
}
