{
  lib,
  pkgs,
  ...
}:
let
  fmt = pkgs.formats.json {};

  autoloadSubmodule = {
    options = lib.genAttrs [
      "device"
      "device-description"
      "device-profile"
      # TODO: setup assertions to catch an invalid preset-name
      "preset-name"
    ] (_: lib.mkOption {
      default = "";

      type = with lib.types; str;
    });
  };

  # TODO: this forces the creation of an `input` preset even without `input`
  # being set up, due to the existence of the attribute. Is this a problem?
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

      autoload = lib.genAttrs [ "input" "output" ] (_: lib.mkOption {
        default = [];

        type = with lib.types; listOf (submodule autoloadSubmodule);
      });

      presets = lib.mkOption {
        default = {};

        type = with lib.types; attrsOf (submodule presetsSubmodule);
      };
    };
  };
}