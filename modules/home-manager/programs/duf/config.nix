{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.duf;
in {
  config = lib.mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
      ];

      shellAliases.df = lib.getExe cfg.package;
    };
  };
}
