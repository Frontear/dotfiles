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

          commandLineArgs =
            "--user-data-dir=${config.xdg.configHome}/${lib.getName pkg}";
        };

        type = with lib.types; package;
      };
    };
  };
}
