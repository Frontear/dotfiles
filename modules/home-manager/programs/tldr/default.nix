{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.tldr;
in {
  options = {
    my.programs.tldr = {
      enable = lib.mkDefaultEnableOption "tldr";
      package = lib.mkPackageOption pkgs "tldr" {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
