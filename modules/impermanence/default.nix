{
    config,
    lib,
    username,
    ...
}:
let
    inherit (lib) mdDoc mkEnableOption mkIf mkOption optionals types;
in {
    options.impermanence = {
        enable = mkEnableOption "enable the usage of impermanence (tmpfs root)";

        persistPath = mkOption {
            type = types.path;
            description = mdDoc ''
            The path to a read-write persistent mount that will
            contain and persist critical files between reboots.
            '';
        };
    };

    # TODO: assumption that environment.persistence exists (impermanence imported elsewhere)
    config = mkIf config.impermanence.enable {
        environment.persistence.${config.impermanence.persistPath} = {
            directories = [
                "/var/lib/systemd/timers" # TODO: determine necessity
            ] ++ optionals config.networking.networkmanager.enable [
                "/etc/NetworkManager"
            ] ++ optionals config.security.sudo.enable [
                "/var/db/sudo"
            ];
            users."${username}" = {
                directories = [
                    "Desktop"
                    "Documents"
                    "Downloads"
                    "Music"
                    "Pictures"
                    "Videos"
                ] ++ optionals config.home-manager.users.${username}.programs.gpg.enable [
                    { directory = ".gnupg"; mode = "0700"; }
                ] ++ optionals config.home-manager.users.${username}.services.gpg-agent.enableSshSupport [
                    { directory = ".ssh"; mode = "0700"; }
                ];
            };
        };
    };
}
