{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.doggo = {
      enable = lib.mkDefaultEnableOption "doggo";
      package = lib.mkOption {
        default = pkgs.doggo;

        type = with lib.types; package;
      };
    };
  };
}