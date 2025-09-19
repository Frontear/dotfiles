{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.rofi;

  conf = config.home.file.${cfg.configPath}.source;
in {
  config = lib.mkIf cfg.enable {
    programs.rofi = {
      package = pkgs.callPackage ./package.nix {
        extraArgs = "-config ${conf}";
      };

      # Stylix doesn't set these in their module, so we add it here instead.
      extraConfig = lib.mkIf (config.stylix.enable && config.stylix.targets.gtk.enable) {
        show-icons = true;
        icon-theme = config.gtk.iconTheme.name;
      };
    };

    home.file.${cfg.configPath}.enable = lib.mkForce false;

    # Can't inject via `-theme` because the config tries to load this as well.
    # Since config expects this file to exist, just leave it here.
    xdg.dataFile."rofi/themes/custom.rasi".enable = lib.mkForce true;
  };
}