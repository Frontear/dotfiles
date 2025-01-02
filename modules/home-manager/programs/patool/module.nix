{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.patool;
in {
  options = {
    my.programs.patool = {
      enable = lib.mkDefaultEnableOption "patool";
      package = lib.mkOption {
        default = pkgs.callPackage ./package.nix {};

        type = with lib.types; package;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    my.toplevel.cachix = [ cfg.package ];

    home.packages = [ cfg.package ];
  };
}
