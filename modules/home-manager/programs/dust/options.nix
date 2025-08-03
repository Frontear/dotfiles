{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.dust = {
      enable = lib.mkDefaultEnableOption "dust";
      package = lib.mkOption {
        default = pkgs.dust;

        type = with lib.types; package;
      };
    };
  };
}
