{
  config,
  lib,
  pkgs,
  ...
}:
let
  path = lib.splitString "." <| "my.programs.fastfetch";
  cfg = lib.getAttrFromPath path config;
in {
  options = lib.setAttrByPath path {
    enable = lib.mkDefaultEnableOption "fastfetch";
    package = lib.mkPackageOption pkgs "fastfetch" {};
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
