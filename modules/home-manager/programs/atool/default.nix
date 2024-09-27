{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.atool;
in {
  options.my.programs.atool = {
    enable = lib.mkDefaultEnableOption "atool";
    package = lib.mkOption {
      default = pkgs.callPackage ./package.nix {};
      defaultText = "<wrapped-drv>";
      description = ''
        The atool package to use.
      '';

      type = with lib.types; package;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
