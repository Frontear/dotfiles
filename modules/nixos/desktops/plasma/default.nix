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
    my.audio.pipewire.enable = mkDefault true;

    # https://wiki.nixos.org/wiki/KDE#GTK_themes_are_not_applied_in_Wayland_applications_/_Window_Decorations_missing_/_Cursor_looks_different
    programs.dconf.enable = true;

    # Use a generic font that supports icons
    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];
  };
in {
  options.my.desktops.plasma = {
    enable = mkEnableOption "plasma";

    default = mkEnableOption "make default";
  };

  config = mkIf config.my.desktops.plasma.enable (mkMerge [
    (mkIf config.my.desktops.plasma.default (mkMerge [
      ({
        assertions = [
          {
            assertion = !config.my.desktops.sway.default;
            message = "Plasma and Sway cannot both be default.";
          }
        ];
      })
      (mkIf (config.specialisation != {}) attrs)
    ]))
    (mkIf (!config.my.desktops.plasma.default) {
      specialisation.plasma.configuration = attrs;
    })
  ]);
}
