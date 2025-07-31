{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.chromium = {
      enable = lib.mkEnableOption "chromium";
      package = lib.mkOption {
        apply = pkg: pkgs.callPackage ./package.nix {
          chromium = pkg;

          commandLineArgs =
            "--user-data-dir=${config.xdg.configHome}/${lib.getName pkg}";
        };

        type = with lib.types; package;
      };
    };
  };
}
