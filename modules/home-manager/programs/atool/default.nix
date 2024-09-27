{
  config,
  lib,
  pkgs,
  ...
}:
{
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

  config = lib.mkIf config.my.programs.atool.enable {
    home.packages = [ config.my.programs.atool.package ];
  };
}
