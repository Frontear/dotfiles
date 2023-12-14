{ lib, username, ... }:
let
    path = "/nix/persist";
in {
    # TODO: isolate?
    fileSystems = {
        "/" = {
            device = "none";
            fsType = "tmpfs";
            options = [ "defaults" "mode=755" "noatime" "size=1G" ];
        };
        "/nix" = {
            device = "/dev/disk/by-label/nix";
            fsType = "btrfs";
            options = [ "defaults" "compress=zstd" "noatime" ];
        };
    };

    environment.persistence."${path}" = {
        directories = lib.mkBefore [
            "/etc/NetworkManager"
            "/var/db/sudo"
            "/var/lib/systemd/timers"
        ];
        users."${username}" = {
            directories = lib.mkBefore [
                { directory = ".gnupg"; mode = "0700"; }
                { directory = ".ssh"; mode = "0700"; }

                "Desktop"
                "Documents"
                "Downloads"
                "Music"
                "Pictures"
                "Videos"
            ];
        };
    };
}
