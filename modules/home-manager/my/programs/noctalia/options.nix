{
  lib,
  pkgs,
  ...
}:
let
  fmt = pkgs.formats.toml { };
in {
  options = {
    my.programs.noctalia = {
      enable = lib.mkEnableOption "Noctalia";

      package = lib.mkOption {
        default = pkgs.noctalia;

        type = with lib.types; package;
      };

      settings = lib.mkOption {
        default = {};

        type = fmt.type;
      };
    };
  };
}