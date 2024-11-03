{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.element;
in {
  options.my.programs.element = {
    enable = lib.mkEnableOption "armcord";
    package = lib.mkOption {
      default = pkgs.element-desktop;
      defaultText = "pkgs.element-desktop";

      type = with lib.types; package;
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.config/Element";
      mode = "700";
    }];

    home.packages = [ cfg.package ];
  };
}
