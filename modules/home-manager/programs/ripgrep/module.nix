{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.ripgrep;
in {
  options.my.programs.ripgrep = {
    enable = lib.mkDefaultEnableOption "ripgrep";
    package = lib.mkOption {
      default = pkgs.ripgrep;

      type = with lib.types; package;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
