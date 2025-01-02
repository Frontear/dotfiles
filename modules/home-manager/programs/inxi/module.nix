{
  config,
  lib,
  pkgs,
  ...
}:
let
  path = lib.splitString "." <| "my.programs.inxi";
  cfg = lib.getAttrFromPath path config;
in {
  options = lib.setAttrByPath path {
    enable = lib.mkDefaultEnableOption "inxi";
    package = lib.mkOption {
      default = pkgs.callPackage ./package.nix {};

      type = with lib.types; package;
    };
  };

  config = lib.mkIf cfg.enable {
    my.toplevel.cachix = [ cfg.package ];

    home.packages = [ cfg.package ];
  };
}
