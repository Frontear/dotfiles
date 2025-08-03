{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.doggo;
in {
  config = lib.mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
      ];

      shellAliases.dig = lib.getExe cfg.package;
    };
  };
}
