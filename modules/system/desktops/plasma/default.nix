{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf mkMerge;

  attrs = {
    # Activate plasma and sddm, with explicit wayland support.
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = mkDefault true;

    # Enable pipewire as the main audio service.
    my.system.audio.pipewire.enable = mkDefault true;

    # https://wiki.nixos.org/wiki/KDE#GTK_themes_are_not_applied_in_Wayland_applications_/_Window_Decorations_missing_/_Cursor_looks_different
    programs.dconf.enable = true;

    # Use a generic font that supports icons
    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];
  };
in {
  options.my.system.desktops.plasma = {
    enable = mkEnableOption "plasma";

    default = mkEnableOption "make default";
  };

  config = mkIf config.my.system.desktops.plasma.enable (mkMerge [
    (mkIf config.my.system.desktops.plasma.default ({
      assertions = [
        {
          assertion = !config.my.system.desktops.cosmic.default;
          message = "Plasma and Cosmic cannot both be default.";
        }
      ];
    } // attrs))
    (mkIf (!config.my.system.desktops.plasma.default) {
      specialisation.plasma.configuration = attrs;
    })
  ]);
}
