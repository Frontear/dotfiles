{ lib, username, ... }:
let
    path = "/nix/persist";
in {
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
