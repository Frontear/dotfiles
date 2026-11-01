{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.microsoft-edge = {
      enable = lib.mkEnableOption "microsoft-edge";
      package = lib.mkOption {
        default = pkgs.microsoft-edge;

        apply = pkg: pkgs.callPackage ./package.nix {
          microsoft-edge = pkg;

          commandLineArgs = lib.concatStringsSep " " [
            "--user-data-dir=${config.xdg.configHome}/${lib.getName pkg}"
            # Despite the name, this doesn't actually just pick `gnome-keyring`.
            #
            # See: `modules/home-manager/my/programs/element/package.nix`
            "--password-store=gnome-libsecret"
          ];
        };

        type = with lib.types; package;
      };
    };
  };
}