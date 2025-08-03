{
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.programs.hyperfine = {
      enable = lib.mkDefaultEnableOption "hyperfine";
      package = lib.mkOption {
        default = pkgs.hyperfine;

        type = with lib.types; package;
      };
    };
  };
}
