{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.plasma;

  attrs = {
    # Activate plasma and sddm, with explicit wayland support.
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = lib.mkDefault true;

    # Enable pipewire as the main audio service.
    my.audio.pipewire.enable = lib.mkDefault true;

    # https://wiki.nixos.org/wiki/KDE#GTK_themes_are_not_applied_in_Wayland_applications_/_Window_Decorations_missing_/_Cursor_looks_different
    programs.dconf.enable = true;

    # Use a generic font that supports icons
    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];
  };
in {
  options.my.desktops.plasma = {
    enable = lib.mkEnableOption "plasma";

    default = lib.mkEnableOption "plasma.default";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.default (lib.mkMerge [
      ({
        assertions = [
          {
            assertion = !config.my.desktops.sway.default;
            message = "Plasma and Sway cannot both be default.";
          }
        ];
      })
      (lib.mkIf (config.specialisation != {}) attrs)
    ]))
    (lib.mkIf (!cfg.default) {
      specialisation.plasma.configuration = attrs;
    })
  ]);
}
