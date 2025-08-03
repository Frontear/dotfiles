{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.bat = {
      enable = lib.mkDefaultEnableOption "bat";
      package = lib.mkOption {
        default = pkgs.bat;

        type = with lib.types; package;
      };
    };
  };
}
