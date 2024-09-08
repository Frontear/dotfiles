{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.programs.atool = {
    enable = lib.mkEnableOption "atool" // { default = true; };
    package = lib.mkPackageOption pkgs "atool" {} // {
      default = pkgs.callPackage ./package.nix {};
    };
  };

  config = lib.mkIf config.my.programs.atool.enable {
    home.packages = [ config.my.programs.atool.package ];
  };
}