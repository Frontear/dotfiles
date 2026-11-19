{
  lib,
  pkgs,
  ...
}:
let
  fmt = pkgs.formats.json {};

  presetsSubmodule = {
    options = lib.genAttrs [ "input" "output" ] (_: lib.mkOption {
      default = {};

      type = fmt.type;
    });
  };
in {
  options = {
    services.easyeffects = {
      enable = lib.mkEnableOption "easyeffects";
      package = lib.mkOption {
        default = pkgs.easyeffects;

        type = with lib.types; package;
      };

      presets = lib.mkOption {
        default = {};

        type = with lib.types; attrsOf (submodule presetsSubmodule);
      };
    };
  };
}