{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.dust;
in {
  config = lib.mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
      ];

      shellAliases.du = lib.getExe cfg.package;
    };
  };
}