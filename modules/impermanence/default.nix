{
    config,
    lib,
    username,
    ...
}:
let
    inherit (lib) mdDoc mkEnableOption mkIf mkMerge mkOption optionals types;
in {
    options = {
        impermanence = {
            enable = mkEnableOption ''
            use the system impermanence-style
            '';

            directories = mkOption {
                #type = types.listOf types.path;
                default = [];
                description = mdDoc ''
                The directories to persist, written in the style
                from nix-community/impermanence.
                '';
            };

            files = mkOption {
                #type = types.listOf types.path;
                default = [];
                description = mdDoc ''
                The files to persist, written in the style from
                nix-community/impermanence.
                '';
            };

            persistPath = mkOption {
                type = types.path;
                default = "/nix/persist";
                description = mdDoc ''
                The path to a persistent read/write mount that
                will contain critical files that persist between
                reboots. Ensure this mount exists at boot-time.
                '';
            };

            # TODO: rename
            user_directories = mkOption {
                #type = types.listOf types.path;
                default = [];
                description = mdDoc ''
                The user directories to persist, written in the
                style from nix-community/impermanence.
                '';
            };

            user_files = mkOption {
                #type = types.listOf types.path;
                default = [];
                description = mdDoc ''
                The user files to persist, written in the style
                from nix-community/impermanence.
                '';
            };
        };
    };

    config = mkMerge [
        (mkIf config.impermanence.enable {
            environment.persistence.${config.impermanence.persistPath} = {
                directories = []
                ++ config.impermanence.directories;

                files = []
                ++ config.impermanence.files;

                users.${username} = {
                    directories = []
                    ++ config.impermanence.user_directories;

                    files = []
                    ++ config.impermanence.user_files;
                };
            };
        })
    ];
}
