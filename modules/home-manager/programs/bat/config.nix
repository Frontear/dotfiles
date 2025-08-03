{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.bat;
in {
  config = lib.mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
      ];

      shellAliases.cat = lib.getExe cfg.package;
    };
  };
}
