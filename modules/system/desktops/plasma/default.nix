{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
in {
  options.my.system.desktops.plasma.enable = mkEnableOption "plasma";

  config = mkIf config.my.system.desktops.plasma.enable {
    my.system.audio.enable = true;

    my.users.frontear.persist.directories = [
      "~/.config"
      "~/.local"
    ];

    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];

    programs.dconf.enable = true;

    services = {
      desktopManager.plasma6.enable = true;

      displayManager.sddm.enable = true;
      displayManager.sddm.wayland.enable = true;
    };
  };
}
